import Foundation
import SwiftUI

/// Runtime language selection (`Settings` → `app_preferred_language`).
enum AppLanguage {
    static let storageKey = "app_preferred_language"

    static var code: String {
        let stored = UserDefaults.standard.string(forKey: storageKey) ?? "system"
        if stored == "system" {
            let preferred = Locale.preferredLanguages.first ?? "en"
            if preferred.hasPrefix("ar") { return "ar" }
            if preferred.hasPrefix("fr") { return "fr" }
            return "en"
        }
        return stored
    }

    static var locale: Locale {
        switch code {
        case "ar": return Locale(identifier: "ar")
        case "fr": return Locale(identifier: "fr")
        default: return Locale(identifier: "en")
        }
    }

    static var layoutDirection: LayoutDirection {
        code == "ar" ? .rightToLeft : .leftToRight
    }

    static var localizedBundle: Bundle {
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }
}
