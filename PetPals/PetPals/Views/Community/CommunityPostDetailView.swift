import SwiftUI

struct CommunityPostDetailView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: CommunityPostDetailViewModel

    init(postId: UUID) {
        _viewModel = StateObject(wrappedValue: CommunityPostDetailViewModel(postId: postId))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    if viewModel.isLoading && viewModel.post == nil {
                        PremiumLoadingView()
                            .padding(.top, Spacing.xl)
                    } else if let post = viewModel.post {
                        postHeader(post)
                        commentsSection
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.md)
            }

            commentComposer
        }
        .petPalsScreenBackground()
        .navigationTitle(L10n.communityDiscussion)
        .navigationBarTitleDisplayMode(.inline)
        .keyboardDoneToolbar()
        .onAppear { viewModel.load() }
    }

    @ViewBuilder
    private func postHeader(_ post: CommunityPost) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            CommunityVoteControl(
                score: post.score,
                userVote: post.userVote,
                onUp: { viewModel.votePost(direction: 1) },
                onDown: { viewModel.votePost(direction: -1) }
            )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                if let sub = post.subredditName {
                    Text("r/\(sub)")
                        .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                        .foregroundStyle(Theme.primary)
                }
                Text(post.title)
                    .font(Theme.Fonts.display(Typography.title2))
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: 6) {
                    Text(post.authorName ?? L10n.petParentDefault)
                    if let date = post.createdAt {
                        Text("·")
                        Text(date, style: .date)
                    }
                }
                .font(Theme.Fonts.body(Typography.caption))
                .foregroundStyle(Theme.textSecondary)

                if post.imageUrl != nil {
                    CommunityPostImageView(imageUrl: post.imageUrl, cornerRadius: Radius.md, maxHeight: 320)
                        .padding(.top, Spacing.xs)
                }

                if !post.body.isEmpty {
                    Text(post.body)
                        .font(Theme.Fonts.body(Typography.body))
                        .foregroundStyle(Theme.textPrimary)
                        .lineSpacing(4)
                        .padding(.top, Spacing.xs)
                }
            }
        }
        .padding(Spacing.sm)
        .glassCard(cornerRadius: Radius.lg, elevation: .resting)

        PremiumSectionHeader(title: L10n.communityCommentsTitle)
    }

    @ViewBuilder
    private var commentsSection: some View {
        if viewModel.comments.isEmpty {
            Text(L10n.communityNoComments)
                .font(Theme.Fonts.body(Typography.callout))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(spacing: Spacing.sm) {
                ForEach(viewModel.comments) { comment in
                    commentRow(comment)
                }
            }
        }

        if let err = viewModel.errorMessage {
            Text(err)
                .font(Theme.Fonts.body(Typography.caption))
                .foregroundStyle(Theme.statusCritical)
        }
    }

    private func commentRow(_ comment: CommunityComment) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            CommunityVoteControl(
                score: comment.score,
                userVote: comment.userVote,
                axis: .vertical,
                onUp: { viewModel.voteComment(comment, direction: 1) },
                onDown: { viewModel.voteComment(comment, direction: -1) }
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.authorName ?? L10n.petParentDefault)
                        .font(Theme.Fonts.headline(Typography.caption, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    if let date = comment.createdAt {
                        Text(date, style: .relative)
                            .font(Theme.Fonts.label(Typography.micro))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Text(comment.body)
                    .font(Theme.Fonts.body(Typography.callout))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.sm)
        .glassCard(cornerRadius: Radius.md, elevation: .resting)
    }

    private var commentComposer: some View {
        HStack(alignment: .bottom, spacing: Spacing.xs) {
            TextField(L10n.communityCommentPlaceholder, text: $viewModel.draftComment, axis: .vertical)
                .lineLimit(1...4)
                .font(Theme.Fonts.body(Typography.callout))
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 12)
                .glassCard(cornerRadius: Radius.md, elevation: .resting)

            Button {
                Haptic.light()
                viewModel.submitComment()
            } label: {
                Group {
                    if viewModel.isSubmittingComment {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Theme.brandGradient))
            }
            .disabled(viewModel.isSubmittingComment)
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
    }
}
