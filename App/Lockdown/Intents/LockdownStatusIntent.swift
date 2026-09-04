import AppIntents
import LockdownCore

struct LockdownStatusIntent: AppIntent {
    static var title: LocalizedStringResource { "Lockdown Status" }
    static var description: IntentDescription {
        IntentDescription("Says whether a session is running and how long is left.")
    }
    static var openAppWhenRun: Bool { false }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let coordinator = AppEnvironment.shared.coordinator
        let state = coordinator.state
        let text: String
        if let s = state.session, state.phase.isActive {
            let mins = Int((s.remaining(at: Date()) / 60).rounded(.up))
            let phase: String
            switch state.phase {
            case .arming: phase = "waiting to be placed"
            case .guarding: phase = "guarding"
            case .alarming: phase = "alarming"
            case .appeal: phase = "in appeal"
            default: phase = "ending"
            }
            text = "Lockdown is \(phase), \(mins) min left, \(s.pickups) pickups."
        } else {
            let today = coordinator.departures.filter { Calendar.current.isDateInToday($0.at) }.count
            text = "No session running. \(today) departures today."
        }
        return .result(value: text, dialog: IntentDialog("\(text)"))
    }
}
