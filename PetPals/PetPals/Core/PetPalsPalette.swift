import SwiftUI

// MARK: - Palette tokens (edit hex values or switch `active` to retheme)

struct PaletteTokens: Sendable, Equatable {
    let honeydew: UInt
    let powderBlush: UInt
    let almondCream: UInt
    let richCerulean: UInt
    let navy: UInt
    /// Dark-mode background anchor — deeper, cooler blue than `navy`.
    let navyDark: UInt

    /// Honeydew · Powder Blush · Almond Cream · Rich Cerulean · Navy
    static let classic = PaletteTokens(
        honeydew: 0xF2FFE9,
        powderBlush: 0xF2A4A5,
        almondCream: 0xE5D4C5,
        richCerulean: 0x3078A4,
        navy: 0x090087,
        navyDark: 0x010A2E
    )

    /// Alternate preset (Alice Blue · Thistle · Pearl Aqua · Dusk Blue · Deep Navy)
    static let nynae = PaletteTokens(
        honeydew: 0xDAE8FB,
        powderBlush: 0xF2D2FF,
        almondCream: 0x75CBD1,
        richCerulean: 0x3E5BA3,
        navy: 0x0C0D45,
        navyDark: 0x030818
    )
}

// MARK: - Mesh orb (photo-style ambient blobs)

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

// MARK: - Active palette

enum PetPalsPalette {
    /// **Single switch:** change this to `.nynae` or another preset.
    static var active: PaletteTokens = .classic

    // MARK: Swatches

    static var honeydew: Color { color(active.honeydew) }
    static var powderBlush: Color { color(active.powderBlush) }
    static var almondCream: Color { color(active.almondCream) }
    static var richCerulean: Color { color(active.richCerulean) }
    static var navy: Color { color(active.navy) }
    static var navyDark: Color { color(active.navyDark) }

    // MARK: Primary duo — Powder Blush · Navy

    static var primarySoft: Color { powderBlush }
    static var primary: Color { powderBlush }
    static var primaryDeep: Color { navy }

    // MARK: Supporting

    static var accent: Color { richCerulean }
    static var surfaceLight: Color { honeydew }

    // MARK: Semantic UI

    static var brandDeep: Color { navy }
    static var brandDark: Color { navy }
    static var brandWarm: Color { almondCream }

    static var secondary: Color {
        adaptive(
            light: blend(hex: active.almondCream, with: active.honeydew, amount: 0.4).opacity(0.65),
            dark: blend(hex: active.powderBlush, with: active.navy, amount: 0.25).opacity(0.5)
        )
    }

    static var background: Color {
        adaptive(
            light: color(active.honeydew),
            dark: navyDark
        )
    }

    /// Dark mode screen base — deep blue navy → Powder Blush (used by `PetPalsAmbientBackground`).
    static var darkBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                navyDark,
                blend(hex: active.navyDark, with: active.richCerulean, amount: 0.32),
                blend(hex: active.navy, with: active.richCerulean, amount: 0.4),
                blend(hex: active.navy, with: active.powderBlush, amount: 0.52),
                powderBlush.opacity(0.88)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var cardBackground: Color {
        adaptive(
            light: Color.white.opacity(0.78),
            dark: Color.white.opacity(0.08)
        )
    }

    static var textPrimary: Color {
        adaptive(
            light: color(active.navy),
            dark: color(active.honeydew)
        )
    }

    static var textSecondary: Color {
        adaptive(
            light: color(active.richCerulean).opacity(0.78),
            dark: color(active.powderBlush).opacity(0.82)
        )
    }

    static let textOnBrand = Color.white

    /// Main brand sweep (blush → cerulean → navy), like the reference card gradient.
    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [powderBlush, richCerulean.opacity(0.85), navy],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Full five-color mesh sweep for heroes and large surfaces.
    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                powderBlush.opacity(0.9),
                honeydew.opacity(0.95),
                almondCream.opacity(0.85),
                richCerulean.opacity(0.55),
                navy.opacity(0.75)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Angular mesh mimicking the photo background (lavender TL, pink TR, cream center, navy BL, blue BR).
    static var meshGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: meshGradientStops),
            center: .center,
            startAngle: .degrees(-45),
            endAngle: .degrees(315)
        )
    }

    static var meshGradientStops: [Color] {
        [
            blend(hex: active.powderBlush, with: active.richCerulean, amount: 0.35),
            powderBlush.opacity(0.9),
            honeydew,
            almondCream,
            navy.opacity(0.92),
            richCerulean.opacity(0.75),
            blend(hex: active.powderBlush, with: active.honeydew, amount: 0.5)
        ]
    }

    static var glassStroke: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.75),
                powderBlush.opacity(0.5),
                almondCream.opacity(0.35),
                Color.white.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Blurred orbs positioned like the reference photo mesh.
    static func meshOrbs(colorScheme: ColorScheme) -> [MeshOrb] {
        let isDark = colorScheme == .dark
        return [
            MeshOrb(
                color: blend(hex: active.powderBlush, with: active.richCerulean, amount: 0.4),
                size: 340, blur: 88, offset: CGSize(width: -130, height: -200),
                darkOpacity: 0.28, lightOpacity: 0.5
            ),
            MeshOrb(
                color: powderBlush,
                size: 300, blur: 78, offset: CGSize(width: 150, height: -80),
                darkOpacity: 0.22, lightOpacity: 0.45
            ),
            MeshOrb(
                color: blend(hex: active.honeydew, with: active.almondCream, amount: 0.45),
                size: 380, blur: 95, offset: CGSize(width: 20, height: 40),
                darkOpacity: 0.18, lightOpacity: 0.55
            ),
            MeshOrb(
                color: navy,
                size: 320, blur: 85, offset: CGSize(width: -100, height: 340),
                darkOpacity: 0.45, lightOpacity: 0.35
            ),
            MeshOrb(
                color: richCerulean,
                size: 280, blur: 72, offset: CGSize(width: 120, height: 300),
                darkOpacity: 0.3, lightOpacity: 0.38
            )
        ]
    }

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
