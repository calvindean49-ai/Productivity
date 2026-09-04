import LockdownCore
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var coordinator: SessionCoordinator
    @State private var bases = ""
    @State private var token = ""
    @State private var testResult = ""
    @State private var testing = false

    var body: some View {
        Form {
            Section("Aether OS") {
                TextField("Hosts, comma separated", text: $bases, axis: .vertical)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                SecureField("aether_session token", text: $token)
                Button("Save Aether settings") {
                    var cfg = coordinator.config
                    cfg.aetherBaseURLs = bases.split(whereSeparator: { $0 == "," || $0 == "\n" })
                        .map { String($0).trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    coordinator.config = cfg
                    coordinator.aether.setToken(token.isEmpty ? nil : token)
                }
                Button(testing ? "Testing…" : "Test connection") {
                    testing = true
                    Task {
                        testResult = await coordinator.aether.testConnection()
                        testing = false
                    }
                }
                .disabled(testing)
                if !testResult.isEmpty { Text(testResult).font(.footnote) }
                Toggle("Stop the Aether sitting on early exit", isOn: bind(\.stopAetherOnEarlyExit))
            }

            Section("Appeal") {
                TextField("Phrase to type", text: bind(\.appealPhrase))
                Stepper("Cooldown \(Int(coordinator.config.appealCooldownSeconds)) s",
                        value: bind(\.appealCooldownSeconds), in: 0...600, step: 15)
            }

            Section("Alarm") {
                Stepper("Minimum volume \(Int(coordinator.config.minOutputVolume * 100))%",
                        value: bind(\.minOutputVolume), in: 0.1...1, step: 0.1)
                Stepper("Give up after \(Int(coordinator.config.alarmTimeoutSeconds / 60)) min",
                        value: bind(\.alarmTimeoutSeconds), in: 60...3600, step: 60)
                Button("Preview alarm (2 s)") { coordinator.audio.previewAlarm() }
                Text("Current volume \(Int(coordinator.audio.outputVolume * 100))%")
                    .foregroundStyle(.secondary)
            }

            Section("Timing") {
                Stepper("Arm after \(Int(coordinator.config.graceStart)) s still",
                        value: bind(\.graceStart), in: 1...30, step: 1)
                Stepper("Alarm after \(String(format: "%.1f", coordinator.config.alarmDelay)) s moved",
                        value: bind(\.alarmDelay), in: 0.5...10, step: 0.5)
                Stepper("Silence after \(Int(coordinator.config.graceReturn)) s still",
                        value: bind(\.graceReturn), in: 1...30, step: 1)
            }

            Section {
                Toggle("Keep screen on during a session", isOn: $coordinator.keepScreenOn)
            } footer: {
                Text("Use this if motion stops arriving once the phone locks. Costs battery.")
            }

            Section {
                Button("Reset thresholds to defaults", role: .destructive) {
                    var cfg = LockdownConfig.default
                    cfg.aetherBaseURLs = coordinator.config.aetherBaseURLs
                    coordinator.config = cfg
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            bases = coordinator.config.aetherBaseURLs.joined(separator: ", ")
            token = coordinator.aether.token ?? ""
        }
    }

    private func bind<T>(_ key: WritableKeyPath<LockdownConfig, T>) -> Binding<T> {
        Binding(
            get: { coordinator.config[keyPath: key] },
            set: { coordinator.config[keyPath: key] = $0 }
        )
    }
}
