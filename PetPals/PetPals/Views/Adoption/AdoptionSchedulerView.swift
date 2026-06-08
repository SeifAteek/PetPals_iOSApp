import SwiftUI

struct AdoptionSchedulerView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = AdoptionViewModel()
    let petId: UUID

    @State private var isSubmitting = false
    @State private var submitError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text("Choose your preferred adoption date and time.")
                    .font(Theme.Fonts.primaryFont(size: 15))
                    .foregroundColor(Theme.textSecondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred Adoption Date & Time")
                        .font(Theme.Fonts.primaryFont(size: 13, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)

                    DatePicker(
                        "Select Date",
                        selection: $viewModel.preferredDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .tint(Theme.primary)
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred Time")
                        .font(Theme.Fonts.primaryFont(size: 13, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)

                    HStack(spacing: 12) {
                        ForEach(viewModel.timeOptions, id: \.self) { time in
                            let isSelected = viewModel.preferredTime == time
                            Button(action: { viewModel.preferredTime = time }) {
                                Text(time)
                                    .font(Theme.Fonts.primaryFont(size: 14, weight: isSelected ? .bold : .regular))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(isSelected ? Theme.primary : Theme.cardBackground)
                                    .foregroundColor(.black)
                                    .cornerRadius(14)
                                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                }

                if let error = submitError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(Theme.Fonts.primaryFont(size: 14))
                }

                PrimaryButton(
                    title: "Submit Application",
                    isLoading: isSubmitting
                ) {
                    submitApplication()
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .clawsyScreenBackground()
        .navigationTitle("Schedule Appointment")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let draft = coordinator.adoptionFormDraft, draft.petId == petId {
                viewModel.applyFormDraft(draft)
            }
        }
    }

    private func submitApplication() {
        guard let base = coordinator.adoptionFormDraft, base.petId == petId else {
            submitError = "Please complete the adoption form before scheduling."
            return
        }

        let draft = AdoptionFormDraft(
            petId: base.petId,
            firstName: base.firstName,
            lastName: base.lastName,
            email: base.email,
            phone: base.phone,
            address: base.address,
            city: base.city,
            zip: base.zip,
            housingType: base.housingType,
            hasOtherPets: base.hasOtherPets,
            preferredDate: viewModel.preferredDate,
            preferredTime: viewModel.preferredTime
        )
        viewModel.applyFormDraft(draft)

        if let error = viewModel.validateForm() {
            submitError = error
            return
        }

        isSubmitting = true
        submitError = nil

        Task {
            do {
                try await viewModel.submitAdoptionApplication(for: petId, draft: draft)
                isSubmitting = false
                coordinator.clearAdoptionFormDraft()
                coordinator.push(.adoptionConfirmation(petId: petId))
            } catch {
                isSubmitting = false
                submitError = error.localizedDescription
            }
        }
    }
}

#Preview {
    AdoptionSchedulerView(petId: UUID())
        .environmentObject(AppCoordinator())
}
