import AppIntents
import LockdownCore

/// Where a Shortcut-driven start came from, so the log can say "NFC" rather
/// than "shortcut" when he tapped the tag on the desk.
enum LockdownSource: String, AppEnum {
    case shortcut, siri, nfc, backTap, aether, focus

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Source" }

    static var caseDisplayRepresentations: [LockdownSource: DisplayRepresentation] {
        [
            .shortcut: "Shortcut",
            .siri: "Siri",
            .nfc: "NFC tag",
            .backTap: "Back Tap",
            .aether: "Aether Focus",
            .focus: "Focus mode",
        ]
    }

    var origin: SessionOrigin {
        switch self {
        case .shortcut: return .shortcut
        case .siri: return .siri
        case .nfc: return .nfc
        case .backTap: return .backTap
        case .aether: return .aether
        case .focus: return .focus
        }
    }
}
