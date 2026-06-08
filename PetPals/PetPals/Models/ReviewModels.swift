import Foundation

enum ReviewEntityType: String, Codable {
    case clinic
    case shelter
    case shop
}

struct EntityReview: Codable, Identifiable {
    var id: UUID { reviewId }
    let reviewId: UUID
    let userId: UUID?
    let entityType: ReviewEntityType
    let entityId: UUID
    let rating: Int
    let comment: String?
    let createdAt: Date?
    let reviewerName: String?

    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case userId = "user_id"
        case entityType = "entity_type"
        case entityId = "entity_id"
        case rating
        case comment
        case createdAt = "created_at"
        case reviewerName = "reviewer_name"
    }
}

struct EntityReviewInsert: Encodable {
    let userId: UUID
    let entityType: String
    let entityId: UUID
    let rating: Int
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case entityType = "entity_type"
        case entityId = "entity_id"
        case rating
        case comment
    }
}

struct EntityRatingSummary {
    let average: Double
    let count: Int
}
