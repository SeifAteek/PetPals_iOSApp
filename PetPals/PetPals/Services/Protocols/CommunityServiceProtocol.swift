import Foundation

protocol CommunityServiceProtocol {
    func fetchSubreddits() async throws -> [CommunitySubreddit]
    func fetchPosts(subredditId: UUID?, userId: UUID?) async throws -> [CommunityPost]
    func fetchPost(postId: UUID, userId: UUID?) async throws -> CommunityPost
    func uploadPostImage(data: Data, fileName: String) async throws -> String
    func createPost(
        subredditId: UUID,
        userId: UUID,
        title: String,
        body: String,
        imageUrl: String?
    ) async throws -> CommunityPost
    func fetchComments(postId: UUID, userId: UUID?) async throws -> [CommunityComment]
    func createComment(postId: UUID, userId: UUID, body: String) async throws -> CommunityComment
    /// Returns the user's vote after the action: -1, 0, or 1.
    func castVote(
        userId: UUID,
        target: CommunityVoteTarget,
        targetId: UUID,
        direction: Int
    ) async throws -> Int
}
