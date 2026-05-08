import SwiftUI
import Combine
import Foundation
import Supabase

@MainActor
final class ProfileSetupViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var userType: UserType = .adopter
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client = SupabaseClientManager.shared.client
    
    func loadInitialData(profile: Profile) {
        self.userName = profile.userName
        self.email = profile.email ?? ""
        self.phoneNumber = profile.phoneNumber ?? ""
        self.userType = profile.userType ?? .adopter
    }
    
    func saveProfile(coordinator: AppCoordinator) {
        guard !userName.isEmpty else {
            errorMessage = "Name cannot be empty"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let session = try? await client.auth.session else {
                    throw NSError(domain: "ProfileSetup", code: 401, userInfo: [NSLocalizedDescriptionKey: "User session expired"])
                }
                let userId = session.user.id
                
                let existingProfile: Profile = try await client.database
                    .from("profiles")
                    .select()
                    .eq("user_id", value: userId.uuidString.lowercased())
                    .single()
                    .execute()
                    .value
                
                let updatedProfile = Profile(
                    userId: userId,
                    userName: userName,
                    email: email.isEmpty ? nil : email,
                    phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                    userType: userType,
                    avatarUrl: existingProfile.avatarUrl
                )
                
                try await client.database
                    .from("profiles")
                    .update(updatedProfile)
                    .eq("user_id", value: userId.uuidString.lowercased())
                    .execute()
                
                isLoading = false
                coordinator.switchRoot(to: .mainTabs)
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
