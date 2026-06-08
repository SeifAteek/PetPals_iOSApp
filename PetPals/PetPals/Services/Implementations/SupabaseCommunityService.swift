import Foundation
import Supabase

final class SupabaseCommunityService: CommunityServiceProtocol {
    private let client = SupabaseClientManager.shared.client

    private let postSelect = """
        post_id, subreddit_id, user_id, title, body, image_url, score, comment_count, created_at, updated_at,
        profiles(user_name),
        community_subreddits(name, slug)
        """

    private struct PostRow: Decodable {
        let postId: UUID
        let subredditId: UUID
        let userId: UUID
        let title: String
        let body: String
        let imageUrl: String?
        let score: Int
        let commentCount: Int
        let createdAt: Date?
        let updatedAt: Date?
        let profiles: AuthorProfile?
        let communitySubreddits: SubredditEmbed?

        enum CodingKeys: String, CodingKey {
            case postId = "post_id"
            case subredditId = "subreddit_id"
            case userId = "user_id"
            case title, body
            case imageUrl = "image_url"
            case score
            case commentCount = "comment_count"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case profiles
            case communitySubreddits = "community_subreddits"
        }
    }

    private struct CommentRow: Decodable {
        let commentId: UUID
        let postId: UUID
        let userId: UUID
        let parentCommentId: UUID?
        let body: String
        let score: Int
        let createdAt: Date?
        let profiles: AuthorProfile?

        enum CodingKeys: String, CodingKey {
            case commentId = "comment_id"
            case postId = "post_id"
            case userId = "user_id"
            case parentCommentId = "parent_comment_id"
            case body, score
            case createdAt = "created_at"
            case profiles
        }
    }

    private struct AuthorProfile: Decodable {
        let userName: String?

        enum CodingKeys: String, CodingKey {
            case userName = "user_name"
        }
    }

    private struct SubredditEmbed: Decodable {
        let name: String
        let slug: String
    }

    private struct VoteRow: Decodable {
        let targetId: UUID
        let voteValue: Int

        enum CodingKeys: String, CodingKey {
            case targetId = "target_id"
            case voteValue = "vote_value"
        }
    }

    private struct ExistingVoteRow: Decodable {
        let voteId: UUID
        let voteValue: Int

        enum CodingKeys: String, CodingKey {
            case voteId = "vote_id"
            case voteValue = "vote_value"
        }
    }

