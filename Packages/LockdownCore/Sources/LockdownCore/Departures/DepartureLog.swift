import Foundation

public protocol DepartureStore: AnyObject {
    func all() throws -> [Departure]
    func append(_ departure: Departure) throws
    func update(_ departure: Departure) throws
}

public final class InMemoryDepartureLog: DepartureStore {
    private var items: [Departure] = []
    public init() {}
    public func all() throws -> [Departure] { items }
    public func append(_ departure: Departure) throws { items.append(departure) }
    public func update(_ departure: Departure) throws {
        if let i = items.firstIndex(where: { $0.id == departure.id }) {
            items[i] = departure
        } else {
            items.append(departure)
        }
    }
}

/// Whole-file JSON array. Small, rewritten on every change, atomic write.
public final class FileDepartureLog: DepartureStore {
    public let url: URL
    private var cache: [Departure]?

    public init(url: URL) {
        self.url = url
    }

    public func all() throws -> [Departure] {
        if let cache { return cache }
        guard FileManager.default.fileExists(atPath: url.path) else {
            cache = []
            return []
        }
        let data = try Data(contentsOf: url)
        let items = try JSONCoding.decoder.decode([Departure].self, from: data)
        cache = items
        return items
    }

    public func append(_ departure: Departure) throws {
        var items = try all()
        items.append(departure)
        try save(items)
    }

    public func update(_ departure: Departure) throws {
        var items = try all()
        if let i = items.firstIndex(where: { $0.id == departure.id }) {
            items[i] = departure
        } else {
            items.append(departure)
        }
        try save(items)
    }

    private func save(_ items: [Departure]) throws {
        let data = try JSONCoding.encoder.encode(items)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
        cache = items
    }
}

/// One encoder/decoder pair so every file and every request agrees on dates.
public enum JSONCoding {
    public static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.sortedKeys]
        return e
    }()

    public static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
