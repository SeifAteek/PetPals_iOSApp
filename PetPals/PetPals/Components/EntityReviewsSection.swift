import SwiftUI

struct EntityReviewsSection: View {
    @StateObject private var viewModel: ReviewViewModel

    init(entityType: ReviewEntityType, entityId: UUID) {
        _viewModel = StateObject(wrappedValue: ReviewViewModel(entityType: entityType, entityId: entityId))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            PremiumSectionHeader(title: L10n.reviewsRatings)

            if viewModel.isLoading {
                PremiumLoadingView(message: L10n.loadingReviews)
            } else {
                ratingSummary
                submitForm
                reviewsList
            }

            if let err = viewModel.errorMessage {
                Text(err)
                    .font(Theme.Fonts.body(Typography.caption))
                    .foregroundStyle(.red)
            }
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
        .onAppear { viewModel.load() }
    }

    private var ratingSummary: some View {
        HStack(spacing: Spacing.sm) {
            Text(String(format: "%.1f", viewModel.summary.average))
                .font(Theme.Fonts.display(Typography.title2))
                .foregroundStyle(Theme.primary)
            starRow(rating: Int(viewModel.summary.average.rounded()))
            Text(L10n.reviewsCount(viewModel.summary.count))
                .font(Theme.Fonts.body(Typography.caption))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
        }
        .padding(Spacing.sm)
        .glassCard(cornerRadius: Radius.md, elevation: .resting)
    }

    private var submitForm: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(L10n.yourRating)
                .font(Theme.Fonts.label(Typography.caption, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        Haptic.selection()
                        viewModel.draftRating = star
                    } label: {
                        Image(systemName: star <= viewModel.draftRating ? "star.fill" : "star")
                            .font(.system(size: 26))
                            .foregroundStyle(star <= viewModel.draftRating ? Theme.primary : Theme.textSecondary.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                }
            }
            TextField(L10n.reviewPlaceholder, text: $viewModel.draftComment, axis: .vertical)
                .lineLimit(3...5)
                .font(Theme.Fonts.body(Typography.callout))
                .padding(Spacing.sm)
                .glassCard(cornerRadius: Radius.md, elevation: .resting)
            PrimaryButton(title: L10n.submitReview, isLoading: viewModel.isSubmitting) {
                viewModel.submitReview()
            }
        }
        .padding(Spacing.sm)
        .glassCard(cornerRadius: Radius.lg, elevation: .resting)
    }

    @ViewBuilder
    private var reviewsList: some View {
        if viewModel.reviews.isEmpty {
            Text(L10n.noReviewsYet)
                .font(Theme.Fonts.body(Typography.callout))
                .foregroundStyle(Theme.textSecondary)
        } else {
            VStack(spacing: Spacing.xs) {
                ForEach(viewModel.reviews) { review in
                    reviewRow(review)
                }
            }
        }
    }

    private func reviewRow(_ review: EntityReview) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.reviewerName ?? L10n.reviewerDefault)
                    .font(Theme.Fonts.headline(Typography.callout, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                starRow(rating: review.rating, size: 12)
            }
            if let comment = review.comment, !comment.isEmpty {
                Text(comment)
                    .font(Theme.Fonts.body(Typography.caption))
                    .foregroundStyle(Theme.textSecondary)
            }
            if let date = review.createdAt {
                Text(date, style: .date)
                    .font(Theme.Fonts.label(Typography.micro))
                    .foregroundStyle(Theme.textSecondary.opacity(0.7))
            }
        }
        .padding(Spacing.sm)
        .glassCard(cornerRadius: Radius.md, elevation: .resting)
    }

    private func starRow(rating: Int, size: CGFloat = 14) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(i <= rating ? Theme.primary : Theme.textSecondary.opacity(0.3))
            }
        }
    }
}
