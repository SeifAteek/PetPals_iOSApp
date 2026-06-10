import ActivityKit
import Foundation

struct OrderStatusAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var updatedAt: Date
    }
    
    var orderNumber: String
    var shopName: String
    var totalAmount: String
}
