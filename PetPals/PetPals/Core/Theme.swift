import SwiftUI

// MARK: - Theme facade (reads from `PetPalsPalette` — change palette in PetPalsPalette.swift)

enum Theme {
    // Swatches
    static var honeydew: Color { PetPalsPalette.honeydew }
    static var powderBlush: Color { PetPalsPalette.powderBlush }
    static var almondCream: Color { PetPalsPalette.almondCream }
    static var richCerulean: Color { PetPalsPalette.richCerulean }
    static var navy: Color { PetPalsPalette.navy }
    static var navyDark: Color { PetPalsPalette.navyDark }

    // Primary duo
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
    static var brandDeep: Color { PetPalsPalette.brandDeep }
    static var brandDark: Color { PetPalsPalette.brandDark }
    static var brandWarm: Color { PetPalsPalette.brandWarm }
    static var secondary: Color { PetPalsPalette.secondary }
    static var background: Color { PetPalsPalette.background }
    static var darkBackgroundGradient: LinearGradient { PetPalsPalette.darkBackgroundGradient }
    static var cardBackground: Color { PetPalsPalette.cardBackground }
    static var textPrimary: Color { PetPalsPalette.textPrimary }
    static var textSecondary: Color { PetPalsPalette.textSecondary }
    static var textOnBrand: Color { PetPalsPalette.textOnBrand }

    static var brandGradient: LinearGradient { PetPalsPalette.brandGradient }
    static var heroGradient: LinearGradient { PetPalsPalette.heroGradient }
    static var meshGradient: AngularGradient { PetPalsPalette.meshGradient }
    static var glassStroke: LinearGradient { PetPalsPalette.glassStroke }

    enum Fonts {
        static func display(_ size: CGFloat) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }

        static func headline(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
            .system(size: size, weight: weight, design: .rounded)
        }

        static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .default)
        }

        static func label(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
            .system(size: size, weight: weight, design: .default)
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
