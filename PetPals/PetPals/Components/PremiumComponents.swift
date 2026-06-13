import SwiftUI

// MARK: - Bottom Tab Bar (glass cream bar · forest active · coral AI fab)

enum PremiumTab: Int, CaseIterable {
    case home, discover, community, care, you, collar

    var title: String {
        switch self {
        case .home: return L10n.tabHome
        case .discover: return L10n.tabDiscover
        case .community: return L10n.tabCommunity
        case .care: return L10n.tabCare
        case .you: return L10n.tabYou
        case .collar: return "Collar"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .discover: return "heart.fill"
        case .community: return "text.bubble.fill"
        case .care: return "stethoscope"
        case .you: return "person.crop.circle.fill"
        case .collar: return "antenna.radiowaves.left.and.right"
        }
    }
}

struct PremiumTabBar: View {
    @Binding var selected: PremiumTab
    /// Tabs to render — lets the host show/hide the conditional Collar tab.
    var tabs: [PremiumTab] = [.home, .discover, .community, .care, .you]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.rawValue) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
        .background {
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(Theme.surfaceGlass)
            }
            .overlay(alignment: .top) {
                Rectangle().fill(Theme.borderSubtle).frame(height: 1)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    @ViewBuilder
    private func tabButton(_ tab: PremiumTab) -> some View {
        let isSelected = selected == tab
        Button {
            Haptic.selection()
            withAnimation(Motion.tab) { selected = tab }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 21, weight: .semibold))
                    .symbolEffect(.bounce, value: isSelected)
                Text(tab.title)
                    .font(Theme.Fonts.label(10, weight: .heavy))
            }
            .foregroundStyle(isSelected ? Theme.primary : PetPalsPalette.ink300)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - AI Floating Action Button (right side, above the tab bar)

struct AIFloatingButton: View {
    var action: () -> Void

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            Haptic.medium()
            action()
        } label: {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background {
                    Circle()
                        .fill(Theme.coral)
                        .shadow(color: Theme.coral.opacity(0.5), radius: 14, y: 7)
                }
        }
        .buttonStyle(MagneticPressStyle())
        .scaleEffect(appeared || reduceMotion ? 1 : 0.5)
        .opacity(appeared || reduceMotion ? 1 : 0)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(Motion.spring.delay(0.2)) { appeared = true }
        }
        .accessibilityLabel("Ask PetPals AI")
    }
}

// MARK: - Screen Chrome

struct PremiumScreenHeader: View {
    let eyebrow: String?
    let title: String
    var subtitle: String? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                        .foregroundStyle(Theme.textFaint)
                        .tracking(1.0)
                }
                Text(title)
                    .font(Theme.Fonts.display(26))
                    .tracking(-0.5)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle {
                    Text(subtitle)
                        .font(Theme.Fonts.body(Typography.caption, weight: .bold))
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
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.textFaint)
            TextField(placeholder, text: $text)
                .font(Theme.Fonts.body(Typography.callout))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, 16)
        .frame(height: 46)
        .background {
            Capsule(style: .continuous).fill(Theme.surface)
        }
        .overlay {
            Capsule(style: .continuous).stroke(Theme.borderDefault, lineWidth: 1.5)
        }
    }
}

struct PremiumSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(Theme.Fonts.display(Typography.title3 + 1))
                .tracking(-0.4)
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Theme.Fonts.label(Typography.caption, weight: .heavy))
                        .foregroundStyle(PetPalsPalette.forest500)
                }
            }
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }
}

// MARK: - Category Chip (Tag — sand chip, forest when selected)

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
            .foregroundStyle(isSelected ? Color.white : Theme.textBody)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background {
                Capsule(style: .continuous)
                    .fill(isSelected ? Theme.forest : Theme.surfaceWarm)
            }
        }
        .buttonStyle(MagneticPressStyle())
    }
}

// MARK: - Empty State (encouraging, never a dead-end)

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
                    .fill(Theme.forestSoft)
                    .frame(width: 88, height: 88)
                Image(systemName: icon)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(Theme.forest)
            }
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(Theme.Fonts.display(Typography.title3))
                    .tracking(-0.3)
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

// MARK: - Quick Action Tile (white card · tinted icon tile · two lines)

struct PremiumServiceTile: View {
    let title: String
    var subtitle: String? = nil
    let icon: String
    let tint: Color
    var tileBackground: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptic.light()
            action()
        }) {
            HStack(spacing: 12) {
                PPIconTile(
                    icon: icon,
                    tint: tint,
                    background: tileBackground ?? tint.opacity(0.12)
                )
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(Theme.Fonts.headline(14, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.leading)
                    if let subtitle {
                        Text(subtitle)
                            .font(Theme.Fonts.body(Typography.micro, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: Radius.lg, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }
}

// MARK: - Hub Row (list row card)

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
            HStack(spacing: 12) {
                PPIconTile(icon: icon, tint: Theme.forest, background: Theme.forestSoft, size: 42)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.Fonts.headline(14, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer()
                if let badge {
                    PPBadge(text: badge, tone: .coral, solid: true)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textFaint)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .glassCard(cornerRadius: Radius.lg, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }
}
