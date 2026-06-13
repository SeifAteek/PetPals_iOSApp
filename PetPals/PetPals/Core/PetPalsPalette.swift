import SwiftUI

// MARK: - PetPals Design System palette
// Source of truth: design-system tokens/colors.css + tokens/semantic.css
// Deep forest green (primary) · warm sand (secondary) · soft coral (accent) · warm near-white canvas.
// Neutrals are green-tinted ink so even text feels part of the family.

// MARK: - Mesh orb (legacy type — ambient mesh backgrounds were retired by the design system)

struct MeshOrb: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let blur: CGFloat
    let offset: CGSize
    let darkOpacity: Double
    let lightOpacity: Double

    func opacity(for scheme: ColorScheme) -> Double {
        scheme == .dark ? darkOpacity : lightOpacity
    }
}

enum PetPalsPalette {

    // MARK: Forest green (primary brand)

    static let forest950 = color(0x0E2219)
    static let forest900 = color(0x12291F)
    static let forest800 = color(0x173A2C)
    static let forest700 = color(0x1C4534)
    static let forest600 = color(0x234E3F)   // PRIMARY
    static let forest500 = color(0x2E6651)
    static let forest400 = color(0x4C8670)
    static let forest300 = color(0x7CAB97)
    static let forest200 = color(0xB4D0C2)
    static let forest100 = color(0xDCEAE2)
    static let forest50  = color(0xEEF5F0)

    // MARK: Warm sand (secondary / warm neutral)

    static let sand700 = color(0xB9A57E)
    static let sand600 = color(0xCFBC93)
    static let sand500 = color(0xE0CFA8)     // signature sand
    static let sand400 = color(0xE8DABA)
    static let sand300 = color(0xECE0C6)
    static let sand200 = color(0xF2EAD7)
    static let sand100 = color(0xF7F1E4)

    // MARK: Soft coral (accent / energy / heartbeat)

    static let coral700 = color(0xC9543A)
    static let coral600 = color(0xE1654A)
    static let coral500 = color(0xF2876B)    // ACCENT
    static let coral400 = color(0xF6A48E)
    static let coral300 = color(0xF9C2B2)
    static let coral200 = color(0xFBD9CF)
    static let coral100 = color(0xFDEBE4)

    // MARK: Warm near-white canvas

    static let cream50 = color(0xFBF8F2)

    // MARK: Ink (green-tinted neutrals for text)

    static let ink900 = color(0x14201B)
    static let ink800 = color(0x21302A)
    static let ink700 = color(0x2C3A33)
    static let ink600 = color(0x41514A)
    static let ink500 = color(0x51635A)
    static let ink400 = color(0x6E7E75)
    static let ink300 = color(0x98A69D)
    static let ink200 = color(0xC5CFC9)
    static let ink100 = color(0xE5EAE6)

    // MARK: Status

    static let green     = color(0x2E9E6B)   // success / healthy
    static let greenSoft = color(0xDCF0E5)
    static let amber     = color(0xE0A23B)   // warning / due soon
    static let amberSoft = color(0xFBEBCF)
    static let red       = color(0xDA4A38)   // danger / overdue / critical
    static let redSoft   = color(0xFBE0DB)
    static let teal      = color(0x2F8C97)   // info / live data
    static let tealSoft  = color(0xD7EDEF)

    // MARK: Semantic — surfaces

    /// Warm near-white canvas (dark: deep forest ink).
    static var background: Color {
        adaptive(light: cream50, dark: forest950)
    }

    /// Card / surface color — solid white on cream (dark: raised forest ink).
    static var cardBackground: Color {
        adaptive(light: .white, dark: color(0x16291F))
    }

    /// Sunken / recessed surface (sand-tinted).
    static var surfaceSunken: Color {
        adaptive(light: sand100, dark: forest900)
    }

    /// Warm sand panel surface.
    static var surfaceWarm: Color {
        adaptive(light: sand200, dark: forest800)
    }

    /// Inverse (forest) surface for the dark hero/collar cards.
    static var surfaceInverse: Color {
        adaptive(light: forest700, dark: forest800)
    }

    /// Glass top bars / tab bar — 72% cream + blur.
    static var surfaceGlass: Color {
        adaptive(light: cream50.opacity(0.72), dark: forest950.opacity(0.72))
    }

