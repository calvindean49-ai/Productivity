import Foundation

public enum SessionOrigin: String, Codable, Sendable, CaseIterable {
    case manual, siri, shortcut, nfc, backTap, url, aether, focus
}

public enum EndReason: String, Codable, Sendable {
    case cancelled      // left arming before the phone was ever placed
    case timerExpired
    case earlyExit
    case aetherStopped
    case alarmTimeout
    case panic
}

/// Whether this phone session is tied to an Aether "sitting".
public enum AetherLink: String, Codable, Sendable {
    case unlinked   // not yet asked
    case pending    // start posted, no answer yet
    case started    // this phone created the sitting
    case adopted    // Aether already had one running; we ride along
    case offline    // could not reach Aether; local only
}

public enum Phase: Codable, Equatable, Sendable {
    case idle
    case arming
    case guarding
    case alarming
    case appeal
    case ending(EndReason)

    public var isActive: Bool {
        switch self {
        case .idle: return false
        default: return true
        }
    }
}

public struct ActiveSession: Codable, Equatable, Sendable {
    public var id: UUID
    public var startedAt: Date
    public var endsAt: Date
    public var minutes: Int
    public var origin: SessionOrigin
    public var pickups: Int
    public var aether: AetherLink

    public init(id: UUID = UUID(), startedAt: Date, minutes: Int, origin: SessionOrigin) {
        self.id = id
        self.startedAt = startedAt
        self.endsAt = startedAt.addingTimeInterval(TimeInterval(minutes) * 60)
        self.minutes = minutes
        self.origin = origin
        self.pickups = 0
        self.aether = .unlinked
    }

    public func remaining(at now: Date) -> TimeInterval {
        max(0, endsAt.timeIntervalSince(now))
    }
}

/// The whole reducer state. Persisted as-is after every transition so a
/// relaunch can resume.
public struct SessionState: Codable, Equatable, Sendable {
    public var phase: Phase
    public var session: ActiveSession?
    /// Latest posture verdict and when it last changed.
    public var anchored: Bool
    public var postureSince: Date?
    public var alarmStartedAt: Date?
    public var appealStartedAt: Date?
    /// Where `appealAbandoned` goes back to.
    public var appealReturnPhase: Phase?
    public var stallReported: Bool

    public init() {
        phase = .idle
        session = nil
        anchored = false
        postureSince = nil
        alarmStartedAt = nil
        appealStartedAt = nil
        appealReturnPhase = nil
        stallReported = false
    }

    public static let idle = SessionState()

    /// Seconds the current posture has held, or 0 if unknown.
    public func postureHeld(at now: Date) -> TimeInterval {
        guard let since = postureSince else { return 0 }
        return max(0, now.timeIntervalSince(since))
    }

    public func appealCooldownRemaining(at now: Date, config: LockdownConfig) -> TimeInterval {
        guard let started = appealStartedAt else { return config.appealCooldownSeconds }
        return max(0, config.appealCooldownSeconds - now.timeIntervalSince(started))
    }

    /// The appeal passes on an exact phrase, or once the cooldown has run out.
    public func appealPasses(typed: String, at now: Date, config: LockdownConfig) -> Bool {
        guard phase == .appeal else { return false }
        if typed == config.appealPhrase { return true }
        return appealCooldownRemaining(at: now, config: config) <= 0
    }
}
