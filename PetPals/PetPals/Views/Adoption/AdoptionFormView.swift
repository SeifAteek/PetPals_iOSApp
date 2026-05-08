import SwiftUI

struct AdoptionFormView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = AdoptionViewModel()
    let petId: UUID
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Tell us about yourself so we can find the perfect match.")
                    .font(Theme.Fonts.primaryFont(size: 15))
                    .foregroundColor(Theme.textSecondary)
                
                Group {
                    fieldLabel("First Name")
                    CustomTextField(placeholder: "e.g. Sarah", text: $viewModel.formFirstName)
                    
                    fieldLabel("Last Name")
                    CustomTextField(placeholder: "e.g. Johnson", text: $viewModel.formLastName)
                    
                    fieldLabel("Email")
                    CustomTextField(placeholder: "your@email.com", text: $viewModel.formEmail, keyboardType: .emailAddress)
                    
                    fieldLabel("Phone Number")
                    CustomTextField(placeholder: "+1 (555) 000-0000", text: $viewModel.formPhone, keyboardType: .phonePad)
                    
                    fieldLabel("Home Address")
                    CustomTextField(placeholder: "123 Main Street", text: $viewModel.formAddress)
                    
                    fieldLabel("City")
                    CustomTextField(placeholder: "New York", text: $viewModel.formCity)
                    
                    fieldLabel("ZIP / Postal Code")
                    CustomTextField(placeholder: "10001", text: $viewModel.formZip, keyboardType: .numberPad)
                }
                
                fieldLabel("Housing Type")
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
                
                PrimaryButton(title: "Continue") {
                    coordinator.push(.adoptionScheduler(petId: petId))
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Adoption Form")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.Fonts.primaryFont(size: 13, weight: .semibold))
            .foregroundColor(Theme.textSecondary)
    }
}

#Preview {
    AdoptionFormView(petId: UUID())
        .environmentObject(AppCoordinator())
}
