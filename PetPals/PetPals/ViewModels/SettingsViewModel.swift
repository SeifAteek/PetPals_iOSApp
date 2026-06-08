import Foundation
import Combine
import SwiftUI
import PhotosUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var currentUser: Profile?
    @Published var isLoading = false
    @Published var isUploadingImage = false
    @Published var isSavingProfile = false
    @Published var errorMessage: String?
    
    @Published var editUserName = ""
    @Published var editEmail = ""
    @Published var editPhone = ""
    
    // Image Selection
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet { Task { await handleImageSelection() } }
    }
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = DependencyContainer.shared.authService) {
        self.authService = authService
    }
    
    func loadCurrentUser() {
        isLoading = true
        Task {
            do {
                if let user = try await authService.getCurrentUser() {
                    self.currentUser = user
                    self.editUserName = user.userName
                    self.editEmail = user.email ?? ""
                    self.editPhone = user.phoneNumber ?? ""
                } else {
                    self.currentUser = nil
                }
                isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func handleImageSelection() async {
        guard let item = selectedItem, let currentUser = currentUser else { return }
        
        isUploadingImage = true
        errorMessage = nil
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                let fileName = "\(currentUser.userId.uuidString.lowercased()).jpg"
                let publicUrl = try await authService.uploadProfileImage(data: data, fileName: fileName)
                
                let updatedProfile = Profile(
                    userId: currentUser.userId,
                    userName: currentUser.userName,
                    email: currentUser.email,
                    phoneNumber: currentUser.phoneNumber,
                    userType: currentUser.userType,
                    avatarUrl: publicUrl
                )
                
                try await authService.updateProfile(updatedProfile)
                self.currentUser = updatedProfile
                self.editUserName = updatedProfile.userName
                self.editEmail = updatedProfile.email ?? ""
                self.editPhone = updatedProfile.phoneNumber ?? ""
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isUploadingImage = false
    }
    
    func saveProfileEdits(onSaved: ((Profile) -> Void)? = nil) {
        guard let user = currentUser else { return }
        let trimmedName = editUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Display name cannot be empty."
            return
        }
        isSavingProfile = true
        errorMessage = nil
        Task {
            do {
                let updated = Profile(
                    userId: user.userId,
                    userName: trimmedName,
                    email: editEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : editEmail.trimmingCharacters(in: .whitespacesAndNewlines),
                    phoneNumber: editPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : editPhone.trimmingCharacters(in: .whitespacesAndNewlines),
                    userType: user.userType,
                    avatarUrl: user.avatarUrl
                )
                try await authService.updateProfile(updated)
                self.currentUser = updated
                self.isSavingProfile = false
                onSaved?(updated)
            } catch {
                self.errorMessage = error.localizedDescription
                self.isSavingProfile = false
            }
        }
    }
    
    func logout(coordinator: AppCoordinator) {
        Task {
            do {
                try await authService.logout()
                currentUser = nil
                editUserName = ""
                editEmail = ""
                editPhone = ""
                coordinator.signOut()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
