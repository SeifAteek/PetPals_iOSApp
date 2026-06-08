import Foundation

enum UserType: String, Codable {
    case adopter = "Adopter"
    case clinic = "Clinic"
    case shelter = "Shelter"
    case admin = "Admin"
}

struct Profile: Codable, Identifiable {
    var id: UUID { userId }
    let userId: UUID
    let userName: String
    let email: String?
    let phoneNumber: String?
    let userType: UserType?
    let avatarUrl: String?

    var isProfileComplete: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !(email?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) &&
        !(phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) &&
        userType != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case email
        case phoneNumber = "phone_number"
        case userType = "user_type"
        case avatarUrl = "avatar_url"
    }
}



struct ShelterProfile: Codable, Identifiable {
    var id: UUID { shelterId }
    let shelterId: UUID
    let userId: UUID?
    let orgName: String
    let licenseNumber: String?
    let isVerified: Bool?
    let logoUrl: String?
    let rating: Double?

    enum CodingKeys: String, CodingKey {
        case shelterId = "shelter_id"
        case userId = "user_id"
        case orgName = "org_name"
        case licenseNumber = "license_number"
        case isVerified = "is_verified"
        case logoUrl = "logo_url"
        case rating
    }
}
