import AppIntents
import LockdownCore

/// One tap, his words. Posts to Aether's departures table through the outbox.
struct LogDepartureIntent: AppIntent {
    static var title: LocalizedStringResource { "Log a Departure" }
    static var description: IntentDescription {
        IntentDescription("Records what you left for. Goes to Aether.")
    }
    static var openAppWhenRun: Bool { false }

    @Parameter(title: "What did you leave for?")
    var leftFor: String

    @Parameter(title: "App")
    var app: String?

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let text = leftFor.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            return .result(dialog: "Say what you left for.")
        }
        let coordinator = AppEnvironment.shared.coordinator
        coordinator.logStandaloneDeparture(leftFor: text, app: app)
        return .result(dialog: "Noted.")
    }
}
