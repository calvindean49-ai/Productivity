import LockdownCore
import SwiftUI

/// The friction step. Exact phrase, no autocorrect, or wait out the cooldown.
struct AppealView: View {
    @EnvironmentObject var coordinator: SessionCoordinator
    @State private var typed = ""
    @State private var now = Date()
    @FocusState private var focused: Bool
    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ending early")
                .font(.largeTitle.bold())
            Text("Type this exactly:")
            Text(coordinator.config.appealPhrase)
                .font(.title3.monospaced())
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

            TextField("Phrase", text: $typed)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focused)

            let remaining = coordinator.state.appealCooldownRemaining(at: now, config: coordinator.config)
            if remaining > 0 {
                Text("Or wait \(Int(remaining.rounded(.up))) s.").foregroundStyle(.secondary)
            } else {
                Text("Cooldown over. You can end without typing.").foregroundStyle(.secondary)
            }

            Button {
                if !coordinator.submitAppeal(typed: typed) {
                    typed = ""
                }
            } label: {
                Text("End session").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!coordinator.state.appealPasses(typed: typed, at: now, config: coordinator.config))

            Button("Go back to the session") { coordinator.abandonAppeal() }
                .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(24)
        .onAppear { focused = true }
        .onReceive(clock) { now = $0 }
    }
}
