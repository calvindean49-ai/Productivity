import Foundation
import LockdownCore

/// `lockdown://` scheme, for automations that cannot use App Intents.
///
///   lockdown://start?minutes=50&origin=nfc
///   lockdown://stop
///   lockdown://departure?leftFor=water&app=Messages
///   lockdown://config?base=http://mac.local:8787,https://aether.example&token=SECRET
///   lockdown://panic
@MainActor
enum URLRouter {
    static func handle(_ url: URL, coordinator: SessionCoordinator) {
        guard url.scheme?.lowercased() == "lockdown" else { return }
        let action = (url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))).lowercased()
        let q = query(url)
        coordinator.restoreIfNeeded()

        switch action {
        case "start":
            let minutes = Int(q["minutes"] ?? "") ?? coordinator.config.defaultMinutes
            let origin = SessionOrigin(rawValue: q["origin"] ?? "") ?? .url
            _ = coordinator.start(minutes: minutes, origin: origin)

        case "stop":
            guard coordinator.state.phase.isActive else { return }
            if coordinator.state.phase == .arming {
                coordinator.cancelArming()
            } else {
                coordinator.requestEarlyExit()
            }

        case "departure":
            if let leftFor = q["leftFor"], !leftFor.isEmpty {
                coordinator.logStandaloneDeparture(leftFor: leftFor, app: q["app"])
            }

        case "config":
            var cfg = coordinator.config
            if let base = q["base"] {
                cfg.aetherBaseURLs = base.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            }
            coordinator.config = cfg
            if let token = q["token"] {
                coordinator.aether.setToken(token)
            }

        case "panic":
            coordinator.panic()

        default:
            break
        }
    }

    private static func query(_ url: URL) -> [String: String] {
        var out: [String: String] = [:]
        for item in URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? [] {
            out[item.name] = item.value ?? ""
        }
        return out
    }
}
