import SwiftUI
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("app_preferred_language") private var appPreferredLanguage = "system"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // MARK: - Profile Header
                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity, alignment: .center).padding()
                } else if let user = viewModel.currentUser {
                    VStack(spacing: 16) {
                        PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                if viewModel.isUploadingImage {
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(Circle())
                                } else if let avatarUrl = user.avatarUrl, let url = ImageURL.from(avatarUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.1)
                                    }
                                    .id(avatarUrl)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.primary, lineWidth: 2))
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(Theme.primary.opacity(0.1))
                                            .frame(width: 100, height: 100)
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(Theme.primary)
                                    }
                                    .overlay(Circle().stroke(Theme.primary, lineWidth: 2))
                                }
                                
                                Image(systemName: "camera.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.primary)
                                    .background(Theme.cardBackground.clipShape(Circle()))
                                    .offset(x: 5, y: 5)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text(user.userName)
                                .font(Theme.Fonts.primaryFont(size: 24, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            if let email = user.email {
                                Text(email)
                                    .font(Theme.Fonts.primaryFont(size: 14))
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Edit profile")
                            .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        CustomTextField(placeholder: "Display name", text: $viewModel.editUserName)
                        CustomTextField(placeholder: "Email", text: $viewModel.editEmail, keyboardType: .emailAddress)
                        CustomTextField(placeholder: "Phone", text: $viewModel.editPhone, keyboardType: .phonePad)
                        PrimaryButton(title: "Save changes", isLoading: viewModel.isSavingProfile) {
                            viewModel.saveProfileEdits { updated in
                                coordinator.lastFetchedProfile = updated
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                
                // MARK: - Preferences
                    Text("Account")
                        .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Button(action: {
                        coordinator.push(.activity)
                    }) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard.fill")
                                .foregroundColor(Theme.primary)
                                .frame(width: 24)
                            Text("My Activity")
                                .font(Theme.Fonts.primaryFont(size: 16))
                                .foregroundColor(Theme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
                    }
                    
                    Button(action: {
                        coordinator.push(.donationHistory)
                    }) {
                        HStack {
                            Image(systemName: "heart.text.square.fill")
                                .foregroundColor(Theme.primary)
                                .frame(width: 24)
                            Text("Donation History")
                                .font(Theme.Fonts.primaryFont(size: 16))
                                .foregroundColor(Theme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
                    }
                    
                    Text("Preferences")
                        .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.top, 8)
                    
                    VStack(spacing: 0) {
                        Toggle(isOn: $isDarkMode) {
                            HStack(spacing: 12) {
                                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .foregroundColor(isDarkMode ? .indigo : .orange)
                                Text("Dark Mode")
                                    .font(Theme.Fonts.primaryFont(size: 16))
                                    .foregroundColor(Theme.textPrimary)
                            }
                        }
                        .padding()
                        .tint(Theme.primary)
                    }
                    .background(Theme.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.language)
                            .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Picker(L10n.language, selection: $appPreferredLanguage) {
                            Text(L10n.languageSystem).tag("system")
                            Text(L10n.languageEnglish).tag("en")
                            Text(L10n.languageArabic).tag("ar")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.top, 4)
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(Theme.Fonts.primaryFont(size: 14))
                }
                
                Spacer(minLength: 40)
                
                // MARK: - Logout
                Button(action: {
                    viewModel.logout(coordinator: coordinator)
                }) {
                    Text("Log Out")
                        .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(25)
                }
            }
            .padding(24)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(L10n.settings)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadCurrentUser()
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(AppCoordinator())
    }
}
