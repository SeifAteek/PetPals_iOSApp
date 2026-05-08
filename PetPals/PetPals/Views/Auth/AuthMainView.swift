import SwiftUI

struct AuthMainView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = AuthViewModel()
    @State private var isLoginMode = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                // MARK: - Logo & Title
                VStack(spacing: 12) {
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Theme.primary)
                    
                    Text("PetPals")
                        .font(Theme.Fonts.primaryFont(size: 32, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                }
                
                // MARK: - Mode Switcher
                HStack(spacing: 0) {
                    modeButton(title: "Log In", isSelected: isLoginMode) {
                        withAnimation { isLoginMode = true }
                    }
                    modeButton(title: "Sign Up", isSelected: !isLoginMode) {
                        withAnimation { isLoginMode = false }
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                
                // MARK: - Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(Theme.Fonts.primaryFont(size: 14))
                        .padding(.horizontal, 24)
                }
                
                // MARK: - Form Fields
                VStack(spacing: 16) {
                    if !isLoginMode {
                        HStack(spacing: 12) {
                            CustomTextField(placeholder: "First Name", text: $viewModel.firstName)
                            CustomTextField(placeholder: "Last Name", text: $viewModel.lastName)
                        }
                    }
                    
                    CustomTextField(placeholder: "Email Address", text: $viewModel.email, keyboardType: .emailAddress)
                    CustomTextField(placeholder: "Password", text: $viewModel.password, isSecure: true)
                    
                    if !isLoginMode {
                        CustomTextField(placeholder: "Confirm Password", text: $viewModel.confirmPassword, isSecure: true)
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Action Button
                PrimaryButton(
                    title: isLoginMode ? "Log In" : "Create Account",
                    isLoading: viewModel.isLoading
                ) {
                    if isLoginMode {
                        viewModel.login(coordinator: coordinator)
                    } else {
                        viewModel.register(coordinator: coordinator)
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Social Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.2))
                    Text("OR").font(.caption).foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.2))
                }
                .padding(.horizontal, 24)
                
                // MARK: - Social Login
                SocialLoginButton(platform: .google) {
                    viewModel.signInWithGoogle(coordinator: coordinator)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Theme.primary : Color.clear)
                .foregroundColor(isSelected ? .black : .gray)
                .cornerRadius(10)
        }
    }
}

#Preview {
    AuthMainView()
        .environmentObject(AppCoordinator())
}
