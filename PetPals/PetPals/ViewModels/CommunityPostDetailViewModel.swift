import Foundation
import Combine

@MainActor
final class CommunityPostDetailViewModel: ObservableObject {
    @Published var post: CommunityPost?
    @Published var comments: [CommunityComment] = []
    @Published var draftComment = ""
    @Published var isLoading = false
    @Published var isSubmittingComment = false
    @Published var errorMessage: String?

    let postId: UUID
    private let communityService: CommunityServiceProtocol
    private let authService: AuthServiceProtocol

    init(
        postId: UUID,
        communityService: CommunityServiceProtocol = DependencyContainer.shared.communityService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.postId = postId
        self.communityService = communityService
        self.authService = authService
    }

    func load() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let userId = try await authService.getCurrentUser()?.userId
                async let postTask = communityService.fetchPost(postId: postId, userId: userId)
                async let commentsTask = communityService.fetchComments(postId: postId, userId: userId)
                post = try await postTask
                comments = try await commentsTask
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func submitComment() {
        let text = draftComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        isSubmittingComment = true
        Task {
            do {
                guard let user = try await authService.getCurrentUser() else {
                    errorMessage = L10n.communitySignInToComment
                    isSubmittingComment = false
                    return
                }
                let created = try await communityService.createComment(
                    postId: postId,
                    userId: user.userId,
                    body: text
                )
                var withVote = created
                withVote.userVote = 0
                comments.append(withVote)
                draftComment = ""
                post = try await communityService.fetchPost(postId: postId, userId: user.userId)
                isSubmittingComment = false
            } catch {
                errorMessage = error.localizedDescription
                isSubmittingComment = false
            }
        }
    }

    func votePost(direction: Int) {
        guard let current = post else { return }
        Task {
            do {
                guard let user = try await authService.getCurrentUser() else {
                    errorMessage = L10n.communitySignInToVote
                    return
                }
                _ = try await communityService.castVote(
                    userId: user.userId,
                    target: .post,
                    targetId: current.postId,
                    direction: direction
                )
                post = try await communityService.fetchPost(postId: postId, userId: user.userId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func voteComment(_ comment: CommunityComment, direction: Int) {
        Task {
            do {
                guard let user = try await authService.getCurrentUser() else {
                    errorMessage = L10n.communitySignInToVote
                    return
                }
                _ = try await communityService.castVote(
                    userId: user.userId,
                    target: .comment,
                    targetId: comment.commentId,
                    direction: direction
                )
                comments = try await communityService.fetchComments(postId: postId, userId: user.userId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
