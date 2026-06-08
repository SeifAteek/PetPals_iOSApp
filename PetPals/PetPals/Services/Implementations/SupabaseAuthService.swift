import Foundation
import Supabase

final class SupabaseAuthService: AuthServiceProtocol {
    private let client = SupabaseClientManager.shared.client

    func login(email: String, password: String) async throws -> Profile {
        _ = try await client.auth.signIn(email: email, password: password)
        let session = try await requireSession()
        return try await getProfile(userId: session.user.id)
    }

    func register(email: String, password: String, userName: String, type: UserType) async throws -> Profile {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: [
                "user_name": .string(userName),
                "user_type": .string(type.rawValue),
            ]
        )

        let userId = response.user.id

        // When email confirmation is off, signUp returns a session; otherwise sign in now.
        if response.session == nil {
            do {
                _ = try await client.auth.signIn(email: email, password: password)
            } catch {
                throw NSError(
                    domain: "AuthService",
                    code: 403,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Account created. Confirm your email if required, then log in with the same password.",
                    ]
                )
            }
        }

        _ = try await requireSession()

        let profile = Profile(
            userId: userId,
            userName: userName,
            email: email,
            phoneNumber: nil,
            userType: type,
            avatarUrl: nil
        )

        // Upsert so we work whether `handle_new_user` trigger or client created the row.
        try await client.database
            .from("profiles")
            .upsert(profile, onConflict: "user_id")
            .execute()

        return try await getProfile(userId: userId)
    }

    func logout() async throws {
        try await client.auth.signOut()
    }

    func getCurrentUser() async throws -> Profile? {
        do {
            let session = try await client.auth.session
            return try await getProfile(userId: session.user.id)
        } catch {
            return nil
        }
    }

    func getProfile(userId: UUID) async throws -> Profile {
        let profile: Profile = try await client.database
            .from("profiles")
            .select()
            .eq("user_id", value: userId.uuidString.lowercased())
            .single()
            .execute()
            .value
        return profile
    }

    func uploadProfileImage(data: Data, fileName: String) async throws -> String {
        let storage = client.storage.from("pet_files")
        let path = "avatars/\(fileName)"

        try await storage.upload(
            path: path,
            file: data,
            options: FileOptions(contentType: "image/jpeg", upsert: true)
        )

        let url = try storage.getPublicURL(path: path)
        return url.absoluteString
    }

    func updateProfile(_ profile: Profile) async throws {
        try await client.database
            .from("profiles")
            .upsert(profile, onConflict: "user_id")
            .execute()
    }

    private func requireSession() async throws -> Session {
        do {
            return try await client.auth.session
        } catch {
            throw NSError(
                domain: "AuthService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Not signed in. Please log in again."]
            )
        }
    }
}
