import Foundation

/// `GET /api/session/active` -> `{ active: null | {...} }`. Dates stay as
/// strings: Aether writes ISO 8601 and nothing here needs to do arithmetic on
/// them.
public struct AetherActiveSession: Codable, Equatable, Sendable {
    public var startedAt: String
    public var knowledgeObjectIds: [String]?
    public var techniqueUsed: String?
    public var planItemId: String?
    public var runningMinutes: Double?
    public var likelyForgotten: Bool?

    public init(startedAt: String, knowledgeObjectIds: [String]? = nil, techniqueUsed: String? = nil,
                planItemId: String? = nil, runningMinutes: Double? = nil, likelyForgotten: Bool? = nil) {
        self.startedAt = startedAt
        self.knowledgeObjectIds = knowledgeObjectIds
        self.techniqueUsed = techniqueUsed
        self.planItemId = planItemId
        self.runningMinutes = runningMinutes
        self.likelyForgotten = likelyForgotten
    }
}

struct ActiveEnvelope: Codable {
    var active: AetherActiveSession?
}

struct StartSittingBody: Encodable {
    var knowledgeObjectIds: [String]
    var techniqueUsed: String
}

struct StopSittingBody: Encodable {
    var durationMinutes: Int
    var selfReported: String
}

struct DepartureBody: Encodable {
    var leftFor: String
    var app: String?
}

struct ErrorEnvelope: Decodable {
    var error: String?
    var code: String?
}

public enum StartSittingResult: Equatable, Sendable {
    case started(AetherActiveSession)
    /// Aether answered 409: a sitting was already running. Ride along.
    case alreadyRunning
}

public enum AetherError: Error, Equatable, Sendable {
    case http(status: Int, message: String?)
    case decoding(String)
    case transport(String)
}
