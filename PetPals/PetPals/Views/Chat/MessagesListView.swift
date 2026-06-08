import SwiftUI

struct MessagesListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.isLoading {
                PremiumLoadingView()
                    .padding(.top, Spacing.xl)
            } else if viewModel.chatThreads.isEmpty {
                PremiumEmptyState(
                    icon: "message.fill",
                    title: L10n.inboxQuiet,
                    message: L10n.inboxQuietDesc
                )
            } else {
                LazyVStack(spacing: Spacing.sm) {
                    ForEach(viewModel.chatThreads) { thread in
                        MessageThreadRow(thread: thread) {
                            coordinator.push(.chatRoom(
                                clinicId: thread.clinicId,
                                shelterId: thread.shelterId,
                                displayName: thread.partnerName
                            ))
                        }
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
                .padding(.vertical, Spacing.sm)
            }
        }
        .padding(.bottom, ScreenLayout.tabBarScrollInset)
        .petPalsScreenBackground()
        .navigationTitle(L10n.messages)
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.loadThreads() }
        .onReceive(NotificationCenter.default.publisher(for: .petPalsChatDidClose)) { _ in
            viewModel.loadThreads()
        }
    }
}

struct MessageThreadRow: View {
    let thread: ChatThreadSummary
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                threadAvatar
                VStack(alignment: .leading, spacing: 4) {
                    Text(thread.partnerName)
                        .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(thread.previewText)
                        .font(Theme.Fonts.body(Typography.caption))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
                if let date = thread.createdAt {
                    Text(date, style: .time)
                        .font(Theme.Fonts.label(Typography.micro))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(Spacing.sm)
            .glassCard(cornerRadius: Radius.md, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }

    @ViewBuilder
    private var threadAvatar: some View {
        Group {
            if let url = ImageURL.from(thread.partnerLogoURL) {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        defaultIcon
                    }
                }
            } else {
                defaultIcon
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
    }

    private var defaultIcon: some View {
        ZStack {
            Circle().fill(Theme.primary.opacity(0.14))
            Image(systemName: thread.clinicId != nil ? "cross.case.fill" : "house.fill")
                .foregroundStyle(Theme.primary)
        }
    }
}

#Preview {
    NavigationStack {
        MessagesListView()
            .environmentObject(AppCoordinator())
    }
}
