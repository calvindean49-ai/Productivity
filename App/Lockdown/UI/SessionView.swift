import LockdownCore
import SwiftUI

/// Black screen. It is meant to be looked at for two seconds while the
/// phone goes face down, then never again until the session ends.
struct SessionView: View {
    @EnvironmentObject var coordinator: SessionCoordinator
    @State private var now = Date()
    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                Text(headline)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                if let p = coordinator.posture, coordinator.state.phase == .arming {
                    Text(p.faceDown ? (p.still ? "Face down and still…" : "Face down, hold still") : "Turn it face down")
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                if coordinator.state.phase == .arming {
                    Button("Cancel") { coordinator.cancelArming() }
                        .buttonStyle(.bordered)
                        .tint(.white)
                } else {
                    Button("End early") { coordinator.requestEarlyExit() }
                        .buttonStyle(.bordered)
                        .tint(.white)
                    Button("Panic stop") { coordinator.panic() }
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(32)
        }
        .onReceive(clock) { now = $0 }
        .persistentSystemOverlays(.hidden)
    }

    private var background: Color {
        switch coordinator.state.phase {
        case .alarming: return .red
        default: return .black
        }
    }

    private var headline: String {
        switch coordinator.state.phase {
        case .arming: return "Place the phone face down"
        case .guarding: return remaining
        case .alarming: return "PUT IT BACK"
        default: return ""
        }
    }

    private var detail: String {
        switch coordinator.state.phase {
        case .arming: return "Hold still for \(Int(coordinator.config.graceStart)) seconds to arm."
        case .guarding:
            let pickups = coordinator.state.session?.pickups ?? 0
            return pickups == 0 ? "Guarding." : "Guarding. \(pickups) pickup\(pickups == 1 ? "" : "s") so far."
        case .alarming: return "Face down and still for \(Int(coordinator.config.graceReturn)) seconds to silence it."
        default: return ""
        }
    }

    private var remaining: String {
        guard let s = coordinator.state.session else { return "" }
        let secs = Int(s.remaining(at: now))
        return String(format: "%02d:%02d", secs / 60, secs % 60)
    }
}
