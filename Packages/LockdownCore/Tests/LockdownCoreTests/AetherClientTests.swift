import XCTest
@testable import LockdownCore

final class ScriptedTransport: HTTPTransport, @unchecked Sendable {
    var responses: [HTTPResponse]
    var requests: [HTTPRequest] = []
    var failWith: Error?

    init(_ responses: [HTTPResponse]) { self.responses = responses }

    func send(_ request: HTTPRequest) async throws -> HTTPResponse {
        requests.append(request)
        if let failWith { throw failWith }
        return responses.isEmpty ? HTTPResponse(status: 500) : responses.removeFirst()
    }
}

struct Boom: Error {}

final class AetherClientTests: XCTestCase {
    let base = URL(string: "http://mac.local:8787")!

    func json(_ s: String) -> Data { Data(s.utf8) }

    func testRequestCarriesCookieAndJSON() throws {
        let t = ScriptedTransport([])
        let c = AetherClient(baseURL: base, token: "secret", transport: t)
        let r = try c.request("POST", "api/native/departures", body: DepartureBody(leftFor: "water", app: nil))
        XCTAssertEqual(r.url.absoluteString, "http://mac.local:8787/api/native/departures")
        XCTAssertEqual(r.headers["Cookie"], "aether_session=secret")
        XCTAssertEqual(r.headers["Content-Type"], "application/json")
        XCTAssertEqual(String(decoding: r.body!, as: UTF8.self), #"{"leftFor":"water"}"#)
    }

    func testNoTokenMeansNoCookie() throws {
        let c = AetherClient(baseURL: base, token: nil, transport: ScriptedTransport([]))
        let r = try c.request("GET", "api/health")
        XCTAssertNil(r.headers["Cookie"])
        XCTAssertNil(r.body)
    }

    func testActiveSessionNull() async throws {
        let t = ScriptedTransport([HTTPResponse(status: 200, body: json(#"{"active":null}"#))])
        let c = AetherClient(baseURL: base, token: "x", transport: t)
        let a = try await c.activeSession()
        XCTAssertNil(a)
        XCTAssertEqual(t.requests.first?.method, "GET")
        XCTAssertEqual(t.requests.first?.url.path, "/api/session/active")
    }

    func testActiveSessionPresent() async throws {
        let body = #"{"active":{"startedAt":"2026-09-04T10:00:00.000Z","knowledgeObjectIds":["k1"],"techniqueUsed":null,"planItemId":null,"runningMinutes":12,"likelyForgotten":false}}"#
        let t = ScriptedTransport([HTTPResponse(status: 200, body: json(body))])
        let c = AetherClient(baseURL: base, token: "x", transport: t)
        let a = try await c.activeSession()
        XCTAssertEqual(a?.startedAt, "2026-09-04T10:00:00.000Z")
        XCTAssertEqual(a?.runningMinutes, 12)
        XCTAssertEqual(a?.knowledgeObjectIds, ["k1"])
    }

    func testStartSittingStartedAnd409() async throws {
        let started = #"{"active":{"startedAt":"2026-09-04T10:00:00.000Z"},"focus":{"ran":false}}"#
        let t = ScriptedTransport([
            HTTPResponse(status: 200, body: json(started)),
            HTTPResponse(status: 409, body: json(#"{"error":"A session is already running."}"#)),
        ])
        let c = AetherClient(baseURL: base, token: "x", transport: t)
        let r1 = try await c.startSitting(technique: "lockdown-ios")
        guard case .started(let a) = r1 else { return XCTFail("expected started") }
        XCTAssertEqual(a.startedAt, "2026-09-04T10:00:00.000Z")
        let sent = String(decoding: t.requests[0].body!, as: UTF8.self)
        XCTAssertEqual(sent, #"{"knowledgeObjectIds":[],"techniqueUsed":"lockdown-ios"}"#)

        let r2 = try await c.startSitting(technique: "lockdown-ios")
        XCTAssertEqual(r2, .alreadyRunning)
    }

    func testStopSittingTreats409AsDone() async throws {
        let t = ScriptedTransport([HTTPResponse(status: 409, body: json(#"{"error":"No session is running."}"#))])
        let c = AetherClient(baseURL: base, token: "x", transport: t)
        try await c.stopSitting(durationMinutes: 50)
        XCTAssertEqual(t.requests.first?.url.path, "/api/session/stop")
    }

    func testHTTPErrorSurfacesMessage() async {
        let t = ScriptedTransport([HTTPResponse(status: 400, body: json(#"{"error":"leftFor is required"}"#))])
        let c = AetherClient(baseURL: base, token: "x", transport: t)
        do {
            try await c.noteDeparture(leftFor: "", app: nil)
            XCTFail("should throw")
        } catch let e as AetherError {
            XCTAssertEqual(e, .http(status: 400, message: "leftFor is required"))
        } catch {
            XCTFail("wrong error \(error)")
        }
    }

    func testDepartureTruncatedTo200() async throws {
        let t = ScriptedTransport([HTTPResponse(status: 201, body: json("{}"))])
        let c = AetherClient(baseURL: base, token: "x", transport: t)
        try await c.noteDeparture(leftFor: String(repeating: "a", count: 300), app: "Messages")
        let body = try JSONDecoder().decode([String: String].self, from: t.requests[0].body!)
        XCTAssertEqual(body["leftFor"]?.count, 200)
        XCTAssertEqual(body["app"], "Messages")
    }

    func testTransportFailureWrapped() async {
        let t = ScriptedTransport([])
        t.failWith = Boom()
        let c = AetherClient(baseURL: base, token: "x", transport: t)
        do {
            _ = try await c.health()
            XCTFail("should throw")
        } catch let e as AetherError {
            if case .transport = e {} else { XCTFail("expected transport error, got \(e)") }
        } catch {
            XCTFail("wrong error \(error)")
        }
    }

    func testFirstReachablePicksInOrder() async {
        let a = URL(string: "http://a")!, b = URL(string: "http://b")!, c = URL(string: "http://c")!
        let picked = await firstReachable([a, b, c]) { $0 == b || $0 == c }
        XCTAssertEqual(picked, b)
        let none = await firstReachable([a]) { _ in false }
        XCTAssertNil(none)
    }
}
