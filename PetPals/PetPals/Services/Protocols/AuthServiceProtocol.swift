import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> Profile
    func register(email: String, password: String, userName: String, type: UserType) async throws -> Profile
    func logout() async throws
    func getCurrentUser() async throws -> Profile?
    func getProfile(userId: UUID) async throws -> Profile
    func uploadProfileImage(data: Data, fileName: String) async throws -> String
    func updateProfile(_ profile: Profile) async throws
}
