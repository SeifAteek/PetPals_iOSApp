import SwiftUI

// MARK: - Premium Tab Bar

enum PremiumTab: Int, CaseIterable {
    case home, discover, community, care, you

    var title: String {
        switch self {
        case .home: return L10n.tabHome
        case .discover: return L10n.tabDiscover
        case .community: return L10n.tabCommunity
        case .care: return L10n.tabCare
        case .you: return L10n.tabYou
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .discover: return "sparkles"
        case .community: return "text.bubble.fill"
        case .care: return "heart.text.square.fill"
        case .you: return "person.crop.circle.fill"
        }
    }
}

struct PremiumTabBar: View {
    @Binding var selected: PremiumTab
    var onAITap: () -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(PremiumTab.allCases, id: \.rawValue) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    Capsule(style: .continuous)
                        .fill(Theme.cardBackground)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Theme.glassStroke, lineWidth: 1)
                )
                .shadow(color: Elevation.floating.shadowColor, radius: Elevation.floating.radius, y: Elevation.floating.y)
        }
        .overlay(alignment: .topTrailing) {
            Button(action: {
                Haptic.light()
                onAITap()
            }) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(Theme.brandGradient)
                            .shadow(color: Theme.primary.opacity(0.45), radius: 12, y: 6)
                    }
            }
            .buttonStyle(MagneticPressStyle())
            .offset(x: 8, y: -52)
        }
    }

    @ViewBuilder
    private func tabButton(_ tab: PremiumTab) -> some View {
        let isSelected = selected == tab
        Button {
            Haptic.selection()
            withAnimation(Motion.tab) { selected = tab }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .symbolEffect(.bounce, value: isSelected)
                Text(tab.title)
                    .font(Theme.Fonts.label(Typography.micro, weight: isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? Theme.primary : Theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(Theme.primary.opacity(0.14))
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Screen Chrome

struct PremiumScreenHeader: View {
    let eyebrow: String?
    let title: String
    var subtitle: String? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(1.2)
                }
                Text(title)
                    .font(Theme.Fonts.display(Typography.title1))
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle {
                    Text(subtitle)
                        .font(Theme.Fonts.body(Typography.callout))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Spacer(minLength: Spacing.sm)
            if let trailing { trailing }
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }
}

struct PremiumSearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.textSecondary)
            TextField(placeholder, text: $text)
                .font(Theme.Fonts.body(Typography.callout))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 14)
        .glassCard(cornerRadius: Radius.md, elevation: .resting)
    }
}

struct PremiumSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Fonts.headline(Typography.title3, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Theme.Fonts.label(Typography.caption, weight: .semibold))
                        .foregroundStyle(Theme.primary)
                }
            }
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }
}

// MARK: - Category Chip

struct PremiumChip: View {
    let title: String
    var icon: String? = nil
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptic.selection()
            action()
        }) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(title)
                    .font(Theme.Fonts.label(Typography.caption, weight: .semibold))
            }
            .foregroundStyle(isSelected ? Theme.textOnBrand : Theme.textPrimary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 10)
            .background {
                Capsule(style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(Theme.brandGradient) : AnyShapeStyle(Theme.cardBackground))
                    .overlay {
                        if !isSelected {
                            Capsule(style: .continuous)
                                .stroke(Theme.glassStroke, lineWidth: 1)
                        }
                    }
            }
        }
        .buttonStyle(MagneticPressStyle())
    }
}

// MARK: - Empty State

struct PremiumEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var ctaTitle: String? = nil
    var ctaAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Theme.primary)
            }
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(Theme.Fonts.headline(Typography.title3, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(message)
                    .font(Theme.Fonts.body(Typography.callout))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            if let ctaTitle, let ctaAction {
                PrimaryButton(title: ctaTitle, action: ctaAction)
                    .padding(.horizontal, Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }
}

// MARK: - Service Tile

struct PremiumServiceTile: View {
    let title: String
    let icon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptic.light()
            action()
        }) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(tint.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.sm)
            .glassCard(cornerRadius: Radius.md, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }
}

// MARK: - Hub Row

struct PremiumHubRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptic.light()
            action()
        }) {
            HStack(spacing: Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(Theme.primary.opacity(0.14))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.Fonts.headline(Typography.body, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(Theme.Fonts.body(Typography.caption))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer()
                if let badge {
                    Text(badge)
                        .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                        .foregroundStyle(Theme.textOnBrand)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Theme.primary))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.6))
            }
            .padding(Spacing.sm)
            .glassCard(cornerRadius: Radius.md, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }
}
