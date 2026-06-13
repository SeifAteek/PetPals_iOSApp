import SwiftUI

// MARK: - Notification categories (grouped in the device notification center by threadIdentifier)

enum AppNotificationCategory: String, Codable, CaseIterable, Identifiable {
    case messages
    case reminders   // clinic / appointment reminders
    case shopping    // order / shopping updates
    case clinic      // clinic & appointment alerts
    case alerts      // general app alerts

    var id: String { rawValue }

    /// Used as both the UNNotificationCategory identifier and the threadIdentifier so
    /// iOS groups notifications of the same category together in Notification Center.
    var threadIdentifier: String { "petpals.\(rawValue)" }

    var title: String {
        switch self {
        case .messages: return "Messages"
        case .reminders: return "Reminders"
        case .shopping: return "Shopping"
        case .clinic: return "Clinic"
        case .alerts: return "App alerts"
        }
    }

    var icon: String {
        switch self {
        case .messages: return "bubble.left.and.bubble.right.fill"
        case .reminders: return "bell.fill"
        case .shopping: return "bag.fill"
        case .clinic: return "stethoscope"
        case .alerts: return "sparkles"
        }
    }

    var tone: PPBadgeTone {
        switch self {
        case .messages: return .info
        case .reminders: return .warn
        case .shopping: return .forest
        case .clinic: return .healthy
        case .alerts: return .coral
        }
    }

    var accent: Color {
        switch self {
        case .messages: return Theme.statusInfo
        case .reminders: return Theme.statusWarn
        case .shopping: return Theme.forest
        case .clinic: return Theme.statusHealthy
        case .alerts: return Theme.coral
        }
    }

    var accentSoft: Color {
        switch self {
        case .messages: return Theme.statusInfoSoft
        case .reminders: return Theme.statusWarnSoft
        case .shopping: return Theme.forestSoft
        case .clinic: return Theme.statusHealthySoft
        case .alerts: return Theme.coralSoft
        }
    }
}

// MARK: - Deep-link target encoded into the notification payload (userInfo)

enum NotificationRoute: Equatable {
    case messages
    case orderHistory
    case reminders
    case clinics
    case settings
    case community(postId: UUID?)
    case petProfile(petId: UUID)
    case collar(petId: UUID)

    private static let key = "name"
    private static let idKey = "id"

    /// Serialize into a JSON-safe dictionary for `UNNotificationContent.userInfo`.
    var userInfo: [String: String] {
        switch self {
        case .messages: return [Self.key: "messages"]
        case .orderHistory: return [Self.key: "orderHistory"]
        case .reminders: return [Self.key: "reminders"]
        case .clinics: return [Self.key: "clinics"]
        case .settings: return [Self.key: "settings"]
        case .community(let id):
            var info = [Self.key: "community"]
            if let id { info[Self.idKey] = id.uuidString }
            return info
        case .petProfile(let id): return [Self.key: "petProfile", Self.idKey: id.uuidString]
        case .collar(let id): return [Self.key: "collar", Self.idKey: id.uuidString]
        }
    }

    init?(userInfo: [AnyHashable: Any]) {
        guard let name = userInfo[Self.key] as? String else { return nil }
        let id = (userInfo[Self.idKey] as? String).flatMap(UUID.init(uuidString:))
        switch name {
        case "messages": self = .messages
        case "orderHistory": self = .orderHistory
        case "reminders": self = .reminders
        case "clinics": self = .clinics
        case "settings": self = .settings
        case "community": self = .community(postId: id)
        case "petProfile": guard let id else { return nil }; self = .petProfile(petId: id)
        case "collar": guard let id else { return nil }; self = .collar(petId: id)
        default: return nil
        }
    }
}

// MARK: - In-app notification record (powers the in-app Notification Center)

struct AppNotification: Identifiable, Codable, Equatable {
    let id: UUID
    let category: AppNotificationCategory
    let title: String
    let body: String
    let date: Date
    var isRead: Bool
    /// Stored deep-link payload so tapping the in-app row routes the same way as the OS notification.
    let routeInfo: [String: String]

    init(
        id: UUID = UUID(),
        category: AppNotificationCategory,
        title: String,
        body: String,
        date: Date = Date(),
        isRead: Bool = false,
        route: NotificationRoute? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.body = body
        self.date = date
        self.isRead = isRead
        self.routeInfo = route?.userInfo ?? [:]
    }

    var route: NotificationRoute? { NotificationRoute(userInfo: routeInfo) }
}
