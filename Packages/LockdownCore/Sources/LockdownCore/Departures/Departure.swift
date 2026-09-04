import Foundation

public enum DepartureKind: String, Codable, Sendable, CaseIterable {
    /// The phone was lifted during a session and later put back.
    case pickup
    /// The session was ended early through the appeal step.
    case earlyExit
    /// Motion samples stopped arriving; the guard could not see the phone.
    case sensorStall
    /// The alarm played for the configured maximum and the session gave up.
    case alarmTimeout
    /// `lockdown://panic` or the panic button: everything stopped, no appeal.
    case panic
}

/// One thing that pulled Calvin away. Mirrors Aether's `departures` row in
/// spirit: his words, optionally the app, and nothing that grades him.
public struct Departure: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var sessionId: UUID
    public var at: Date
    public var kind: DepartureKind
    /// How long the phone was away from the desk (pickup) or how long the
    /// alarm had been sounding (early exit); 0 when not applicable.
    public var durationSeconds: TimeInterval
    /// Filled in by the departure sheet; nil until he answers.
    public var leftFor: String?
    public var app: String?
    /// True once Aether has accepted it.
    public var synced: Bool

    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        at: Date,
        kind: DepartureKind,
        durationSeconds: TimeInterval = 0,
        leftFor: String? = nil,
        app: String? = nil,
        synced: Bool = false
    ) {
        self.id = id
        self.sessionId = sessionId
        self.at = at
        self.kind = kind
        self.durationSeconds = durationSeconds
        self.leftFor = leftFor
        self.app = app
        self.synced = synced
    }

    /// What gets sent to Aether when he never answered the sheet. Honest and
    /// short; Aether refuses only the empty string.
    public var leftForOrPlaceholder: String {
        if let leftFor, !leftFor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return leftFor
        }
        switch kind {
        case .pickup: return "picked up the phone, reason not given"
        case .earlyExit: return "ended the session early, reason not given"
        case .sensorStall: return "the phone guard lost its sensor"
        case .alarmTimeout: return "left the phone alarming until it gave up"
        case .panic: return "hit panic"
        }
    }
}
