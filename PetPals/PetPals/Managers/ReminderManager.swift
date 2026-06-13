import Foundation
import UserNotifications

final class ReminderManager: NSObject {
    static let shared = ReminderManager()

    private let storageKey = "pet_reminders"
    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        // Notification-center delegate + permission are owned by `LocalNotificationManager`.
    }

    // MARK: - Permission

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - CRUD
    
    func saveReminder(_ reminder: PetReminder) {
        var all = allReminders()
        // Replace if exists, otherwise append
        if let idx = all.firstIndex(where: { $0.id == reminder.id }) {
            all[idx] = reminder
        } else {
            all.append(reminder)
        }
        persist(all)
        
        if reminder.isEnabled {
            scheduleNotification(for: reminder)
        }
    }
    
    func deleteReminder(id: UUID) {
        var all = allReminders()
        all.removeAll { $0.id == id }
        persist(all)
        cancelNotification(for: id)
    }
    
    func toggleReminder(id: UUID, enabled: Bool) {
        var all = allReminders()
        guard let idx = all.firstIndex(where: { $0.id == id }) else { return }
        all[idx].isEnabled = enabled
        persist(all)
        
        if enabled {
            scheduleNotification(for: all[idx])
        } else {
            cancelNotification(for: id)
        }
    }
    
    func reminders(for petId: UUID) -> [PetReminder] {
        allReminders().filter { $0.petId == petId }
    }
    
    func allReminders() -> [PetReminder] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([PetReminder].self, from: data)) ?? []
    }
    
    // MARK: - Persistence
    
    private func persist(_ reminders: [PetReminder]) {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // MARK: - Notification Scheduling
    
    private func scheduleNotification(for reminder: PetReminder) {
        // Remove any existing notification first
        cancelNotification(for: reminder.id)
        
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        // Group pet reminders under the "reminders" category in Notification Center and deep-link on tap.
        content.categoryIdentifier = AppNotificationCategory.reminders.threadIdentifier
        content.threadIdentifier = AppNotificationCategory.reminders.threadIdentifier
        content.userInfo = NotificationRoute.reminders.userInfo

        let trigger: UNNotificationTrigger
        
        if reminder.isRepeating {
            // Repeating: fire daily at the same hour & minute
            let comps = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        } else {
            // One-time: calculate the interval from now
            let interval = reminder.time.timeIntervalSinceNow
            guard interval > 0 else { return }
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        }
        
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelNotification(for id: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
