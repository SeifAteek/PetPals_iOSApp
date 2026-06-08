import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = ProfileSetupViewModel()
    let initialProfile: Profile?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                PremiumScreenHeader(
                    eyebrow: L10n.profileSetupEyebrow,
                    title: L10n.profileSetupTitle,
                    subtitle: L10n.profileSetupSubtitle
                )

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red.opacity(0.9))
                        .font(Theme.Fonts.body(Typography.caption))
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    fieldLabel(L10n.displayName)
                    CustomTextField(placeholder: L10n.profileNamePlaceholder, text: $viewModel.userName)

                    fieldLabel(L10n.email)
                    CustomTextField(
                        placeholder: L10n.profileEmailPlaceholder,
                        text: $viewModel.email,
                        keyboardType: .emailAddress
                    )

                    fieldLabel(L10n.phone)
                    CustomTextField(
                        placeholder: L10n.profilePhonePlaceholder,
                        text: $viewModel.phoneNumber,
                        keyboardType: .phonePad
                    )
                }

                PrimaryButton(
                    title: L10n.profileSetupContinue,
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.saveProfile(coordinator: coordinator)
                }
                .padding(.top, Spacing.xs)
            }
            .padding(Spacing.lg)
        }
        .dismissKeyboardOnSwipe()
        .petPalsScreenBackground()
        .onAppear {
            if let profile = initialProfile {
                viewModel.loadInitialData(profile: profile)
            }
        }
    }

    @ViewBuilder
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.Fonts.label(Typography.caption, weight: .semibold))
            .foregroundStyle(Theme.textSecondary)
    }
}

#Preview {
    ProfileSetupView(initialProfile: nil)
        .environmentObject(AppCoordinator())
}
