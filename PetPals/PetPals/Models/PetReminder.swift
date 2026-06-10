import Foundation

enum ReminderType: String, Codable, CaseIterable {
    case feeding = "Feeding"
    case medication = "Medication"
    case vetVisit = "Vet Visit"
    case grooming = "Grooming"
    case exercise = "Exercise"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .feeding: return "fork.knife"
        case .medication: return "pills.fill"
        case .vetVisit: return "cross.case.fill"
        case .grooming: return "scissors"
        case .exercise: return "figure.walk"
        case .custom: return "bell.fill"
        }
    }
    
    var color: String {
        switch self {
        case .feeding: return "orange"
        case .medication: return "red"
        case .vetVisit: return "blue"
        case .grooming: return "purple"
        case .exercise: return "green"
        case .custom: return "gray"
        }
    }
}

struct PetReminder: Codable, Identifiable {
    let id: UUID
    let petId: UUID
    let petName: String
    var title: String
    var body: String
    var type: ReminderType
    var time: Date
    var isRepeating: Bool
    var isEnabled: Bool
    
    init(id: UUID = UUID(), petId: UUID, petName: String, title: String, body: String, type: ReminderType, time: Date, isRepeating: Bool = true, isEnabled: Bool = true) {
        self.id = id
        self.petId = petId
        self.petName = petName
        self.title = title
        self.body = body
        self.type = type
        self.time = time
        self.isRepeating = isRepeating
        self.isEnabled = isEnabled
    }
}
