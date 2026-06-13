import SwiftUI

// MARK: - Theme facade (reads from `PetPalsPalette` — PetPals Design System tokens)

enum Theme {
    // Brand scales (most-used steps surfaced for convenience)
    static var forest: Color { PetPalsPalette.forest600 }
    static var forestDeep: Color { PetPalsPalette.forest700 }
    static var forestSoft: Color { PetPalsPalette.forest50 }
    static var sand: Color { PetPalsPalette.sand500 }
    static var sandSoft: Color { PetPalsPalette.sand200 }
    static var coral: Color { PetPalsPalette.coral500 }
    static var coralDeep: Color { PetPalsPalette.coral600 }
    static var coralSoft: Color { PetPalsPalette.coral100 }
    static var cream: Color { PetPalsPalette.cream50 }

    // Status roles
    static var statusHealthy: Color { PetPalsPalette.green }
    static var statusHealthySoft: Color { PetPalsPalette.greenSoft }
    static var statusWarn: Color { PetPalsPalette.amber }
    static var statusWarnSoft: Color { PetPalsPalette.amberSoft }
    static var statusCritical: Color { PetPalsPalette.red }
    static var statusCriticalSoft: Color { PetPalsPalette.redSoft }
    static var statusInfo: Color { PetPalsPalette.teal }
    static var statusInfoSoft: Color { PetPalsPalette.tealSoft }

    // Surfaces & borders
    static var surface: Color { PetPalsPalette.cardBackground }
    static var surfaceSunken: Color { PetPalsPalette.surfaceSunken }
    static var surfaceWarm: Color { PetPalsPalette.surfaceWarm }
    static var surfaceInverse: Color { PetPalsPalette.surfaceInverse }
    static var surfaceGlass: Color { PetPalsPalette.surfaceGlass }
    static var borderSubtle: Color { PetPalsPalette.borderSubtle }
    static var borderDefault: Color { PetPalsPalette.borderDefault }
    static var borderStrong: Color { PetPalsPalette.borderStrong }
    static var shadowInk: Color { PetPalsPalette.shadowInk }

    // Legacy swatch names (kept for source compatibility)
    static var honeydew: Color { PetPalsPalette.honeydew }
    static var powderBlush: Color { PetPalsPalette.powderBlush }
    static var almondCream: Color { PetPalsPalette.almondCream }
    static var richCerulean: Color { PetPalsPalette.richCerulean }
    static var navy: Color { PetPalsPalette.navy }
    static var navyDark: Color { PetPalsPalette.navyDark }

    // Primary roles
    static var primarySoft: Color { PetPalsPalette.primarySoft }
    static var primary: Color { PetPalsPalette.primary }
    static var primaryDeep: Color { PetPalsPalette.primaryDeep }

    // Aliases (older + alternate naming)
    static var aliceBlue: Color { honeydew }
    static var thistle: Color { powderBlush }
    static var pearlAqua: Color { almondCream }
    static var duskBlue: Color { richCerulean }
    static var deepNavy: Color { navy }
    static var vanillaIce: Color { honeydew }
    static var wildStrawberry: Color { powderBlush }
    static var darkRaspberry: Color { navy }
    static var blackRussian: Color { navy }
    static var amour: Color { almondCream }

    // Semantic
    static var accent: Color { PetPalsPalette.accent }
    static var accentSoft: Color { PetPalsPalette.accentSoft }
    static var onAccent: Color { PetPalsPalette.onAccent }
    static var brandDeep: Color { PetPalsPalette.brandDeep }
    static var brandDark: Color { PetPalsPalette.brandDark }
    static var brandWarm: Color { PetPalsPalette.brandWarm }
    static var secondary: Color { PetPalsPalette.secondary }
    static var background: Color { PetPalsPalette.background }
    static var darkBackgroundGradient: LinearGradient { PetPalsPalette.darkBackgroundGradient }
    static var cardBackground: Color { PetPalsPalette.cardBackground }
    static var textPrimary: Color { PetPalsPalette.textPrimary }
    static var textBody: Color { PetPalsPalette.textBody }
    static var textSecondary: Color { PetPalsPalette.textSecondary }
    static var textFaint: Color { PetPalsPalette.textFaint }
    static var textOnBrand: Color { PetPalsPalette.textOnBrand }
    static var textOnDark: Color { PetPalsPalette.textOnDark }

    static var brandGradient: LinearGradient { PetPalsPalette.brandGradient }
    static var heroGradient: LinearGradient { PetPalsPalette.heroGradient }
    static var meshGradient: AngularGradient { PetPalsPalette.meshGradient }
    static var glassStroke: LinearGradient { PetPalsPalette.glassStroke }

    enum Fonts {
        /// Display — Bricolage Grotesque, characterful humanist headers (set tight via `.tracking` at call sites).
        static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
            .custom(PetPalsFonts.display, fixedSize: size).weight(weight)
        }

        /// UI headings — Nunito (rounded, warm, approachable).
        static func headline(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
            .custom(PetPalsFonts.ui, fixedSize: size).weight(weight)
        }

        /// Body copy — Nunito.
        static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .custom(PetPalsFonts.ui, fixedSize: size).weight(weight)
        }

        /// Labels, badges, chips — Nunito.
        static func label(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
            .custom(PetPalsFonts.ui, fixedSize: size).weight(weight)
        }

        /// Live data readouts — collar bpm, GPS, IDs (JetBrains Mono).
        static func mono(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
            .custom(PetPalsFonts.mono, fixedSize: size).weight(weight)
        }

        static func primaryFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            body(size, weight: weight)
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self = PetPalsPalette.color(hex, alpha: alpha)
    }
}

extension ShapeStyle where Self == Color {
    static var themePrimary: Color { Theme.primary }
    static var themeSecondary: Color { Theme.secondary }
    static var themeBackground: Color { Theme.background }
    static var themeAccent: Color { Theme.accent }
}
