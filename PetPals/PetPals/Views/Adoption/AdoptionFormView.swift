import SwiftUI

struct AdoptionFormView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = AdoptionViewModel()
    let petId: UUID

    @State private var validationError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("Tell us about yourself so we can find the perfect match.")
                    .font(Theme.Fonts.primaryFont(size: 15))
                    .foregroundColor(Theme.textSecondary)

                Group {
                    requiredFieldLabel("First Name")
                    CustomTextField(placeholder: "e.g. Sarah", text: $viewModel.formFirstName)

                    requiredFieldLabel("Last Name")
                    CustomTextField(placeholder: "e.g. Johnson", text: $viewModel.formLastName)

                    requiredFieldLabel("Email")
                    CustomTextField(placeholder: "your@email.com", text: $viewModel.formEmail, keyboardType: .emailAddress)

                    requiredFieldLabel("Phone Number")
                    CustomTextField(placeholder: "+1 (555) 000-0000", text: $viewModel.formPhone, keyboardType: .phonePad)

                    requiredFieldLabel("Home Address")
                    CustomTextField(placeholder: "123 Main Street", text: $viewModel.formAddress)

                    requiredFieldLabel("City")
                    CustomTextField(placeholder: "New York", text: $viewModel.formCity)

                    requiredFieldLabel("ZIP / Postal Code")
                    CustomTextField(placeholder: "10001", text: $viewModel.formZip, keyboardType: .numberPad)
                }

                requiredFieldLabel("Housing Type")
                Picker("Housing Type", selection: $viewModel.formHousingType) {
                    Text("House").tag("House")
                    Text("Apartment").tag("Apartment")
                    Text("Condo").tag("Condo")
                    Text("Other").tag("Other")
                }
                .pickerStyle(.segmented)

                Toggle("I have other pets at home", isOn: $viewModel.formHasOtherPets)
                    .font(Theme.Fonts.primaryFont(size: 15))
                    .tint(Theme.primary)
                    .padding(.top, 4)

                if let validationError {
                    Text(validationError)
                        .font(Theme.Fonts.primaryFont(size: 14))
                        .foregroundColor(Theme.statusCritical)
                }

                PrimaryButton(title: "Continue") {
                    continueToScheduler()
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .dismissKeyboardOnSwipe()
        .keyboardDoneToolbar()
        .clawsyScreenBackground()
        .navigationTitle("Adoption Form")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let draft = coordinator.adoptionFormDraft, draft.petId == petId {
                viewModel.applyFormDraft(draft)
            }
        }
    }

    private func continueToScheduler() {
        if let error = viewModel.validateForm() {
            validationError = error
            return
        }
        validationError = nil
        coordinator.adoptionFormDraft = viewModel.makeFormDraft(petId: petId)
        coordinator.push(.adoptionScheduler(petId: petId))
    }

    @ViewBuilder
    private func requiredFieldLabel(_ text: String) -> some View {
        HStack(spacing: 2) {
            Text(text)
                .font(Theme.Fonts.primaryFont(size: 13, weight: .semibold))
                .foregroundColor(Theme.textSecondary)
            Text("*")
                .font(Theme.Fonts.primaryFont(size: 13, weight: .semibold))
                .foregroundColor(Theme.statusCritical)
        }
    }
}

#Preview {
    AdoptionFormView(petId: UUID())
        .environmentObject(AppCoordinator())
}
