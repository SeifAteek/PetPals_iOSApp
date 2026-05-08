import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = ProfileSetupViewModel()
    let initialProfile: Profile?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Complete Your Profile")
                    .font(Theme.Fonts.primaryFont(size: 28, weight: .bold))
                
                Text("Please fill in the missing details to personalize your PetPals experience.")
                    .font(Theme.Fonts.primaryFont(size: 15))
                    .foregroundColor(Theme.textSecondary)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(Theme.Fonts.primaryFont(size: 14))
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    fieldLabel("Full Name")
                    CustomTextField(placeholder: "e.g. Seif Ateek", text: $viewModel.userName)
                    
                    fieldLabel("Email Address")
                    CustomTextField(placeholder: "e.g. seif@example.com", text: $viewModel.email, keyboardType: .emailAddress)
                    
                    fieldLabel("Phone Number")
                    CustomTextField(placeholder: "e.g. +1 234 567 890", text: $viewModel.phoneNumber, keyboardType: .phonePad)
                    
                    fieldLabel("I am a...")
                    Picker("User Type", selection: $viewModel.userType) {
                        Text("Adopter").tag(UserType.adopter)
                        Text("Clinic").tag(UserType.clinic)
                        Text("Shelter").tag(UserType.shelter)
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 4)
                }
                
                PrimaryButton(
                    title: "Complete Profile",
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.saveProfile(coordinator: coordinator)
                }
                .padding(.top, 16)
            }
            .padding(24)
        }
        .background(Theme.background.ignoresSafeArea())
        .onAppear {
            if let profile = initialProfile {
                viewModel.loadInitialData(profile: profile)
            }
        }
    }
    
    @ViewBuilder
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.Fonts.primaryFont(size: 13, weight: .semibold))
            .foregroundColor(Theme.textSecondary)
    }
}

#Preview {
    ProfileSetupView(initialProfile: nil)
        .environmentObject(AppCoordinator())
}
