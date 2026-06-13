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
                                        .background(Theme.textFaint.opacity(0.1))
                                        .clipShape(Circle())
                                } else if let avatarUrl = user.avatarUrl, let url = ImageURL.from(avatarUrl) {
                                    CachedAsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                    } placeholder: {
                                        Theme.textFaint.opacity(0.1)
                                            .frame(width: 100, height: 100)
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
                        Text(L10n.editProfile)
                            .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        CustomTextField(placeholder: L10n.displayName, text: $viewModel.editUserName)
                        CustomTextField(placeholder: L10n.email, text: $viewModel.editEmail, keyboardType: .emailAddress)
                        CustomTextField(placeholder: L10n.phone, text: $viewModel.editPhone, keyboardType: .phonePad)
                        PrimaryButton(title: L10n.saveChanges, isLoading: viewModel.isSavingProfile) {
                            viewModel.saveProfileEdits { updated in
                                coordinator.lastFetchedProfile = updated
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                
                // MARK: - Preferences
                    Text(L10n.account)
                        .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Button(action: {
                        coordinator.push(.activity)
                    }) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard.fill")
                                .foregroundColor(Theme.primary)
                                .frame(width: 24)
                            Text(L10n.myActivity)
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
                            Text(L10n.donationHistory)
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
                    
                    Text(L10n.preferences)
                        .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.top, 8)
                    
                    VStack(spacing: 0) {
                        Toggle(isOn: $isDarkMode) {
                            HStack(spacing: 12) {
                                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .foregroundColor(isDarkMode ? Theme.statusInfo : Theme.statusWarn)
                                Text(L10n.darkMode)
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
                            Text(L10n.languageFrench).tag("fr")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.top, 4)
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(Theme.statusCritical)
                        .font(Theme.Fonts.primaryFont(size: 14))
                }
                
                Spacer(minLength: 40)
                
                // MARK: - Logout
                Button(action: {
                    viewModel.logout(coordinator: coordinator)
                }) {
                    Text(L10n.logOut)
                        .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                        .foregroundColor(Theme.statusCritical)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.statusCritical.opacity(0.1))
                        .cornerRadius(25)
                }
            }
            .padding(24)
        }
        .dismissKeyboardOnSwipe()
        .keyboardDoneToolbar()
        .petPalsScreenBackground()
        .navigationTitle(L10n.settings)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadCurrentUser()
        }
        .onChange(of: viewModel.currentUser?.avatarUrl) { _, _ in
            coordinator.lastFetchedProfile = viewModel.currentUser
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(AppCoordinator())
    }
}
