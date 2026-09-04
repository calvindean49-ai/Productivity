import Foundation
import LockdownCore

/// UserDefaults for small things, Application Support for files. No App
/// Group: the v1 build is a single target on a free account.
final class SettingsStore {
    private let defaults = UserDefaults.standard
    private enum Key {
        static let config = "lockdown.config"
        static let state = "lockdown.sessionState"
        static let keepScreenOn = "lockdown.keepScreenOn"
    }

    static var supportDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Lockdown", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func loadConfig() -> LockdownConfig {
        guard let data = defaults.data(forKey: Key.config),
              let cfg = try? JSONCoding.decoder.decode(LockdownConfig.self, from: data) else {
            return .default
        }
        return cfg
    }

    func saveConfig(_ config: LockdownConfig) {
        if let data = try? JSONCoding.encoder.encode(config) {
            defaults.set(data, forKey: Key.config)
        }
    }

    func loadState() -> SessionState? {
        guard let data = defaults.data(forKey: Key.state) else { return nil }
        return try? JSONCoding.decoder.decode(SessionState.self, from: data)
    }

    func saveState(_ state: SessionState) {
        if let data = try? JSONCoding.encoder.encode(state) {
            defaults.set(data, forKey: Key.state)
        }
    }

    var keepScreenOn: Bool {
        get { defaults.bool(forKey: Key.keepScreenOn) }
        set { defaults.set(newValue, forKey: Key.keepScreenOn) }
    }
}
