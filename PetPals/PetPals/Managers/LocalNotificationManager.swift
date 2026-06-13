import SwiftUI
import Combine
import UserNotifications

/// Central hub for the device's local notification center.
///
/// Responsibilities:
/// - Requests push-notification permission on first launch (if not already granted).
/// - Registers notification categories (messages, reminders, shopping, clinic, alerts).
/// - Pushes notifications to the OS notification center, grouped by category via `threadIdentifier`.
/// - Owns the in-app notification center store + the unread badge counter.
/// - Deep-links into the app when a notification is tapped.
@MainActor
final class LocalNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = LocalNotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let storageKey = "app_notifications_v1"
    private let seededKey = "app_notifications_seeded_v1"

    /// In-app notification feed (newest first).
    @Published private(set) var notifications: [AppNotification] = []
    /// Set when a notification is tapped — observed by the coordinator layer to navigate.
    @Published var pendingRoute: NotificationRoute?

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    private override init() {
        super.init()
        notifications = load()
        center.delegate = self
    }

    // MARK: - Setup

    /// Registers categories and requests permission on first launch if undecided.
    func configureOnLaunch() {
        registerCategories()
        seedDemoNotificationsIfNeeded()
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }
            guard settings.authorizationStatus == .notDetermined else {
                Task { @MainActor in self.refreshBadge() }
                return
            }
            self.center.requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
                if let error { print("Notification permission error: \(error.localizedDescription)") }
                Task { @MainActor in self.refreshBadge() }
            }
        }
    }

    private func registerCategories() {
        let categories = AppNotificationCategory.allCases.map {
            UNNotificationCategory(
                identifier: $0.threadIdentifier,
                actions: [],
                intentIdentifiers: [],
                options: []
            )
        }
        center.setNotificationCategories(Set(categories))
    }

    // MARK: - Posting

    /// Pushes a notification to the OS notification center *and* records it in the in-app feed.
    /// - Parameter after: delay in seconds before the OS delivers it (min 1s for a banner).
    func post(
        category: AppNotificationCategory,
        title: String,
        body: String,
        route: NotificationRoute? = nil,
        after seconds: TimeInterval? = nil
    ) {
        let item = AppNotification(category: category, title: title, body: body, route: route)
        record(item)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category.threadIdentifier
        content.threadIdentifier = category.threadIdentifier   // groups by category in Notification Center
        content.userInfo = (route?.userInfo ?? [:])
        content.badge = NSNumber(value: unreadCount)

        let trigger = seconds.map {
            UNTimeIntervalNotificationTrigger(timeInterval: max(1, $0), repeats: false)
        }
        center.add(UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger))
    }

    // MARK: - In-app feed

    func record(_ item: AppNotification) {
        notifications.insert(item, at: 0)
        persist()
        refreshBadge()
    }

    func notifications(in category: AppNotificationCategory) -> [AppNotification] {
        notifications.filter { $0.category == category }
    }

    func markRead(_ id: UUID) {
        guard let idx = notifications.firstIndex(where: { $0.id == id }) else { return }
        guard !notifications[idx].isRead else { return }
        notifications[idx].isRead = true
        persist()
        refreshBadge()
    }

    func markAllRead() {
        guard unreadCount > 0 else { return }
        for idx in notifications.indices { notifications[idx].isRead = true }
        persist()
        refreshBadge()
    }

    func clearAll() {
        notifications.removeAll()
        persist()
        refreshBadge()
        center.removeAllDeliveredNotifications()
    }

    private func refreshBadge() {
        center.setBadgeCount(unreadCount)
    }

    // MARK: - Deep-link handling

    /// Routes a tapped notification's deep-link via the coordinator.
    @MainActor
    func handle(route: NotificationRoute, coordinator: AppCoordinator) {
        switch route {
        case .messages: coordinator.push(.messages)
        case .orderHistory: coordinator.push(.orderHistory)
        case .reminders: coordinator.push(.activity)
        case .clinics: coordinator.push(.vets)
        case .settings: coordinator.push(.settings)
        case .community(let postId):
            if let postId { coordinator.push(.communityPostDetail(postId: postId)) }
        case .petProfile(let petId): coordinator.push(.petProfile(petId: petId))
        case .collar(let petId): coordinator.push(.collarDashboard(petId: petId))
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound, .badge])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let id = UUID(uuidString: response.notification.request.identifier)
        let route = NotificationRoute(userInfo: userInfo)
        Task { @MainActor in
            if let id { self.markRead(id) }
            if let route { self.pendingRoute = route }
        }
        completionHandler()
    }

    // MARK: - Persistence

    private func persist() {
        if let data = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() -> [AppNotification] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([AppNotification].self, from: data)) ?? []
    }

    // MARK: - Demo seed (so the center + badge are populated on first run)

    private func seedDemoNotificationsIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }
        UserDefaults.standard.set(true, forKey: seededKey)

        // Push one of each category to the device notification center (grouped by thread) and
        // mirror them into the in-app feed. Staggered so they land as a group, not a single burst.
        post(category: .clinic, title: "Biscuit's rabies booster",
             body: "Due in 6 days at Maple Vet. Tap to book a visit.", route: .clinics, after: 3)
        post(category: .shopping, title: "Your order is on the way",
             body: "Salmon & rice (Wild Harvest) ships today — track it here.", route: .orderHistory, after: 4)
        post(category: .messages, title: "Maple Vet clinic",
             body: "Dr. Okafor: Biscuit's results look great — all clear!", route: .messages, after: 5)
        post(category: .reminders, title: "Flea treatment — Friday",
             body: "Biscuit's flea treatment is due Friday. Auto-reorder is on.", route: .reminders, after: 6)
        post(category: .alerts, title: "New in PetPals",
             body: "Vet Tips of the Week and a donation drive just landed on Home.", route: .settings, after: 7)
    }
}
