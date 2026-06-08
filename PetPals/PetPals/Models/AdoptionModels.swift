import Foundation

enum ApplicationStatus: String, Codable {
    case underReview = "Under Review"
    case approved = "Approved"
    case rejected = "Rejected"
}

struct Application: Codable, Identifiable {
    var id: UUID { applicationId }
    let applicationId: UUID
    let petId: UUID?
    let adopterId: UUID?
    let submissionDate: Date?
    let status: ApplicationStatus?
    let matchScore: Int?
    
    enum CodingKeys: String, CodingKey {
        case applicationId = "application_id"
        case petId = "pet_id"
        case adopterId = "adopter_id"
        case submissionDate = "submission_date"
        case status
        case matchScore = "match_score"
    }
}

struct Campaign: Codable, Identifiable, Hashable {
    var id: UUID { campaignId }
    let campaignId: UUID
    let shelterId: UUID?
    let title: String
    let goalAmount: Decimal
    let currentAmount: Decimal?
    let endDate: Date?
    let createdAt: Date?
    let description: String?
    let isDeleted: Bool?

    enum CodingKeys: String, CodingKey {
        case campaignId = "campaign_id"
        case shelterId = "shelter_id"
        case title
        case goalAmount = "goal_amount"
        case currentAmount = "current_amount"
        case endDate = "end_date"
        case createdAt = "created_at"
        case description
        case isDeleted = "is_deleted"
    }
}

struct Donation: Codable, Identifiable {
    var id: UUID { donationId }
    let donationId: UUID
    let campaignId: UUID?
    let userId: UUID?
    let amount: Decimal
    let donationDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case donationId = "donation_id"
        case campaignId = "campaign_id"
        case userId = "user_id"
        case amount
        case donationDate = "donation_date"
    }
}

/// One row per conversation partner (clinic or shelter) for the messages list.
struct ChatThreadSummary: Identifiable {
    let id: UUID
    let clinicId: UUID?
    let shelterId: UUID?
    let partnerName: String
    let partnerLogoURL: String?
    let previewText: String
    let createdAt: Date?
}

enum MessageSender: String, Codable {
    case clinic = "Clinic"
    case client = "Client"
    case shelter = "Shelter"
}

struct ChatMessage: Codable, Identifiable {
    var id: UUID { messageId }
    let messageId: UUID
    let clinicId: UUID?
    let shelterId: UUID?
    let clientId: UUID?
    let sender: MessageSender?
    let text: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case clinicId = "clinic_id"
        case shelterId = "shelter_id"
        case clientId = "client_id"
        case sender
        case text
        case createdAt = "created_at"
    }
}

struct AdopterProfile: Codable, Hashable {
    let adopterId: UUID
    let userId: UUID
    let housingType: String?
    let hasOtherPets: Bool?
    
    enum CodingKeys: String, CodingKey {
        case adopterId = "adopter_id"
        case userId = "user_id"
        case housingType = "housing_type"
        case hasOtherPets = "has_other_pets"
    }
}

/// In-progress adoption application passed from the form step to scheduling.
struct AdoptionFormDraft: Equatable {
    let petId: UUID
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let address: String
    let city: String
    let zip: String
    let housingType: String
    let hasOtherPets: Bool
    let preferredDate: Date
    let preferredTime: String
}

struct PetApplication: Codable, Hashable, Identifiable {
    var id: UUID { applicationId }
    let applicationId: UUID
    let petId: UUID
    let adopterId: UUID
    let submissionDate: Date
    let status: ApplicationStatus
    let matchScore: Int?
    
    enum CodingKeys: String, CodingKey {
        case applicationId = "application_id"
        case petId = "pet_id"
        case adopterId = "adopter_id"
        case submissionDate = "submission_date"
        case status
        case matchScore = "match_score"
    }
}
