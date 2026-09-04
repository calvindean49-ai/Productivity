import AppIntents
import LockdownCore

/// The one reliable entry point. It opens the app because starting audio and
/// motion from the background is not something iOS promises; in the
/// foreground the arming screen also handles the volume and headphone gate.
struct StartLockdownIntent: AppIntent {
    static var title: LocalizedStringResource { "Start Lockdown" }
    static var description: IntentDescription {
        IntentDescription("Starts a lockdown session: phone face-down, alarm if lifted.")
    }
    static var openAppWhenRun: Bool { true }

    @Parameter(title: "Minutes", default: 50, inclusiveRange: (1, 600))
    var minutes: Int

    @Parameter(title: "Source", default: .shortcut)
    var source: LockdownSource

    static var parameterSummary: some ParameterSummary {
        Summary("Start lockdown for \(\.$minutes) minutes from \(\.$source)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let coordinator = AppEnvironment.shared.coordinator
        coordinator.restoreIfNeeded()
        switch coordinator.start(minutes: minutes, origin: source.origin) {
        case .started:
            return .result(dialog: "Lockdown armed for \(minutes) minutes. Place the phone face down.")
        case .refused(let reason):
            return .result(dialog: "Not started: \(reason)")
        }
    }
}
