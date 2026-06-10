import Foundation

struct DayHours: Codable, Equatable, Hashable {
    let open: String
    let close: String
}

struct Clinic: Codable, Identifiable, Hashable {
    var id: UUID { clinicId }
    let clinicId: UUID
    let name: String
    let location: String?
    let phone: String?
    let ownerId: UUID?
    let logoUrl: String?
    let rating: Double?
    var latitude: Double?
    var longitude: Double?
    /// ISO calendar dates (`yyyy-MM-dd`) when the clinic is closed (vacation); optional DB column.
    let vacationDates: [String]?
    let workingHours: [String: DayHours?]?
    
    enum CodingKeys: String, CodingKey {
        case clinicId = "clinic_id"
        case name
        case location
        case phone
        case ownerId = "owner_id"
        case logoUrl = "logo_url"
        case rating
        case latitude
        case longitude
        case vacationDates = "vacation_dates"
        case workingHours = "working_hours"
    }
}

enum StaffRole: String, Codable {
    case headVet = "Head Vet"
    case associateVet = "Associate Vet"
    case receptionist = "Receptionist"
    case technician = "Technician"
}

struct ClinicStaff: Codable, Identifiable {
    var id: UUID { staffId }
    let staffId: UUID
    let clinicId: UUID?
    let userId: UUID?
    let role: StaffRole?
    let isActive: Bool?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case staffId = "staff_id"
        case clinicId = "clinic_id"
        case userId = "user_id"
        case role
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

struct MedicalRecord: Codable, Identifiable {
    var id: UUID { recordId }
    let recordId: UUID
    let petId: UUID?
    let clinicId: UUID?
    let visitDate: Date?
    let diagnosis: String
    let treatment: String
    let vetName: String?
    let attachmentUrl: String?
    let attachmentType: String?
    
    enum CodingKeys: String, CodingKey {
        case recordId = "record_id"
        case petId = "pet_id"
        case clinicId = "clinic_id"
        case visitDate = "visit_date"
        case diagnosis
        case treatment
        case vetName = "vet_name"
        case attachmentUrl = "attachment_url"
        case attachmentType = "attachment_type"
    }
}

enum AppointmentStatus: String, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case missed = "Missed"
}

struct Appointment: Codable, Identifiable {
    var id: UUID { appointmentId }
    let appointmentId: UUID
    let userId: UUID?
    let clinicId: UUID?
    let petId: UUID?
    let appointmentDate: Date
    let reason: String?
    let status: AppointmentStatus?
    
    enum CodingKeys: String, CodingKey {
        case appointmentId = "appointment_id"
        case userId = "user_id"
        case clinicId = "clinic_id"
        case petId = "pet_id"
        case appointmentDate = "appointment_date"
        case reason
        case status
    }
}

struct AppointmentUsage: Codable, Identifiable {
    var id: UUID { usageId }
    let usageId: UUID
    let appointmentId: UUID?
    let itemId: UUID?
    let quantityUsed: Int
    
    enum CodingKeys: String, CodingKey {
        case usageId = "usage_id"
        case appointmentId = "appointment_id"
        case itemId = "item_id"
        case quantityUsed = "quantity_used"
    }
}

enum InventoryCategory: String, Codable {
    case medicine = "Medicine"
    case vaccine = "Vaccine"
    case consumable = "Consumable"
    case retail = "Retail"
}

struct InventoryItem: Codable, Identifiable {
    var id: UUID { itemId }
    let itemId: UUID
    let clinicId: UUID?
    let itemName: String
    let category: InventoryCategory?
    let currentStock: Int?
    let lowStockThreshold: Int?
    let unitPrice: Decimal?
    let lastRestocked: Date?
    
    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case clinicId = "clinic_id"
        case itemName = "item_name"
        case category
        case currentStock = "current_stock"
        case lowStockThreshold = "low_stock_threshold"
        case unitPrice = "unit_price"
        case lastRestocked = "last_restocked"
    }
}

struct ClinicProcedure: Codable, Identifiable {
    var id: UUID { procedureId }
    let procedureId: UUID
    let clinicId: UUID?
    let name: String
    let price: Decimal
    
    enum CodingKeys: String, CodingKey {
        case procedureId = "procedure_id"
        case clinicId = "clinic_id"
        case name
        case price
    }
}

enum ExpenseCategory: String, Codable {
    case inventoryRestock = "Inventory Restock"
    case equipment = "Equipment"
    case rent = "Rent"
    case other = "Other"
}

struct ClinicExpense: Codable, Identifiable {
    var id: UUID { expenseId }
    let expenseId: UUID
    let clinicId: UUID?
    let category: ExpenseCategory?
    let description: String
    let amount: Decimal
    let expenseDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case expenseId = "expense_id"
        case clinicId = "clinic_id"
        case category
        case description
        case amount
        case expenseDate = "expense_date"
    }
}
