import LockdownCore
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: SessionCoordinator

    var body: some View {
        Group {
            switch coordinator.state.phase {
            case .idle:
                HomeView()
            case .arming, .guarding, .alarming:
                SessionView()
            case .appeal:
                AppealView()
            case .ending:
                ProgressView("Ending…")
            }
        }
        .onAppear { coordinator.restoreIfNeeded() }
        .sheet(item: $coordinator.pendingDeparture) { departure in
            DepartureSheet(departure: departure)
        }
        .preferredColorScheme(.dark)
    }
}
