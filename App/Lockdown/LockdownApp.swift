import SwiftUI

@main
struct LockdownApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var coordinator = AppEnvironment.shared.coordinator

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .onOpenURL { url in
                    URLRouter.handle(url, coordinator: coordinator)
                }
        }
        .onChange(of: scenePhase) { _, phase in
            coordinator.scenePhaseChanged(phase)
        }
    }
}
