import LockdownCore
import SwiftUI

/// One tap, his words. Presets so the honest answer costs one touch.
struct DepartureSheet: View {
    @EnvironmentObject var coordinator: SessionCoordinator
    @Environment(\.dismiss) private var dismiss
    let departure: Departure

    @State private var text = ""
    @State private var app = ""

    private let presets = ["Toilet", "Water / food", "Someone came in", "A message", "Checked the time", "Boredom", "Anxious about something"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(prompt).font(.headline)
                    if departure.durationSeconds > 0 {
                        Text("Away \(Int(departure.durationSeconds)) s").foregroundStyle(.secondary)
                    }
                }
                Section("What did you leave for?") {
                    ForEach(presets, id: \.self) { p in
                        Button(p) { save(p) }
                    }
                    TextField("Your words", text: $text)
                    TextField("App, if any", text: $app)
                    Button("Save") { save(text) }
                        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Departure")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        coordinator.answerDeparture(departure, leftFor: nil, app: nil)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var prompt: String {
        switch departure.kind {
        case .pickup: return "You picked the phone up."
        case .earlyExit: return "You ended the session early."
        default: return "Something happened."
        }
    }

    private func save(_ reason: String) {
        coordinator.answerDeparture(departure, leftFor: reason, app: app)
        dismiss()
    }
}
