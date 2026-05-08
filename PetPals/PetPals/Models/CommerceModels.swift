import Foundation

// MARK: - Shop (Seller)
struct Shop: Codable, Identifiable, Hashable {
    var id: UUID { shopId }
    let shopId: UUID
    let name: String
    let description: String?
    let logoUrl: String?
    let category: String?   // e.g. "Food", "Accessories", "Medicine"
    let rating: Double?
    let isVerified: Bool?
    
    enum CodingKeys: String, CodingKey {
        case shopId      = "shop_id"
        case name
        case description
        case logoUrl     = "logo_url"
        case category
        case rating
        case isVerified  = "is_verified"
    }
}

// MARK: - Product
struct PetProduct: Codable, Identifiable, Hashable {
    var id: UUID { productId }
    let productId: UUID
    let name: String
    let price: Decimal
    let stockLevel: Int?
    let category: String?
    let description: String?
    let imageUrl: String?
    let shopId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case productId  = "product_id"
        case name
        case price
        case stockLevel = "stock_level"
        case category
        case description
        case imageUrl   = "image_url"
        case shopId     = "shop_id"
    }
    
    // Only show products that are in stock
    var isInStock: Bool { (stockLevel ?? 0) > 0 }
}

// MARK: - Product Gallery Image
struct ProductImage: Codable, Identifiable {
    var id: UUID { imageId }
    let imageId: UUID
    let productId: UUID
    let url: String
    let sortOrder: Int
    let isPrimary: Bool
    
    enum CodingKeys: String, CodingKey {
        case imageId   = "image_id"
        case productId = "product_id"
        case url
        case sortOrder = "sort_order"
        case isPrimary = "is_primary"
    }
}

enum OrderStatus: String, Codable {
    case processing = "Processing"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}

struct ShopOrder: Codable, Identifiable {
    var id: UUID { orderId }
    let orderId: UUID
    let userId: UUID?
    let shopId: UUID?
    let orderDate: Date?
    let totalAmount: Decimal?
    let status: OrderStatus?
    let shippingAddress: String?
    let paymentMethod: String?
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case userId = "user_id"
        case shopId = "shop_id"
        case orderDate = "order_date"
        case totalAmount = "total_amount"
        case status
        case shippingAddress = "shipping_address"
        case paymentMethod = "payment_method"
    }
}

struct ShopOrderItem: Codable, Identifiable {
    var id: UUID { orderItemId }
    let orderItemId: UUID
    let orderId: UUID?
    let productId: UUID?
    let quantity: Int
    let subTotal: Decimal
    
    enum CodingKeys: String, CodingKey {
        case orderItemId = "order_item_id"
        case orderId = "order_id"
        case productId = "product_id"
        case quantity
        case subTotal = "sub_total"
    }
}

enum InvoiceStatus: String, Codable {
    case pending = "Pending"
    case paid = "Paid"
    case overdue = "Overdue"
    case cancelled = "Cancelled"
}

struct Invoice: Codable, Identifiable {
    var id: UUID { invoiceId }
    let invoiceId: UUID
    let clinicId: UUID?
    let shopId: UUID?
    let clientId: UUID?
    let guestClientName: String?
    let petId: UUID?
    let totalAmount: Decimal
    let status: InvoiceStatus?
    let issueDate: Date?
    let dueDate: Date?
    let appointmentId: UUID?
    let paymentMethod: String?
    
    enum CodingKeys: String, CodingKey {
        case invoiceId = "invoice_id"
        case clinicId = "clinic_id"
        case shopId = "shop_id"
        case clientId = "client_id"
        case guestClientName = "guest_client_name"
        case petId = "pet_id"
        case totalAmount = "total_amount"
        case status
        case issueDate = "issue_date"
        case dueDate = "due_date"
        case appointmentId = "appointment_id"
        case paymentMethod = "payment_method"
    }
}
