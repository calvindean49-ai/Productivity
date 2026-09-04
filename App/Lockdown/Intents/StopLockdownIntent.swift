import AppIntents
import LockdownCore

/// Never a free stop. A session that Aether started ends cleanly when its
/// Focus turns off; anything else lands on the appeal screen.
struct StopLockdownIntent: AppIntent {
    static var title: LocalizedStringResource { "End Lockdown" }
    static var description: IntentDescription {
        IntentDescription("Ends the session. From an Aether Focus it ends at once; otherwise it opens the appeal step.")
    }
    static var openAppWhenRun: Bool { true }

    @Parameter(title: "Source", default: .shortcut)
    var source: LockdownSource

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let coordinator = AppEnvironment.shared.coordinator
        coordinator.restoreIfNeeded()
        guard coordinator.state.phase.isActive else {
            return .result(dialog: "No lockdown session is running.")
        }
        let sessionOrigin = coordinator.state.session?.origin
        if (source == .aether || source == .focus), sessionOrigin == .aether || sessionOrigin == .focus {
            coordinator.dispatch(.aetherSessionEnded(at: Date()))
            return .result(dialog: "Lockdown ended with the Focus.")
        }
        if coordinator.state.phase == .arming {
            coordinator.cancelArming()
            return .result(dialog: "Lockdown cancelled before it was armed.")
        }
        coordinator.requestEarlyExit()
        return .result(dialog: "Ending early goes through the appeal step.")
    }
}
