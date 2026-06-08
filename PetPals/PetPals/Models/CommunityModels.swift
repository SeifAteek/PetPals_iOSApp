import Foundation

struct CommunitySubreddit: Codable, Identifiable, Hashable {
    var id: UUID { subredditId }
    let subredditId: UUID
    let slug: String
    let name: String
    let description: String?
    let iconName: String?
    let isActive: Bool?
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case subredditId = "subreddit_id"
        case slug, name, description
        case iconName = "icon_name"
        case isActive = "is_active"
        case sortOrder = "sort_order"
    }
}

struct CommunityPost: Codable, Identifiable, Hashable {
    var id: UUID { postId }
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
    let authorName: String?
    let subredditName: String?
    let subredditSlug: String?
    /// Current user's vote: -1, 0, or 1 (not from DB row; filled client-side).
    var userVote: Int

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
        case authorName = "author_name"
        case subredditName = "subreddit_name"
        case subredditSlug = "subreddit_slug"
        case userVote = "user_vote"
    }

    init(
        postId: UUID,
        subredditId: UUID,
        userId: UUID,
        title: String,
        body: String,
        imageUrl: String? = nil,
        score: Int,
        commentCount: Int,
        createdAt: Date?,
        updatedAt: Date?,
        authorName: String?,
        subredditName: String?,
        subredditSlug: String?,
        userVote: Int = 0
    ) {
        self.postId = postId
        self.subredditId = subredditId
        self.userId = userId
        self.title = title
        self.body = body
        self.imageUrl = imageUrl
        self.score = score
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.authorName = authorName
        self.subredditName = subredditName
        self.subredditSlug = subredditSlug
        self.userVote = userVote
    }
}

struct CommunityComment: Codable, Identifiable, Hashable {
    var id: UUID { commentId }
    let commentId: UUID
    let postId: UUID
    let userId: UUID
    let parentCommentId: UUID?
    let body: String
    let score: Int
    let createdAt: Date?
    let authorName: String?
    var userVote: Int

    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case postId = "post_id"
        case userId = "user_id"
        case parentCommentId = "parent_comment_id"
        case body, score
        case createdAt = "created_at"
        case authorName = "author_name"
        case userVote = "user_vote"
    }

    init(
        commentId: UUID,
        postId: UUID,
        userId: UUID,
        parentCommentId: UUID?,
        body: String,
        score: Int,
        createdAt: Date?,
        authorName: String?,
        userVote: Int = 0
    ) {
        self.commentId = commentId
        self.postId = postId
        self.userId = userId
        self.parentCommentId = parentCommentId
        self.body = body
        self.score = score
        self.createdAt = createdAt
        self.authorName = authorName
        self.userVote = userVote
    }
}

enum CommunityVoteTarget: String, Codable {
    case post
    case comment
}

struct CommunityPostInsert: Encodable {
    let subredditId: UUID
    let userId: UUID
    let title: String
    let body: String
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case subredditId = "subreddit_id"
        case userId = "user_id"
        case title, body
        case imageUrl = "image_url"
    }
}

struct CommunityCommentInsert: Encodable {
    let postId: UUID
    let userId: UUID
    let body: String

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
        case body
    }
}

struct CommunityVoteInsert: Encodable {
    let userId: UUID
    let targetType: String
    let targetId: UUID
    let voteValue: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case targetType = "target_type"
        case targetId = "target_id"
        case voteValue = "vote_value"
    }
}

struct CommunityVoteUpdate: Encodable {
    let voteValue: Int

    enum CodingKeys: String, CodingKey {
        case voteValue = "vote_value"
    }
}
