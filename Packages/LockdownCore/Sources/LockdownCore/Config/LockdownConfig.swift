import Foundation

/// Every tunable number in one Codable value. The app persists this and the
/// Calibration screen edits it; nothing in the package hard-codes a threshold.
public struct LockdownConfig: Codable, Equatable, Sendable {
    // Session
    public var defaultMinutes: Int
    /// Alarm that has played continuously this long ends the session
    /// (battery and goodwill guard).
    public var alarmTimeoutSeconds: TimeInterval

    // Posture classifier
    public var faceDownEnter: Double   // gravity z above this = face down
    public var faceDownExit: Double    // gravity z below this = no longer face down
    public var stillRMS: Double        // g, rms of user acceleration over the window
    public var stillPeak: Double       // g, max |user acceleration| over the window
    public var gravityDrift: Double    // max change of gravity vector over the window
    public var windowSeconds: TimeInterval

    // Timing (seconds)
    public var graceStart: TimeInterval   // anchored this long while arming -> guarding
    public var alarmDelay: TimeInterval   // un-anchored this long while guarding -> alarm
    public var graceReturn: TimeInterval  // anchored this long while alarming -> guarding
    public var stallRestartSeconds: TimeInterval
    public var stallFailSeconds: TimeInterval

    // Appeal
    public var appealPhrase: String
    public var appealCooldownSeconds: TimeInterval

    // Audio
    public var minOutputVolume: Double

    // Aether
    public var aetherBaseURLs: [String]
    public var aetherPollSeconds: TimeInterval
    public var stopAetherOnEarlyExit: Bool
    public var techniqueLabel: String

    public init(
        defaultMinutes: Int = 50,
        alarmTimeoutSeconds: TimeInterval = 600,
        faceDownEnter: Double = 0.85,
        faceDownExit: Double = 0.70,
        stillRMS: Double = 0.02,
        stillPeak: Double = 0.08,
        gravityDrift: Double = 0.05,
        windowSeconds: TimeInterval = 1.0,
        graceStart: TimeInterval = 5,
        alarmDelay: TimeInterval = 1.5,
        graceReturn: TimeInterval = 3,
        stallRestartSeconds: TimeInterval = 4,
        stallFailSeconds: TimeInterval = 15,
        appealPhrase: String = "I am choosing to stop studying now",
        appealCooldownSeconds: TimeInterval = 90,
        minOutputVolume: Double = 0.8,
        aetherBaseURLs: [String] = [],
        aetherPollSeconds: TimeInterval = 60,
        stopAetherOnEarlyExit: Bool = false,
        techniqueLabel: String = "lockdown-ios"
    ) {
        self.defaultMinutes = defaultMinutes
        self.alarmTimeoutSeconds = alarmTimeoutSeconds
        self.faceDownEnter = faceDownEnter
        self.faceDownExit = faceDownExit
        self.stillRMS = stillRMS
        self.stillPeak = stillPeak
        self.gravityDrift = gravityDrift
        self.windowSeconds = windowSeconds
        self.graceStart = graceStart
        self.alarmDelay = alarmDelay
        self.graceReturn = graceReturn
        self.stallRestartSeconds = stallRestartSeconds
        self.stallFailSeconds = stallFailSeconds
        self.appealPhrase = appealPhrase
        self.appealCooldownSeconds = appealCooldownSeconds
        self.minOutputVolume = minOutputVolume
        self.aetherBaseURLs = aetherBaseURLs
        self.aetherPollSeconds = aetherPollSeconds
        self.stopAetherOnEarlyExit = stopAetherOnEarlyExit
        self.techniqueLabel = techniqueLabel
    }

    public static let `default` = LockdownConfig()
}
