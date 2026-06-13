import SwiftUI

// MARK: - PetPals Design System primitives
// Swift counterparts of the design-system components (Badge, Tag, Tabs, icon tiles).

// MARK: Badge

enum PPBadgeTone {
    case forest, healthy, warn, critical, info, neutral, coral

    var soft: (background: Color, foreground: Color) {
        switch self {
        case .forest: return (Theme.forestSoft, Theme.forest)
        case .healthy: return (Theme.statusHealthySoft, Color(hex: 0x1F7350))
        case .warn: return (Theme.statusWarnSoft, Color(hex: 0xA36F12))
        case .critical: return (Theme.statusCriticalSoft, Color(hex: 0xB23423))
        case .info: return (Theme.statusInfoSoft, Color(hex: 0x1F6A73))
        case .neutral: return (Theme.sandSoft, Color(hex: 0x41514A))
        case .coral: return (Theme.coralSoft, PetPalsPalette.coral700)
        }
    }

    var solid: (background: Color, foreground: Color) {
        switch self {
        case .forest: return (Theme.forest, .white)
        case .healthy: return (Theme.statusHealthy, .white)
        case .warn: return (Theme.statusWarn, .white)
        case .critical: return (Theme.statusCritical, .white)
        case .info: return (Theme.statusInfo, .white)
        case .neutral: return (PetPalsPalette.ink600, .white)
        case .coral: return (Theme.coral, Theme.onAccent)
        }
    }
}

struct PPBadge: View {
    let text: String
    var tone: PPBadgeTone = .forest
    var solid: Bool = false
    var icon: String? = nil
    var dot: Bool = false

    private var colors: (background: Color, foreground: Color) {
        solid ? tone.solid : tone.soft
    }

    var body: some View {
        HStack(spacing: 5) {
            if dot {
                Circle().fill(colors.foreground).frame(width: 7, height: 7)
            }
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
            }
            Text(text)
        }
        .font(Theme.Fonts.label(12, weight: .bold))
        .foregroundStyle(colors.foreground)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule(style: .continuous).fill(colors.background))
    }
}

// MARK: Tag (sand chip — personality traits, filters)

struct PPTag: View {
    let text: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(text)
        }
        .font(Theme.Fonts.label(Typography.caption, weight: .semibold))
        .foregroundStyle(Theme.textBody)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Capsule(style: .continuous).fill(Theme.surfaceWarm))
    }
}

// MARK: Segmented Tabs (sand track · white active pill)

struct PPSegmentedTabs: View {
    let items: [(value: String, label: String)]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 2) {
            ForEach(items, id: \.value) { item in
                let isActive = selection == item.value
                Button {
                    Haptic.selection()
                    withAnimation(Motion.tab) { selection = item.value }
                } label: {
                    Text(item.label)
                        .font(Theme.Fonts.label(14, weight: .bold))
                        .foregroundStyle(isActive ? Theme.forestDeep : Theme.textSecondary)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background {
                            if isActive {
                                Capsule(style: .continuous)
                                    .fill(Theme.surface)
                                    .shadow(color: Elevation.resting.shadowColor, radius: 3, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Capsule(style: .continuous).fill(Theme.surfaceWarm))
    }
}

// MARK: Icon Tile (tinted rounded square leading icon)

struct PPIconTile: View {
    let icon: String
    var tint: Color = Theme.forest
    var background: Color = Theme.forestSoft
    var size: CGFloat = 40
    var iconSize: CGFloat = 18

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(background)
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
    }
}

// MARK: Circular icon button (outline — matches IconButton "outline" variant)

struct PPIconButton: View {
    let icon: String
    var solid: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            Haptic.light()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(solid ? Color.white : Theme.textPrimary)
                .frame(width: 44, height: 44)
                .background {
                    Circle().fill(solid ? Theme.forest : Theme.surface)
                    if !solid {
                        Circle().stroke(Theme.borderDefault, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(MagneticPressStyle())
    }
}

// MARK: Status glow (the living pet card halo)

extension View {
    /// Soft colored halo that signals health at a glance (--glow-healthy/warn/critical/coral).
    func statusGlow(_ color: Color, cornerRadius: CGFloat = Radius.xl) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(color.opacity(0.20), lineWidth: 4)
                .padding(-2)
        )
    }
}
