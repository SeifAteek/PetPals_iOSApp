import SwiftUI
import CoreText

// MARK: - PetPals Design System fonts
// Bundles + registers the brand typefaces at launch so `Theme.Fonts` can use them.
// Display = Bricolage Grotesque · UI/body = Nunito · Data = JetBrains Mono
// (tokens/fonts.css). Fonts are registered at runtime via CoreText, so no
// Info.plist UIAppFonts entry is required.

enum PetPalsFonts {
    /// Family names as reported by the font name tables (preferred/typographic family).
    static let display = "Bricolage Grotesque"
    static let ui = "Nunito"
    static let mono = "JetBrains Mono"

    private static let fileNames = [
        "BricolageGrotesque-Medium",
        "BricolageGrotesque-Bold",
        "BricolageGrotesque-ExtraBold",
        "Nunito-Regular",
        "Nunito-Medium",
        "Nunito-SemiBold",
        "Nunito-Bold",
        "Nunito-ExtraBold",
        "JetBrainsMono-Bold"
    ]

    private static var didRegister = false

    /// Registers every bundled .ttf with the process font manager. Idempotent.
    static func register() {
        guard !didRegister else { return }
        didRegister = true

        for name in fileNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                #if DEBUG
                print("[PetPalsFonts] Missing bundled font: \(name).ttf")
                #endif
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                #if DEBUG
                print("[PetPalsFonts] Could not register \(name): \(String(describing: error?.takeUnretainedValue()))")
                #endif
                error?.release()
            }
        }
    }
}
