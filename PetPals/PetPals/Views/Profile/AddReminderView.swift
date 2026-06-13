import SwiftUI

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    let petId: UUID
    let petName: String
    
    @State private var title = ""
    @State private var descriptionText = ""
    @State private var selectedType: ReminderType = .feeding
    @State private var selectedTime = Date()
    @State private var isRepeating = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                    TextField("e.g. Morning feeding", text: $title)
                        .font(Theme.Fonts.primaryFont(size: 16))
                        .padding(14)
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                }
                
                // MARK: - Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                    TextField("Optional details", text: $descriptionText, axis: .vertical)
                        .lineLimit(2...4)
                        .font(Theme.Fonts.primaryFont(size: 16))
                        .padding(14)
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                }
                
                // MARK: - Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type")
                        .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ReminderType.allCases, id: \.self) { type in
                                Button(action: { selectedType = type }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: type.icon)
                                            .font(.caption)
                                        Text(type.rawValue)
                                            .font(Theme.Fonts.primaryFont(size: 13, weight: .semibold))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(selectedType == type ? Theme.primary : Theme.cardBackground)
                                    .foregroundColor(selectedType == type ? .white : Theme.textPrimary)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                
                // MARK: - Time Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time")
                        .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                    
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                }
                
                // MARK: - Repeat Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Repeat Daily")
                            .font(Theme.Fonts.primaryFont(size: 16, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                        Text("Notification will fire every day at the selected time")
                            .font(Theme.Fonts.primaryFont(size: 12))
                            .foregroundColor(Theme.textSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: $isRepeating)
                        .labelsHidden()
                        .tint(Theme.primary)
                }
                .padding(14)
                .background(Theme.cardBackground)
                .cornerRadius(12)
                
                // MARK: - Save Button
                Button(action: saveReminder) {
                    Text("Save Reminder")
                        .font(Theme.Fonts.primaryFont(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(title.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.textFaint : Theme.primary)
                        .cornerRadius(14)
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .dismissKeyboardOnSwipe()
        .clawsyScreenBackground()
        .navigationTitle("New Reminder")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveReminder() {
        let reminder = PetReminder(
            petId: petId,
            petName: petName,
            title: title.trimmingCharacters(in: .whitespaces),
            body: descriptionText.trimmingCharacters(in: .whitespaces).isEmpty
                ? "\(selectedType.rawValue) reminder for \(petName)"
                : descriptionText.trimmingCharacters(in: .whitespaces),
            type: selectedType,
            time: selectedTime,
            isRepeating: isRepeating
        )
        ReminderManager.shared.saveReminder(reminder)
        dismiss()
    }
}
