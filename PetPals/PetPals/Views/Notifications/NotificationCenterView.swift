import SwiftUI

/// In-app notification center — mirrors the device notification center and groups by category
/// (messages, reminders, shopping, clinic, app alerts). Tapping a row deep-links into the app.
struct NotificationCenterView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject private var store = LocalNotificationManager.shared

    /// Categories that currently have at least one notification, in display order.
    private var activeCategories: [AppNotificationCategory] {
        AppNotificationCategory.allCases.filter { !store.notifications(in: $0).isEmpty }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            if store.notifications.isEmpty {
                PremiumEmptyState(
                    icon: "bell",
                    title: "All caught up",
                    message: "No notifications right now. We'll let you know about reminders, messages, orders and clinic visits."
                )
                .padding(.top, Spacing.xl)
            } else {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    ForEach(activeCategories) { category in
                        categorySection(category)
                    }
                }
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .petPalsScreenBackground()
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if store.unreadCount > 0 {
                    Button("Mark all read") { store.markAllRead() }
                        .font(Theme.Fonts.label(Typography.caption, weight: .heavy))
                        .foregroundStyle(PetPalsPalette.forest500)
                }
            }
        }
        .onAppear { Haptic.selection() }
    }

    @ViewBuilder
    private func categorySection(_ category: AppNotificationCategory) -> some View {
        let items = store.notifications(in: category)
        let unread = items.filter { !$0.isRead }.count
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(category.accent)
                Text(category.title)
                    .font(Theme.Fonts.display(Typography.title3))
                    .tracking(-0.3)
                    .foregroundStyle(Theme.textPrimary)
                if unread > 0 {
                    PPBadge(text: "\(unread)", tone: category.tone, solid: true)
                }
                Spacer()
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)

            VStack(spacing: Spacing.xs) {
                ForEach(items) { item in
                    NotificationRow(item: item) { tapped(item) }
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)
        }
    }

    private func tapped(_ item: AppNotification) {
        Haptic.light()
        store.markRead(item.id)
        if let route = item.route {
            store.handle(route: route, coordinator: coordinator)
        }
    }
}

// MARK: - Badged bell button (notification icon with unread counter)

struct NotificationBellButton: View {
    @ObservedObject private var store = LocalNotificationManager.shared
    let action: () -> Void

    var body: some View {
        PPIconButton(icon: "bell", action: action)
            .overlay(alignment: .topTrailing) {
                if store.unreadCount > 0 {
                    Text(store.unreadCount > 99 ? "99+" : "\(store.unreadCount)")
                        .font(Theme.Fonts.label(Typography.micro, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, store.unreadCount > 9 ? 5 : 0)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(Capsule().fill(Theme.coral))
                        .overlay(Capsule().stroke(Theme.background, lineWidth: 2))
                        .offset(x: 4, y: -4)
                        .transition(.scale.combined(with: .opacity))
                        .accessibilityLabel("\(store.unreadCount) unread notifications")
                }
            }
            .animation(Motion.spring, value: store.unreadCount)
    }
}

// MARK: - Row

private struct NotificationRow: View {
    let item: AppNotification
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                PPIconTile(
                    icon: item.category.icon,
                    tint: item.category.accent,
                    background: item.category.accentSoft,
                    size: 42
                )
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(item.title)
                            .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                        Text(item.date.formatted(.relative(presentation: .numeric)))
                            .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                            .foregroundStyle(Theme.textFaint)
                    }
                    Text(item.body)
                        .font(Theme.Fonts.body(Typography.caption))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !item.isRead {
                    Circle()
                        .fill(Theme.coral)
                        .frame(width: 9, height: 9)
                        .padding(.top, 5)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: Radius.lg, elevation: .resting)
            .opacity(item.isRead ? 0.78 : 1)
        }
        .buttonStyle(MagneticPressStyle())
    }
}
