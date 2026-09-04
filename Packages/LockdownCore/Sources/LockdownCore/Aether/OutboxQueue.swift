import Foundation

public enum OutboxPayload: Codable, Equatable, Sendable {
    case departure(departureId: UUID, leftFor: String, app: String?)
    case stopSitting(durationMinutes: Int)
}

public struct OutboxItem: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var createdAt: Date
    public var attempts: Int
    public var nextAttemptAt: Date
    public var payload: OutboxPayload

    public init(id: UUID = UUID(), createdAt: Date, payload: OutboxPayload) {
        self.id = id
        self.createdAt = createdAt
        self.attempts = 0
        self.nextAttemptAt = createdAt
        self.payload = payload
    }
}

public protocol OutboxStorage: AnyObject {
    func load() throws -> [OutboxItem]
    func save(_ items: [OutboxItem]) throws
}

public final class InMemoryOutboxStorage: OutboxStorage {
    private var items: [OutboxItem] = []
    public init() {}
    public func load() throws -> [OutboxItem] { items }
    public func save(_ items: [OutboxItem]) throws { self.items = items }
}

public final class FileOutboxStorage: OutboxStorage {
    public let url: URL
    public init(url: URL) { self.url = url }

    public func load() throws -> [OutboxItem] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        return try JSONCoding.decoder.decode([OutboxItem].self, from: Data(contentsOf: url))
    }

    public func save(_ items: [OutboxItem]) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONCoding.encoder.encode(items).write(to: url, options: .atomic)
    }
}

/// Durable retry queue for the POSTs Aether must eventually receive.
/// Exponential backoff, capped; nothing is ever dropped automatically.
public final class OutboxQueue {
    public private(set) var items: [OutboxItem]
    private let storage: OutboxStorage

    public static let baseBackoff: TimeInterval = 30
    public static let maxBackoff: TimeInterval = 3600

    public init(storage: OutboxStorage) {
        self.storage = storage
        self.items = (try? storage.load()) ?? []
    }

    public static func backoff(afterAttempts n: Int) -> TimeInterval {
        let raw = baseBackoff * pow(2, Double(max(0, n - 1)))
        return min(maxBackoff, raw)
    }

    @discardableResult
    public func enqueue(_ payload: OutboxPayload, at now: Date) -> OutboxItem {
        let item = OutboxItem(createdAt: now, payload: payload)
        items.append(item)
        persist()
        return item
    }

    public func due(at now: Date) -> [OutboxItem] {
        items.filter { $0.nextAttemptAt <= now }.sorted { $0.createdAt < $1.createdAt }
    }

    public func succeeded(_ id: UUID) {
        items.removeAll { $0.id == id }
        persist()
    }

    public func failed(_ id: UUID, at now: Date) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].attempts += 1
        items[i].nextAttemptAt = now.addingTimeInterval(Self.backoff(afterAttempts: items[i].attempts))
        persist()
    }

    public func remove(_ id: UUID) {
        items.removeAll { $0.id == id }
        persist()
    }

    private func persist() {
        try? storage.save(items)
    }
}
