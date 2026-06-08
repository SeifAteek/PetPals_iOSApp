import Foundation
import Combine

@MainActor
final class CommunityFeedViewModel: ObservableObject {
    @Published var subreddits: [CommunitySubreddit] = []
    @Published var selectedSubredditId: UUID?
    @Published var posts: [CommunityPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let communityService: CommunityServiceProtocol
    private let authService: AuthServiceProtocol

    init(
        communityService: CommunityServiceProtocol = DependencyContainer.shared.communityService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.communityService = communityService
        self.authService = authService
    }

    func load() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                async let subs = communityService.fetchSubreddits()
                let userId = try await authService.getCurrentUser()?.userId
                let fetchedSubs = try await subs
                subreddits = fetchedSubs
                posts = try await communityService.fetchPosts(
                    subredditId: selectedSubredditId,
                    userId: userId
                )
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func selectSubreddit(_ id: UUID?) {
        selectedSubredditId = id
        load()
    }

    func vote(on post: CommunityPost, direction: Int) {
        Task {
            do {
                guard let user = try await authService.getCurrentUser() else {
                    errorMessage = L10n.communitySignInToVote
                    return
                }
                _ = try await communityService.castVote(
                    userId: user.userId,
                    target: .post,
                    targetId: post.postId,
                    direction: direction
                )
                if let idx = posts.firstIndex(where: { $0.postId == post.postId }) {
                    let refreshed = try await communityService.fetchPost(postId: post.postId, userId: user.userId)
                    posts[idx] = refreshed
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
