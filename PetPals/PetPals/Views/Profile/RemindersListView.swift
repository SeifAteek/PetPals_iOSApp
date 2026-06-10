import SwiftUI

struct RemindersListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let petId: UUID
    let petName: String
    
    @State private var reminders: [PetReminder] = []
    
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if reminders.isEmpty {
                    emptyState
                } else {
                    ForEach(reminders) { reminder in
                        reminderRow(reminder)
                    }
                }
            }
            .padding()
        }
        .clawsyScreenBackground()
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    coordinator.push(.addReminder(petId: petId, petName: petName))
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Theme.primary)
                        .font(.title3)
                }
            }
        }
        .onAppear { loadReminders() }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 60)
            
            Image(systemName: "bell.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(Theme.textSecondary.opacity(0.4))
            
            Text("No Reminders Yet")
                .font(Theme.Fonts.primaryFont(size: 20, weight: .bold))
                .foregroundColor(Theme.textPrimary)
            
            Text("Set up feeding, medication, vet visits and more for \(petName).")
                .font(Theme.Fonts.primaryFont(size: 15))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                coordinator.push(.addReminder(petId: petId, petName: petName))
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Reminder")
                        .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Theme.primary)
                .cornerRadius(14)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Reminder Row
    
    private func reminderRow(_ reminder: PetReminder) -> some View {
        HStack(spacing: 14) {
            // Type icon
            Image(systemName: reminder.type.icon)
                .font(.title3)
                .foregroundColor(colorForType(reminder.type))
                .frame(width: 40, height: 40)
                .background(colorForType(reminder.type).opacity(0.12))
                .cornerRadius(10)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(Theme.Fonts.primaryFont(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(timeFormatter.string(from: reminder.time))
                        .font(Theme.Fonts.primaryFont(size: 13))
                        .foregroundColor(Theme.textSecondary)
                    
                    if reminder.isRepeating {
                        HStack(spacing: 2) {
                            Image(systemName: "repeat")
                                .font(.caption2)
                            Text("Daily")
                                .font(Theme.Fonts.primaryFont(size: 11))
                        }
                        .foregroundColor(Theme.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.primary.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { newVal in
                    ReminderManager.shared.toggleReminder(id: reminder.id, enabled: newVal)
                    loadReminders()
                }
            ))
            .labelsHidden()
            .tint(Theme.primary)
        }
        .padding(14)
        .background(Theme.cardBackground)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                ReminderManager.shared.deleteReminder(id: reminder.id)
                loadReminders()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                ReminderManager.shared.deleteReminder(id: reminder.id)
                loadReminders()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func loadReminders() {
        reminders = ReminderManager.shared.reminders(for: petId)
    }
    
    private func colorForType(_ type: ReminderType) -> Color {
        switch type.color {
        case "orange": return .orange
        case "red": return .red
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        default: return .gray
        }
    }
}