    // MARK: Semantic — brand roles

    static var primary: Color { adaptive(light: forest600, dark: forest300) }
    static var primaryHover: Color { forest700 }
    static var primaryPress: Color { forest800 }
    static var primarySoft: Color { adaptive(light: forest50, dark: forest800) }
    static var primaryDeep: Color { adaptive(light: forest800, dark: forest200) }

    static var accent: Color { coral500 }
    static var accentSoft: Color { adaptive(light: coral100, dark: color(0x3A2018)) }
    /// Dark warm text used on coral fills.
    static let onAccent = color(0x3A140B)

    static var brandDeep: Color { adaptive(light: forest700, dark: forest200) }
    static var brandDark: Color { ink900 }
    static var brandWarm: Color { sand500 }

    static var secondary: Color {
        adaptive(light: sand200, dark: forest800)
    }

    static var surfaceLight: Color { cream50 }

    // MARK: Semantic — text

    static var textPrimary: Color {
        adaptive(light: ink900, dark: color(0xEAF1EC))
    }

    static var textBody: Color {
        adaptive(light: ink700, dark: ink200)
    }

    static var textSecondary: Color {
        adaptive(light: ink500, dark: ink300)
    }

    static var textFaint: Color {
        adaptive(light: ink400, dark: ink400)
    }

    static let textOnBrand = Color.white
    static let textOnDark = color(0xEAF1EC)

    // MARK: Semantic — borders

    static var borderSubtle: Color {
        adaptive(light: color(0xECE5D6), dark: Color.white.opacity(0.10))
    }

    static var borderDefault: Color {
        adaptive(light: color(0xE1D9C6), dark: Color.white.opacity(0.14))
    }

    static var borderStrong: Color {
        adaptive(light: forest200, dark: forest400)
    }

    /// Warm green-tinted shadow ink — never neutral gray.
    static let shadowInk = color(0x14201B)

    // MARK: Legacy swatch aliases (older views reference these names)

    static var honeydew: Color { cream50 }
    static var powderBlush: Color { coral500 }
    static var almondCream: Color { sand500 }
    static var richCerulean: Color { teal }
    static var navy: Color { forest700 }
    static var navyDark: Color { forest950 }

    // MARK: Legacy gradients — flattened per the design system ("no busy gradients")

    /// Solid forest fill (kept as a gradient type for source compatibility).
    static var brandGradient: LinearGradient {
        LinearGradient(colors: [forest600, forest600], startPoint: .top, endPoint: .bottom)
    }

    /// Quiet forest sweep for hero/inverse surfaces.
    static var heroGradient: LinearGradient {
        LinearGradient(colors: [forest600, forest700], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Dark-mode screen base.
    static var darkBackgroundGradient: LinearGradient {
        LinearGradient(colors: [forest950, forest950], startPoint: .top, endPoint: .bottom)
    }

    /// Subtle sand wash (replaces the old angular mesh).
    static var meshGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: meshGradientStops),
            center: .center,
            startAngle: .degrees(-45),
            endAngle: .degrees(315)
        )
    }

    static var meshGradientStops: [Color] {
        [sand200, cream50, sand100, cream50, sand200]
    }

    /// Hairline sand-tinted border (replaces the old glass stroke).
    static var glassStroke: LinearGradient {
        LinearGradient(colors: [borderSubtle, borderSubtle], startPoint: .top, endPoint: .bottom)
    }

    /// Ambient mesh orbs were retired — the canvas stays flat and warm.
    static func meshOrbs(colorScheme: ColorScheme) -> [MeshOrb] { [] }

    // MARK: Helpers

    static func color(_ hex: UInt, alpha: Double = 1) -> Color {
        Color(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    private static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    static func blend(hex a: UInt, with b: UInt, amount: Double) -> Color {
        let t = min(1, max(0, amount))
        let ar = Double((a >> 16) & 0xFF)
        let ag = Double((a >> 8) & 0xFF)
        let ab = Double(a & 0xFF)
        let br = Double((b >> 16) & 0xFF)
        let bg = Double((b >> 8) & 0xFF)
        let bb = Double(b & 0xFF)
        return Color(
            red: (ar * (1 - t) + br * t) / 255,
            green: (ag * (1 - t) + bg * t) / 255,
            blue: (ab * (1 - t) + bb * t) / 255
        )
    }
}
