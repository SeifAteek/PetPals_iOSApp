import Foundation
import Supabase

final class SupabaseAuthService: AuthServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func login(email: String, password: String) async throws -> Profile {
        let _ = try await client.auth.signIn(email: email, password: password)
        guard let session = try? await client.auth.session else {
            throw NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve session"])
        }
        
        // Fetch profile from public.profiles table
        return try await getProfile(userId: session.user.id)
    }
    
    func register(email: String, password: String, userName: String, type: UserType) async throws -> Profile {
        let authResponse = try await client.auth.signUp(email: email, password: password)
        
        let profile = Profile(
            userId: authResponse.user.id,
            userName: userName,
            email: email,
            phoneNumber: nil,
            userType: type,
            avatarUrl: nil
        )
        
        // Insert into public.profiles table
        try await client.database
            .from("profiles")
            .insert(profile)
            .execute()
        
        return profile
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
            .update(profile)
            .eq("user_id", value: profile.userId.uuidString.lowercased())
            .execute()
    }
}
