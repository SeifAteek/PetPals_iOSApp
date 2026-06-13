import SwiftUI

struct CommunityFeedView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = CommunityFeedViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                PremiumScreenHeader(
                    eyebrow: L10n.societyEyebrow,
                    title: L10n.communityTitle,
                    subtitle: L10n.communitySubtitle,
                    trailing: AnyView(
                        PPIconButton(icon: "square.and.pencil", solid: true) {
                            coordinator.push(.createCommunityPost(subredditId: viewModel.selectedSubredditId))
                        }
                    )
                )

                subredditFilters

                if viewModel.isLoading && viewModel.posts.isEmpty {
                    PremiumLoadingView(message: L10n.loading)
                        .padding(.top, Spacing.xl)
                } else if viewModel.posts.isEmpty {
                    PremiumEmptyState(
                        icon: "text.bubble.fill",
                        title: L10n.communityNoPosts,
                        message: L10n.communityNoPostsDesc
                    )
                } else {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(viewModel.posts) { post in
                            CommunityPostCard(
                                post: post,
                                onUpvote: { viewModel.vote(on: post, direction: 1) },
                                onDownvote: { viewModel.vote(on: post, direction: -1) },
                                onTap: { coordinator.push(.communityPostDetail(postId: post.postId)) }
                            )
                        }
                    }
                    .padding(.horizontal, ScreenLayout.horizontalPadding)
                }

                if let err = viewModel.errorMessage {
                    Text(err)
                        .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                        .foregroundStyle(Theme.statusCritical)
                        .padding(.horizontal, ScreenLayout.horizontalPadding)
                }
            }
            .padding(.top, Spacing.sm)
            .padding(.bottom, ScreenLayout.tabBarScrollInset)
        }
        .dismissKeyboardOnSwipe()
        .petPalsScreenBackground()
        .onAppear { viewModel.load() }
        .refreshable { viewModel.load() }
    }

    private var subredditFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                PremiumChip(
                    title: L10n.all,
                    icon: "line.3.horizontal.decrease.circle",
                    isSelected: viewModel.selectedSubredditId == nil
                ) {
                    viewModel.selectSubreddit(nil)
                }
                ForEach(viewModel.subreddits) { sub in
                    PremiumChip(
                        title: sub.name,
                        icon: sub.iconName,
                        isSelected: viewModel.selectedSubredditId == sub.subredditId
                    ) {
                        viewModel.selectSubreddit(sub.subredditId)
                    }
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)
        }
    }
}

#Preview {
    CommunityFeedView()
        .environmentObject(AppCoordinator())
}
