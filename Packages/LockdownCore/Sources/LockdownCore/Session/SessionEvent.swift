import Foundation

public enum SessionEvent: Equatable, Sendable {
    case startRequested(minutes: Int, origin: SessionOrigin, at: Date)
    /// Leaving `arming` before the phone was placed. Free.
    case cancelled(at: Date)
    /// Classifier verdict. Sent on every sample; the reducer only cares when
    /// it changes and how long it has held.
    case posture(anchored: Bool, at: Date)
    /// Once a second while a session is active.
    case tick(at: Date)
    case earlyExitRequested(at: Date)
    case appealPassed(at: Date)
    case appealAbandoned(at: Date)
    /// Aether's sitting is no longer active.
    case aetherSessionEnded(at: Date)
    /// Result of `postAetherStart`.
    case aetherLinked(AetherLink, at: Date)
    /// No motion samples for too long while guarding.
    case sensorStalled(at: Date)
    case panic(at: Date)
    /// The coordinator has run every ending effect.
    case cleanupDone(at: Date)
}
