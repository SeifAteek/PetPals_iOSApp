import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<OrderStatusAttributes>?
    
    func startOrderTracking(orderNumber: String, shopName: String, totalAmount: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[LiveActivity] Activities not enabled")
            return
        }
        
        let attributes = OrderStatusAttributes(
            orderNumber: orderNumber,
            shopName: shopName,
            totalAmount: totalAmount
        )
        let initialState = OrderStatusAttributes.ContentState(
            status: "Processing",
            updatedAt: Date()
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            print("[LiveActivity] Started tracking order \(orderNumber)")
        } catch {
            print("[LiveActivity] Failed to start: \(error)")
        }
    }
    
    func updateOrderStatus(_ status: String) {
        Task {
            let state = OrderStatusAttributes.ContentState(
                status: status,
                updatedAt: Date()
            )
            await currentActivity?.update(.init(state: state, staleDate: nil))
            
            if status == "Delivered" || status == "Cancelled" {
                await currentActivity?.end(.init(state: state, staleDate: nil), dismissalPolicy: .after(.now + 300))
                currentActivity = nil
            }
        }
    }
    
    func endTracking() {
        Task {
            if let activity = currentActivity {
                let state = OrderStatusAttributes.ContentState(
                    status: "Delivered",
                    updatedAt: Date()
                )
                await activity.end(.init(state: state, staleDate: nil), dismissalPolicy: .immediate)
                currentActivity = nil
            }
        }
    }
    
    var isTracking: Bool {
        currentActivity != nil
    }
}
