import Foundation

/// Side effects the reducer asks for. The app's coordinator executes them;
/// tests just assert on them.
public enum SessionEffect: Equatable, Sendable {
    case startMotion
    case stopMotion
    case startKeepalive
    case stopAudio
    case playAlarm
    case stopAlarm
    case persist
    case recordDeparture(Departure)
    case postAetherStart(ActiveSession)
    case postAetherStop(ActiveSession, durationMinutes: Int)
    case scheduleBackupNotifications(endsAt: Date)
    case cancelBackupNotifications
    case notify(title: String, body: String)
    case sessionEnded(EndReason)
}
