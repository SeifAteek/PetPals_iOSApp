import SwiftUI

struct AuthMainView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = AuthViewModel()
    @State private var isLoginMode = true

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.lg) {
                brandHeader
                modeSwitcher
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(Theme.Fonts.body(Typography.caption))
                        .foregroundStyle(.red.opacity(0.9))
                        .padding(.horizontal, ScreenLayout.horizontalPadding)
                }
                formFields
                PrimaryButton(
                    title: isLoginMode ? L10n.logIn : L10n.createAccount,
                    isLoading: viewModel.isLoading
                ) {
                    if isLoginMode {
                        viewModel.login(coordinator: coordinator)
                    } else {
                        viewModel.register(coordinator: coordinator)
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)

                divider
                SocialLoginButton(platform: .google) {
                    viewModel.signInWithGoogle(coordinator: coordinator)
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
            }
            .padding(.top, Spacing.xxl)
            .padding(.bottom, Spacing.xl)
        }
        .dismissKeyboardOnSwipe()
        .keyboardDoneToolbar()
        .petPalsScreenBackground()
        .navigationBarHidden(true)
    }

    private var brandHeader: some View {
        VStack(spacing: Spacing.sm) {
            PetPalsLogoView(height: 72)
            Text(L10n.premiumCareTagline)
                .font(Theme.Fonts.body(Typography.callout))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var modeSwitcher: some View {
        HStack(spacing: 4) {
            modeButton(title: L10n.logIn, isSelected: isLoginMode) {
                withAnimation(Motion.spring) { isLoginMode = true }
            }
            modeButton(title: L10n.signUp, isSelected: !isLoginMode) {
                withAnimation(Motion.spring) { isLoginMode = false }
            }
        }
        .padding(4)
        .glassCard(cornerRadius: Radius.md, elevation: .resting)
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    private var formFields: some View {
        VStack(spacing: Spacing.sm) {
            if !isLoginMode {
                HStack(spacing: Spacing.sm) {
                    CustomTextField(placeholder: L10n.firstName, text: $viewModel.firstName, iconName: "person.fill")
                    CustomTextField(placeholder: L10n.lastName, text: $viewModel.lastName, iconName: "person.fill")
                }
            }
            CustomTextField(placeholder: L10n.email, text: $viewModel.email, iconName: "envelope.fill", keyboardType: .emailAddress)
            CustomTextField(placeholder: L10n.password, text: $viewModel.password, iconName: "lock.fill", isSecure: true)
            if !isLoginMode {
                CustomTextField(placeholder: L10n.confirmPassword, text: $viewModel.confirmPassword, iconName: "lock.fill", isSecure: true)
            }
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    private var divider: some View {
        HStack {
            Rectangle().fill(Theme.textSecondary.opacity(0.2)).frame(height: 1)
            Text(L10n.orContinueWith)
                .font(Theme.Fonts.label(Typography.caption))
                .foregroundStyle(Theme.textSecondary)
            Rectangle().fill(Theme.textSecondary.opacity(0.2)).frame(height: 1)
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    private func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            Haptic.selection()
            action()
        }) {
            Text(title)
                .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(isSelected ? Theme.textOnBrand : Theme.textSecondary)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                            .fill(Theme.brandGradient)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AuthMainView()
        .environmentObject(AppCoordinator())
}
