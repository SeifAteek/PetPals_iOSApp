import Foundation
import SwiftUI
import Combine

@MainActor
final class ReviewViewModel: ObservableObject {
    @Published var reviews: [EntityReview] = []
    @Published var summary = EntityRatingSummary(average: 0, count: 0)
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    @Published var draftRating = 5
    @Published var draftComment = ""

    let entityType: ReviewEntityType
    let entityId: UUID

    private let reviewService: ReviewServiceProtocol
    private let authService: AuthServiceProtocol

    init(
        entityType: ReviewEntityType,
        entityId: UUID,
        reviewService: ReviewServiceProtocol = DependencyContainer.shared.reviewService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.entityType = entityType
        self.entityId = entityId
        self.reviewService = reviewService
        self.authService = authService
    }

    func load() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetched = try await reviewService.fetchReviews(
                    entityType: entityType,
                    entityId: entityId
                )
                reviews = fetched
                if fetched.isEmpty {
                    summary = EntityRatingSummary(average: 0, count: 0)
                } else {
                    let total = fetched.reduce(0) { $0 + $1.rating }
                    summary = EntityRatingSummary(
                        average: Double(total) / Double(fetched.count),
                        count: fetched.count
                    )
                }
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func submitReview() {
        guard draftRating >= 1, draftRating <= 5 else {
            errorMessage = "Please select a rating from 1 to 5 stars."
            return
        }
        isSubmitting = true
        errorMessage = nil
        Task {
            do {
                guard let user = try await authService.getCurrentUser() else {
                    errorMessage = "Sign in to leave a review."
                    isSubmitting = false
                    return
                }
                try await reviewService.submitReview(
                    userId: user.userId,
                    entityType: entityType,
                    entityId: entityId,
                    rating: draftRating,
                    comment: draftComment.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                draftComment = ""
                draftRating = 5
                isSubmitting = false
                load()
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}
