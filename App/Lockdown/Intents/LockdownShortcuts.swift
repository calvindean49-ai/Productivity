import AppIntents

struct LockdownShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartLockdownIntent(),
            phrases: [
                "Start lockdown in \(.applicationName)",
                "Lock me down with \(.applicationName)",
                "Start a \(.applicationName) session",
            ],
            shortTitle: "Start Lockdown",
            systemImageName: "lock.fill"
        )
        AppShortcut(
            intent: StopLockdownIntent(),
            phrases: [
                "End lockdown in \(.applicationName)",
                "Stop \(.applicationName)",
            ],
            shortTitle: "End Lockdown",
            systemImageName: "lock.open"
        )
        AppShortcut(
            intent: LockdownStatusIntent(),
            phrases: [
                "\(.applicationName) status",
                "How long is left in \(.applicationName)",
            ],
            shortTitle: "Status",
            systemImageName: "timer"
        )
        AppShortcut(
            intent: LogDepartureIntent(),
            phrases: [
                "Log a departure in \(.applicationName)",
            ],
            shortTitle: "Log Departure",
            systemImageName: "figure.walk.departure"
        )
    }
}
