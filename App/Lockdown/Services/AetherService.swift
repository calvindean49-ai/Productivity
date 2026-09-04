import Foundation
import LockdownCore

/// URLSession-backed transport. Cookie handling is off so the only cookie
/// Aether ever sees is the one the client builds by hand.
struct URLSessionTransport: HTTPTransport {
    let session: URLSession

    init(timeout: TimeInterval = 10) {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = timeout
        cfg.httpShouldSetCookies = false
        cfg.httpCookieAcceptPolicy = .never
        cfg.waitsForConnectivity = false
        session = URLSession(configuration: cfg)
    }

    func send(_ request: HTTPRequest) async throws -> HTTPResponse {
        var r = URLRequest(url: request.url)
        r.httpMethod = request.method
        r.httpShouldHandleCookies = false
        for (k, v) in request.headers { r.setValue(v, forHTTPHeaderField: k) }
        r.httpBody = request.body
        let (data, resp) = try await session.data(for: r)
        let status = (resp as? HTTPURLResponse)?.statusCode ?? 0
        return HTTPResponse(status: status, body: data)
    }
}

/// Everything network-shaped: which Aether host answers, the sitting calls,
/// the 60 s poll during a session, and draining the outbox.
@MainActor
final class AetherService: ObservableObject {
    @Published private(set) var status: String = "not configured"
    @Published private(set) var resolvedBase: URL?

    var config: LockdownConfig {
        didSet { if config.aetherBaseURLs != oldValue.aetherBaseURLs { resolvedBase = nil } }
    }
    private let keychain: KeychainStore
    let outbox: OutboxQueue
    private let transport = URLSessionTransport()
    private let tokenAccount = "aether-token"
    private var draining = false

    init(config: LockdownConfig, keychain: KeychainStore, outbox: OutboxQueue) {
        self.config = config
        self.keychain = keychain
        self.outbox = outbox
    }

    var token: String? { keychain.read(tokenAccount) }
    var hasToken: Bool { !(token ?? "").isEmpty }

    func setToken(_ value: String?) {
        if let value, !value.isEmpty {
            keychain.write(value, account: tokenAccount)
        } else {
            keychain.delete(tokenAccount)
        }
        resolvedBase = nil
    }

    var configuredBases: [URL] {
        config.aetherBaseURLs.compactMap { raw in
            let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !s.isEmpty, let u = URL(string: s), u.scheme != nil else { return nil }
            return u
        }
    }

    private func client(for base: URL) -> AetherClient {
        AetherClient(baseURL: base, token: token, transport: transport)
    }

    /// First configured host that answers `/api/session/active`. Cached until
    /// the host list or the token changes, or a call fails.
    func resolveClient() async -> AetherClient? {
        if let base = resolvedBase { return client(for: base) }
        let bases = configuredBases
        guard !bases.isEmpty else {
            status = "no Aether host configured"
            return nil
        }
        let picked = await firstReachable(bases) { base in
            await self.reachable(base)
        }
        if let picked {
            resolvedBase = picked
            status = "connected to \(picked.host ?? picked.absoluteString)"
            return client(for: picked)
        }
        status = "no Aether host reachable"
        return nil
    }

    /// A host counts as reachable if `session/active` answers at all (an
    /// empty answer is still an answer), falling back to `health`.
    private func reachable(_ base: URL) async -> Bool {
        let c = client(for: base)
        do {
            _ = try await c.activeSession()
            return true
        } catch {
            return (try? await c.health()) ?? false
        }
    }

    func testConnection() async -> String {
        resolvedBase = nil
        guard let c = await resolveClient() else { return status }
        do {
            let active = try await c.activeSession()
            return "OK. Active sitting: \(active == nil ? "none" : "yes, \(Int(active?.runningMinutes ?? 0)) min")"
        } catch {
            resolvedBase = nil
            return "Reached host but request failed: \(error)"
        }
    }

    /// Ask Aether to open a sitting for this phone session.
    func startSitting() async -> AetherLink {
        guard let c = await resolveClient() else { return .offline }
        do {
            switch try await c.startSitting(technique: config.techniqueLabel) {
            case .started: return .started
            case .alreadyRunning: return .adopted
            }
        } catch {
            resolvedBase = nil
            status = "start failed: \(error)"
            return .offline
        }
    }

    /// nil = unreachable; true/false = whether a sitting is active.
    func pollActive() async -> Bool? {
        guard let c = await resolveClient() else { return nil }
        do {
            return try await c.activeSession() != nil
        } catch {
            resolvedBase = nil
            return nil
        }
    }

    func enqueueDeparture(_ d: Departure, now: Date = Date()) {
        outbox.enqueue(.departure(departureId: d.id, leftFor: d.leftForOrPlaceholder, app: d.app), at: now)
    }

    func enqueueStop(durationMinutes: Int, now: Date = Date()) {
        outbox.enqueue(.stopSitting(durationMinutes: durationMinutes), at: now)
    }

    /// Send what is due. Returns ids of departures Aether accepted so the log
    /// can mark them synced.
    @discardableResult
    func drain(now: Date = Date()) async -> [UUID] {
        guard !draining else { return [] }
        let due = outbox.due(at: now)
        guard !due.isEmpty, let c = await resolveClient() else { return [] }
        draining = true
        defer { draining = false }
        var synced: [UUID] = []
        for item in due {
            do {
                switch item.payload {
                case .departure(let id, let leftFor, let app):
                    try await c.noteDeparture(leftFor: leftFor, app: app)
                    synced.append(id)
                case .stopSitting(let minutes):
                    try await c.stopSitting(durationMinutes: minutes)
                }
                outbox.succeeded(item.id)
            } catch AetherError.http(let status, _) where (400..<500).contains(status) && status != 401 && status != 403 {
                // Aether refused the content itself; retrying will not help.
                outbox.remove(item.id)
                self.status = "Aether rejected an item (\(status))"
            } catch {
                outbox.failed(item.id, at: now)
                resolvedBase = nil
                self.status = "send failed, will retry: \(error)"
                break
            }
        }
        return synced
    }
}