    func fetchSubreddits() async throws -> [CommunitySubreddit] {
        try await client.database
            .from("community_subreddits")
            .select()
            .eq("is_active", value: true)
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    func uploadPostImage(data: Data, fileName: String) async throws -> String {
        let storage = client.storage.from("pet_files")
        let path = "community_posts/\(fileName)"
        try await storage.upload(
            path: path,
            file: data,
            options: FileOptions(contentType: "image/jpeg", upsert: true)
        )
        return try storage.getPublicURL(path: path).absoluteString
    }

    func fetchPosts(subredditId: UUID?, userId: UUID?) async throws -> [CommunityPost] {
        let rows: [PostRow]
        if let subredditId {
            rows = try await client.database
                .from("community_posts")
                .select(postSelect)
                .eq("subreddit_id", value: subredditId.uuidString.lowercased())
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
        } else {
            rows = try await client.database
                .from("community_posts")
                .select(postSelect)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
        }

        var posts = rows.map(mapPost)
        if let userId {
            let votes = try await fetchVotes(
                userId: userId,
                targetType: .post,
                targetIds: posts.map(\.postId)
            )
            posts = posts.map { post in
                var copy = post
                copy.userVote = votes[post.postId] ?? 0
                return copy
            }
        }
        return posts
    }

    func fetchPost(postId: UUID, userId: UUID?) async throws -> CommunityPost {
        let row: PostRow = try await client.database
            .from("community_posts")
            .select(postSelect)
            .eq("post_id", value: postId.uuidString.lowercased())
            .single()
            .execute()
            .value

        var post = mapPost(row)
        if let userId {
            let votes = try await fetchVotes(userId: userId, targetType: .post, targetIds: [postId])
            post.userVote = votes[postId] ?? 0
        }
        return post
    }

    func createPost(
        subredditId: UUID,
        userId: UUID,
        title: String,
        body: String,
        imageUrl: String?
    ) async throws -> CommunityPost {
        let payload = CommunityPostInsert(
            subredditId: subredditId,
            userId: userId,
            title: title,
            body: body,
            imageUrl: imageUrl
        )
        let row: PostRow = try await client.database
            .from("community_posts")
            .insert(payload)
            .select(postSelect)
            .single()
            .execute()
            .value
        return mapPost(row)
    }

    func fetchComments(postId: UUID, userId: UUID?) async throws -> [CommunityComment] {
        let rows: [CommentRow] = try await client.database
            .from("community_comments")
            .select("comment_id, post_id, user_id, parent_comment_id, body, score, created_at, profiles(user_name)")
            .eq("post_id", value: postId.uuidString.lowercased())
            .order("created_at", ascending: true)
            .execute()
            .value

        var comments = rows.map(mapComment)
        if let userId {
            let votes = try await fetchVotes(
                userId: userId,
                targetType: .comment,
                targetIds: comments.map(\.commentId)
            )
            comments = comments.map { comment in
                var copy = comment
                copy.userVote = votes[comment.commentId] ?? 0
                return copy
            }
        }
        return comments
    }

    func createComment(postId: UUID, userId: UUID, body: String) async throws -> CommunityComment {
        let payload = CommunityCommentInsert(postId: postId, userId: userId, body: body)
        let row: CommentRow = try await client.database
            .from("community_comments")
            .insert(payload)
            .select("comment_id, post_id, user_id, parent_comment_id, body, score, created_at, profiles(user_name)")
            .single()
            .execute()
            .value
        return mapComment(row)
    }

    func castVote(
        userId: UUID,
        target: CommunityVoteTarget,
        targetId: UUID,
        direction: Int
    ) async throws -> Int {
        guard direction == 1 || direction == -1 else {
            throw NSError(domain: "Community", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid vote direction"])
        }

        let existing: [ExistingVoteRow] = try await client.database
            .from("community_votes")
            .select("vote_id, vote_value")
            .eq("user_id", value: userId.uuidString.lowercased())
            .eq("target_type", value: target.rawValue)
            .eq("target_id", value: targetId.uuidString.lowercased())
            .limit(1)
            .execute()
            .value

        if let vote = existing.first {
            if vote.voteValue == direction {
                try await client.database
                    .from("community_votes")
                    .delete()
                    .eq("vote_id", value: vote.voteId.uuidString.lowercased())
                    .execute()
                return 0
            }
            try await client.database
                .from("community_votes")
                .update(CommunityVoteUpdate(voteValue: direction))
                .eq("vote_id", value: vote.voteId.uuidString.lowercased())
                .execute()
            return direction
        }

        let insert = CommunityVoteInsert(
            userId: userId,
            targetType: target.rawValue,
            targetId: targetId,
            voteValue: direction
        )
        try await client.database
            .from("community_votes")
            .insert(insert)
            .execute()
        return direction
    }

    // MARK: - Helpers

    private func fetchVotes(
        userId: UUID,
        targetType: CommunityVoteTarget,
        targetIds: [UUID]
    ) async throws -> [UUID: Int] {
        guard !targetIds.isEmpty else { return [:] }
        let idStrings = targetIds.map { $0.uuidString.lowercased() }
        let rows: [VoteRow] = try await client.database
            .from("community_votes")
            .select("target_id, vote_value")
            .eq("user_id", value: userId.uuidString.lowercased())
            .eq("target_type", value: targetType.rawValue)
            .in("target_id", values: idStrings)
            .execute()
            .value
        return Dictionary(uniqueKeysWithValues: rows.map { ($0.targetId, $0.voteValue) })
    }

    private func mapPost(_ row: PostRow) -> CommunityPost {
        CommunityPost(
            postId: row.postId,
            subredditId: row.subredditId,
            userId: row.userId,
            title: row.title,
            body: row.body,
            imageUrl: row.imageUrl,
            score: row.score,
            commentCount: row.commentCount,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
            authorName: row.profiles?.userName,
            subredditName: row.communitySubreddits?.name,
            subredditSlug: row.communitySubreddits?.slug
        )
    }

    private func mapComment(_ row: CommentRow) -> CommunityComment {
        CommunityComment(
            commentId: row.commentId,
            postId: row.postId,
            userId: row.userId,
            parentCommentId: row.parentCommentId,
            body: row.body,
            score: row.score,
            createdAt: row.createdAt,
            authorName: row.profiles?.userName
        )
    }
}
