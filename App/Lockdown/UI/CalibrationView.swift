import LockdownCore
import SwiftUI

/// Milestone 2's instrument. Streams motion through the real classifier with
/// the audio keepalive on, shows samples per second, and records traces to
/// Documents (visible in the Files app) for the regression fixtures.
struct CalibrationView: View {
    @EnvironmentObject var coordinator: SessionCoordinator
    @State private var recording: [String] = []
    @State private var isRecording = false
    @State private var lastSaved: String?
    @State private var label = "desk"

    var body: some View {
        Form {
            Section("Stream") {
                Button(coordinator.isStreaming ? "Stop streaming" : "Start streaming (keepalive on)") {
                    if coordinator.isStreaming {
                        coordinator.stopStreaming()
                    } else {
                        coordinator.startStreaming()
                    }
                }
                LabeledContent("Samples / s", value: String(format: "%.1f", coordinator.samplesPerSecond))
                if let p = coordinator.posture {
                    LabeledContent("Gravity z", value: String(format: "%.2f", p.gravityZ))
                    LabeledContent("RMS", value: String(format: "%.3f g", p.rms))
                    LabeledContent("Peak", value: String(format: "%.3f g", p.peak))
                    LabeledContent("Drift", value: String(format: "%.3f", p.drift))
                    LabeledContent("Face down", value: p.faceDown ? "yes" : "no")
                    LabeledContent("Still", value: p.still ? "yes" : "no")
                    LabeledContent("Anchored", value: p.anchored ? "YES" : "no")
                }
            }

            Section {
                TextField("Trace label", text: $label)
                Button(isRecording ? "Stop and save (\(recording.count) samples)" : "Record trace") {
                    if isRecording { save() } else { begin() }
                }
                .disabled(!coordinator.isStreaming)
                if let lastSaved { Text("Saved \(lastSaved)").font(.footnote) }
            } header: {
                Text("Traces")
            } footer: {
                Text("Record 'desk' (face down, still), 'pickup' and 'bump' traces, then lock the phone and watch whether samples keep arriving. Files land in the Files app under Lockdown.")
            }
        }
        .navigationTitle("Calibration")
        .onDisappear {
            coordinator.trace = nil
            if !isRecording { coordinator.stopStreaming() }
        }
    }

    private func begin() {
        recording = []
        isRecording = true
        coordinator.trace = { sample, posture in
            if let data = try? JSONCoding.encoder.encode(TraceLine(sample: sample, anchored: posture.anchored, faceDown: posture.faceDown, still: posture.still)),
               let line = String(data: data, encoding: .utf8) {
                recording.append(line)
            }
        }
    }

    private func save() {
        isRecording = false
        coordinator.trace = nil
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let name = "\(label.isEmpty ? "trace" : label)-\(stamp).jsonl"
        let url = SettingsStore.documentsDirectory.appendingPathComponent(name)
        try? recording.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
        lastSaved = name
    }
}

private struct TraceLine: Encodable {
    var sample: MotionSample
    var anchored: Bool
    var faceDown: Bool
    var still: Bool
}
