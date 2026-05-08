import Foundation

enum PetStatus: String, Codable, Hashable {
    case available = "Available"
    case active = "Active"
    case healthy = "Healthy"
    case sick = "Sick"
    case adopted = "Adopted"
    case deceased = "Deceased"
    case recovery = "Recovery"
    case archived = "Archived"
}

struct Pet: Codable, Identifiable, Hashable {
    var id: UUID { petId }
    let petId: UUID
    let shelterId: UUID?
    let name: String
    let breed: String?
    let age: Int?
    let status: PetStatus?
    let medicalHistory: String?
    let clinicId: UUID?
    let guestOwnerName: String?
    let avatarUrl: String?
    let guestPhone: String?
    let species: String?
    let ownerId: UUID?
    let createdAt: Date?
    var collarUUID: String?
    
    enum CodingKeys: String, CodingKey {
        case petId = "pet_id"
        case shelterId = "shelter_id"
        case name
        case breed
        case age
        case status
        case medicalHistory = "medical_history"
        case clinicId = "clinic_id"
        case guestOwnerName = "guest_owner_name"
        case avatarUrl = "avatar_url"
        case guestPhone = "guest_phone"
        case species
        case ownerId = "owner_id"
        case createdAt = "created_at"
        case collarUUID = "collar_uuid"
    }
}

struct SmartCollar: Codable, Identifiable {
    var id: UUID { collarId }
    let collarId: UUID
    let petId: UUID?
    let serialNumber: String
    let lastSyncTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case collarId = "collar_id"
        case petId = "pet_id"
        case serialNumber = "serial_number"
        case lastSyncTime = "last_sync_time"
    }
}
