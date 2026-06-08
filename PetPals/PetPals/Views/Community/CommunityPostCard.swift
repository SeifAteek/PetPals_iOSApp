import SwiftUI

struct CommunityPostCard: View {
    let post: CommunityPost
    var onUpvote: () -> Void
    var onDownvote: () -> Void
    var onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            CommunityVoteControl(
                score: post.score,
                userVote: post.userVote,
                onUp: onUpvote,
                onDown: onDownvote
            )

            Button(action: onTap) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    if let sub = post.subredditName {
                        Text("r/\(sub)")
                            .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                            .foregroundStyle(Theme.primary)
                    }

                    Text(post.title)
                        .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)

                    if post.imageUrl != nil {
                        CommunityPostImageView(imageUrl: post.imageUrl, maxHeight: 140)
                    }

                    if !post.body.isEmpty {
                    Text(post.body)
                        .font(Theme.Fonts.body(Typography.caption))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    }

                    HStack(spacing: Spacing.sm) {
                        Label(post.authorName ?? L10n.petParentDefault, systemImage: "person.fill")
                        Label(L10n.communityCommentsCount(post.commentCount), systemImage: "bubble.right.fill")
                        if let date = post.createdAt {
                            Text(date, style: .relative)
                        }
                    }
                    .font(Theme.Fonts.label(Typography.micro, weight: .medium))
                    .foregroundStyle(Theme.textSecondary.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.sm)
        .glassCard(cornerRadius: Radius.lg, elevation: .resting)
    }
}
