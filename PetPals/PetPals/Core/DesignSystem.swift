import SwiftUI

// MARK: - Spacing (4pt base grid — tokens/spacing.css)

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 16
    static let md: CGFloat = 24
    static let lg: CGFloat = 32
    static let xl: CGFloat = 40
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius (soft & generous — tokens/elevation.css)

enum Radius {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let xxl: CGFloat = 36
    static let pill: CGFloat = 999
}

// MARK: - Typography Scale (tokens/typography.css)

enum Typography {
    static let hero: CGFloat = 36       // display-md
    static let title1: CGFloat = 28     // display-sm — screen titles
    static let title2: CGFloat = 24     // title-lg
    static let title3: CGFloat = 20     // title-md
    static let body: CGFloat = 16       // ~body-lg
    static let callout: CGFloat = 15    // body-md
    static let caption: CGFloat = 13    // body-sm / label
    static let micro: CGFloat = 11      // caption
}

// MARK: - Elevation (warm green-tinted shadows, never neutral gray)

enum Elevation {
    case resting
    case raised
    case floating
    case hero

    var shadowColor: Color {
        switch self {
        case .resting: return Theme.shadowInk.opacity(0.06)
        case .raised: return Theme.shadowInk.opacity(0.08)
        case .floating: return Theme.shadowInk.opacity(0.12)
        case .hero: return Theme.shadowInk.opacity(0.16)
        }
    }

    var radius: CGFloat {
        switch self {
        case .resting: return 4
        case .raised: return 12
        case .floating: return 24
        case .hero: return 36
        }
    }

    var y: CGFloat {
        switch self {
        case .resting: return 1
        case .raised: return 5
        case .floating: return 11
        case .hero: return 18
        }
    }
}

// MARK: - Motion (calm and gently springy — --ease-out / --ease-spring)

enum Motion {
    static let spring = Animation.spring(response: 0.34, dampingFraction: 0.72, blendDuration: 0.1)
    static let gentle = Animation.easeInOut(duration: 0.22)
    static let quick = Animation.easeOut(duration: 0.14)
    static let tab = Animation.spring(response: 0.32, dampingFraction: 0.85)
}

// MARK: - Haptics

enum Haptic {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - Screen Layout

enum ScreenLayout {
    /// Mobile gutters — 20px per the design system layout rules.
    static let horizontalPadding: CGFloat = 20
    /// Legacy name — prefer `tabBarScrollInset` with `tabBarScrollInset(keyboard:)`.
    static let tabBarClearance: CGFloat = 108
    /// Space reserved above the bottom tab bar (not applied when keyboard is visible).
    static let tabBarScrollInset: CGFloat = 96
    /// Bottom inset for the AI floating action button so it sits clear above the tab bar + home indicator.
    static let aiFabBottomInset: CGFloat = 104
}

// MARK: - Pet photo frames (4:3 standard crop)

enum PetImageMetrics {
    static let gridAspect: CGFloat = 4 / 3
    static let gridHeight: CGFloat = 140
    static let featuredSize = CGSize(width: 260, height: 195)
    static let detailHeroHeight: CGFloat = 320
    static let profileHeroHeight: CGFloat = 300
    static let listThumbSize = CGSize(width: 64, height: 64)
    static let smallAvatarSize: CGFloat = 50
}
