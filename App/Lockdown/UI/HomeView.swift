import LockdownCore
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: SessionCoordinator
    @State private var minutes: Int = 50
    @State private var refusal: String?

    private let presets = [25, 50, 90]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Minutes", selection: $minutes) {
                        ForEach(presets, id: \.self) { Text("\($0) min").tag($0) }
                    }
                    .pickerStyle(.segmented)
                    Stepper("Custom: \(minutes) min", value: $minutes, in: 1...600, step: 5)

                    Button {
                        switch coordinator.start(minutes: minutes, origin: .manual) {
                        case .started: refusal = nil
                        case .refused(let why): refusal = why
                        }
                    } label: {
                        Label("Start Lockdown", systemImage: "lock.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)

                    if let refusal {
                        Text(refusal).foregroundStyle(.orange)
                    }
                } header: {
                    Text("Session")
                } footer: {
                    Text("Volume must be at least \(Int(coordinator.config.minOutputVolume * 100))% and nothing plugged in. Phone goes face down on the desk; lift it and it screams.")
                }

                Section("Last") {
                    if let end = coordinator.lastEnd {
                        Text(describe(end))
                    } else {
                        Text("No session yet").foregroundStyle(.secondary)
                    }
                    if let err = coordinator.lastError {
                        Text(err).foregroundStyle(.red)
                    }
                }

                Section("Aether") {
                    Text(coordinator.aether.status).foregroundStyle(.secondary)
                    let pending = coordinator.aether.outbox.items.count
                    if pending > 0 {
                        Text("\(pending) item\(pending == 1 ? "" : "s") waiting to send")
                    }
                }

                Section {
                    NavigationLink("Departures log") { LogView() }
                    NavigationLink("Calibration") { CalibrationView() }
                    NavigationLink("Settings") { SettingsView() }
                }
            }
            .navigationTitle("Lockdown")
            .onAppear { minutes = coordinator.config.defaultMinutes }
        }
    }

    private func describe(_ reason: EndReason) -> String {
        switch reason {
        case .cancelled: return "Cancelled before arming."
        case .timerExpired: return "Finished on the timer."
        case .earlyExit: return "Ended early through the appeal."
        case .aetherStopped: return "Ended because the Aether sitting stopped."
        case .alarmTimeout: return "The alarm gave up after \(Int(coordinator.config.alarmTimeoutSeconds / 60)) minutes."
        case .panic: return "Panic stop."
        }
    }
}
