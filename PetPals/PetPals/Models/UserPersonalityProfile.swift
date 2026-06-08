import Foundation

struct UserPersonalityProfile: Codable, Equatable {
    let userId: UUID
    let livingSituation: String?
    let activityLevel: String?
    let hoursHome: String?
    let experience: String?
    let allergies: String?
    let householdType: String?
    let petPriority: String?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case livingSituation = "living_situation"
        case activityLevel = "activity_level"
        case hoursHome = "hours_home"
        case experience = "experience"
        case allergies = "allergies"
        case householdType = "household_type"
        case petPriority = "pet_priority"
        case updatedAt = "updated_at"
    }

    var isComplete: Bool {
        livingSituation != nil &&
        activityLevel != nil &&
        hoursHome != nil &&
        experience != nil &&
        allergies != nil &&
        householdType != nil &&
        petPriority != nil
    }
}

struct UserPersonalityProfileUpsert: Encodable {
    let userId: UUID
    let livingSituation: String
    let activityLevel: String
    let hoursHome: String
    let experience: String
    let allergies: String
    let householdType: String
    let petPriority: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case livingSituation = "living_situation"
        case activityLevel = "activity_level"
        case hoursHome = "hours_home"
        case experience = "experience"
        case allergies = "allergies"
        case householdType = "household_type"
        case petPriority = "pet_priority"
    }
}

struct RecommendedPet: Identifiable, Hashable {
    var id: UUID { pet.id }
    let pet: Pet
    let matchScore: Int
}
