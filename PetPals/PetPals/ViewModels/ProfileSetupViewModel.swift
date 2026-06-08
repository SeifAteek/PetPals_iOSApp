import SwiftUI
import Combine
import Foundation
import Supabase

private struct AdopterProfileRow: Codable {
    let adopterId: UUID
    enum CodingKeys: String, CodingKey {
        case adopterId = "adopter_id"
    }
}

private struct ProfileAvatarRow: Codable {
    let avatarUrl: String?
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
    }
}

private struct AdopterProfileInsert: Encodable {
    let userId: UUID
    let housingType: String?
    let hasOtherPets: Bool
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case housingType = "housing_type"
        case hasOtherPets = "has_other_pets"
    }
}

@MainActor
final class ProfileSetupViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientManager.shared.client

    func loadInitialData(profile: Profile) {
        userName = profile.userName
        email = profile.email ?? ""
        phoneNumber = profile.phoneNumber ?? ""
    }

    func saveProfile(coordinator: AppCoordinator) {
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty, !trimmedPhone.isEmpty else {
            errorMessage = L10n.profileSetupRequiredFields
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                guard let session = try? await client.auth.session else {
                    throw NSError(domain: "ProfileSetup", code: 401, userInfo: [NSLocalizedDescriptionKey: L10n.sessionExpired])
                }
                let userId = session.user.id

                let avatarRow: ProfileAvatarRow? = try? await client.database
                    .from("profiles")
                    .select("avatar_url")
                    .eq("user_id", value: userId.uuidString.lowercased())
                    .single()
                    .execute()
                    .value
                let existingAvatar = avatarRow?.avatarUrl

                let updatedProfile = Profile(
                    userId: userId,
                    userName: trimmedName,
                    email: trimmedEmail,
                    phoneNumber: trimmedPhone,
                    userType: .adopter,
                    avatarUrl: existingAvatar
                )

                try await client.database
                    .from("profiles")
                    .upsert(updatedProfile, onConflict: "user_id")
                    .execute()

                try await ensureAdopterProfile(userId: userId)

                isLoading = false
                coordinator.lastFetchedProfile = updatedProfile
                coordinator.switchRoot(to: .personalitySetup)
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func ensureAdopterProfile(userId: UUID) async throws {
        let existing: [AdopterProfileRow] = try await client.database
            .from("adopter_profiles")
            .select("adopter_id")
            .eq("user_id", value: userId.uuidString.lowercased())
            .execute()
            .value

        guard existing.isEmpty else { return }

        let row = AdopterProfileInsert(userId: userId, housingType: nil, hasOtherPets: false)
        try await client.database
            .from("adopter_profiles")
            .insert(row)
            .execute()
    }
}
