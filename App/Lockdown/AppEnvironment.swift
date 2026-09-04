import Foundation
import LockdownCore

/// One place that wires the pure core to the platform services. App Intents
/// and the URL router reach the coordinator through `shared`, so it must be
/// cheap to create and must not start audio or motion on its own.
@MainActor
final class AppEnvironment {
    static let shared = AppEnvironment()

    let settings: SettingsStore
    let keychain: KeychainStore
    let departureLog: FileDepartureLog
    let outbox: OutboxQueue
    let aether: AetherService
    let coordinator: SessionCoordinator

    private init() {
        settings = SettingsStore()
        keychain = KeychainStore(service: "com.calvindean.lockdown")
        let support = SettingsStore.supportDirectory
        departureLog = FileDepartureLog(url: support.appendingPathComponent("departures.json"))
        outbox = OutboxQueue(storage: FileOutboxStorage(url: support.appendingPathComponent("outbox.json")))
        aether = AetherService(config: settings.loadConfig(), keychain: keychain, outbox: outbox)
        coordinator = SessionCoordinator(
            settings: settings,
            departureLog: departureLog,
            aether: aether,
            motion: MotionService(),
            audio: AudioService(),
            notifications: NotificationService()
        )
    }
}
