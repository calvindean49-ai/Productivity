import Foundation

/// Thin client over the handful of Aether OS routes the phone uses.
///
/// Auth is Aether's only scheme: the `aether_session` cookie carrying the raw
/// token. There is no Bearer path on the server, so the header is built by
/// hand and URLSession's cookie jar is bypassed.
public struct AetherClient: Sendable {
    public let baseURL: URL
    public let token: String?
    private let transport: HTTPTransport

    public init(baseURL: URL, token: String?, transport: HTTPTransport) {
        self.baseURL = baseURL
        self.token = token
        self.transport = transport
    }

    // MARK: requests

    public func request<B: Encodable>(_ method: String, _ path: String, body: B?) throws -> HTTPRequest {
        var headers = ["Accept": "application/json"]
        if let token, !token.isEmpty {
            headers["Cookie"] = "aether_session=\(token)"
        }
        var data: Data? = nil
        if let body {
            headers["Content-Type"] = "application/json"
            data = try JSONCoding.encoder.encode(body)
        }
        return HTTPRequest(method: method, url: baseURL.appendingPathComponent(path), headers: headers, body: data)
    }

    public func request(_ method: String, _ path: String) throws -> HTTPRequest {
        try request(method, path, body: Optional<StopSittingBody>.none)
    }

    // MARK: routes

    public func health() async throws -> Bool {
        let r = try await send(try request("GET", "api/health"))
        return (200..<300).contains(r.status)
    }

    public func activeSession() async throws -> AetherActiveSession? {
        let r = try await send(try request("GET", "api/session/active"))
        try expect2xx(r)
        return try decode(ActiveEnvelope.self, r).active
    }

    public func startSitting(technique: String) async throws -> StartSittingResult {
        let body = StartSittingBody(knowledgeObjectIds: [], techniqueUsed: technique)
        let r = try await send(try request("POST", "api/session/start", body: body))
        if r.status == 409 { return .alreadyRunning }
        try expect2xx(r)
        let env = try decode(ActiveEnvelope.self, r)
        guard let active = env.active else {
            throw AetherError.decoding("session/start answered without an active session")
        }
        return .started(active)
    }

    public func stopSitting(durationMinutes: Int) async throws {
        let body = StopSittingBody(durationMinutes: durationMinutes, selfReported: "lockdown-ios timer")
        let r = try await send(try request("POST", "api/session/stop", body: body))
        // 409 = no session running: nothing left to stop, treat as done.
        if r.status == 409 { return }
        try expect2xx(r)
    }

    public func discardSitting() async throws {
        let r = try await send(try request("POST", "api/session/discard"))
        if r.status == 409 { return }
        try expect2xx(r)
    }

    public func noteDeparture(leftFor: String, app: String?) async throws {
        let text = String(leftFor.prefix(200))
        let r = try await send(try request("POST", "api/native/departures", body: DepartureBody(leftFor: text, app: app)))
        try expect2xx(r)
    }

    // MARK: helpers

    private func send(_ req: HTTPRequest) async throws -> HTTPResponse {
        do {
            return try await transport.send(req)
        } catch let e as AetherError {
            throw e
        } catch {
            throw AetherError.transport(String(describing: error))
        }
    }

    private func expect2xx(_ r: HTTPResponse) throws {
        guard (200..<300).contains(r.status) else {
            let msg = (try? JSONCoding.decoder.decode(ErrorEnvelope.self, from: r.body))?.error
            throw AetherError.http(status: r.status, message: msg)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, _ r: HTTPResponse) throws -> T {
        do {
            return try JSONCoding.decoder.decode(type, from: r.body)
        } catch {
            throw AetherError.decoding(String(describing: error))
        }
    }
}

/// Try each base URL in order and return the first one that answers.
/// 127.0.0.1 is only ever the Mac itself; the phone needs a LAN, Tailscale or
/// public host, which is why this takes a list.
public func firstReachable(_ bases: [URL], probe: (URL) async -> Bool) async -> URL? {
    for base in bases {
        if await probe(base) { return base }
    }
    return nil
}
