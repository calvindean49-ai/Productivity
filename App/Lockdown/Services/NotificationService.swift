import Foundation
import UserNotifications

/// Local notifications as the fallback when the process dies mid-session.
/// They cannot beat the silent switch (that needs Critical Alerts, which a
/// personal build will not get) but they do break through a Focus.
final class NotificationService {
    private let center = UNUserNotificationCenter.current()
    private let prefix = "lockdown.backup."
    private let maxChecks = 12

    private var knownIdentifiers: [String] {
        (0..<maxChecks).map { "\(prefix)check.\($0)" } + ["\(prefix)end"]
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .timeSensitive]) { _, _ in }
    }

    func scheduleBackups(endsAt: Date, everyMinutes: Int = 10, now: Date = Date()) {
        cancelBackups()
        var requests: [UNNotificationRequest] = []
        var t = now.addingTimeInterval(TimeInterval(everyMinutes * 60))
        var i = 0
        while t < endsAt && i < maxChecks {
            requests.append(make(id: "\(prefix)check.\(i)", at: t,
                                 title: "Is Lockdown still guarding?",
                                 body: "If you see this, the guard may have stopped. Open the app."))
            t = t.addingTimeInterval(TimeInterval(everyMinutes * 60))
            i += 1
        }
        requests.append(make(id: "\(prefix)end", at: endsAt,
                             title: "Session over", body: "Lockdown timer finished."))
        requests.forEach { center.add($0) }
    }

    /// Identifiers are deterministic, so this is synchronous and cannot race
    /// with a `scheduleBackups` that follows it.
    func cancelBackups() {
        center.removePendingNotificationRequests(withIdentifiers: knownIdentifiers)
    }

    func post(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }

    private func make(id: String, at date: Date, title: String, body: String) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        let interval = max(1, date.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
}
