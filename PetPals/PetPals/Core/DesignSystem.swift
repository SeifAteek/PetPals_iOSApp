import SwiftUI

// MARK: - 8pt Spacing Grid

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

// MARK: - Corner Radius

enum Radius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 20
    static let lg: CGFloat = 28
    static let xl: CGFloat = 36
    static let pill: CGFloat = 999
}

// MARK: - Typography Scale

enum Typography {
    static let hero: CGFloat = 40
    static let title1: CGFloat = 32
    static let title2: CGFloat = 24
    static let title3: CGFloat = 20
    static let body: CGFloat = 16
    static let callout: CGFloat = 15
    static let caption: CGFloat = 13
    static let micro: CGFloat = 11
}

// MARK: - Elevation

enum Elevation {
    case resting
    case raised
    case floating
    case hero

    var shadowColor: Color {
        Theme.brandDark.opacity(level == .hero ? 0.28 : 0.12)
    }

    var radius: CGFloat {
        switch self {
        case .resting: return 8
        case .raised: return 16
        case .floating: return 24
        case .hero: return 32
        }
    }

    var y: CGFloat {
        switch self {
        case .resting: return 2
        case .raised: return 6
        case .floating: return 12
        case .hero: return 18
        }
    }

    private var level: Elevation { self }
}

// MARK: - Motion

enum Motion {
    static let spring = Animation.spring(response: 0.42, dampingFraction: 0.82, blendDuration: 0.1)
    static let gentle = Animation.easeInOut(duration: 0.35)
    static let quick = Animation.easeOut(duration: 0.22)
    static let tab = Animation.spring(response: 0.38, dampingFraction: 0.88)
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
    static let horizontalPadding: CGFloat = Spacing.md
    /// Legacy name — prefer `tabBarScrollInset` with `tabBarScrollInset(keyboard:)`.
    static let tabBarClearance: CGFloat = 108
    /// Space reserved above the floating tab bar (not applied when keyboard is visible).
    static let tabBarScrollInset: CGFloat = 88
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
