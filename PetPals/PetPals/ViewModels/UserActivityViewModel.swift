import Foundation
import Combine
import Supabase

@MainActor
final class UserActivityViewModel: ObservableObject {
    @Published var applications: [PetApplication] = []
    @Published var appointments: [Appointment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client = SupabaseClientManager.shared.client
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = DependencyContainer.shared.authService) {
        self.authService = authService
    }
    
    func loadActivity() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let profile = try await authService.getCurrentUser() else {
                    throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Must be logged in"])
                }
                
                async let fetchApplications = fetchUserApplications(userId: profile.userId)
                async let fetchAppointments = fetchUserAppointments(userId: profile.userId)
                
                let (apps, apts) = try await (fetchApplications, fetchAppointments)
                
                self.applications = apps
                self.appointments = apts
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func fetchUserApplications(userId: UUID) async throws -> [PetApplication] {
        // Find adopter ID for this user
        let adopterProfiles: [AdopterProfile] = try await client.database
            .from("adopter_profiles")
            .select()
            .eq("user_id", value: userId.uuidString.lowercased())
            .execute()
            .value
            
        guard let adopterId = adopterProfiles.first?.adopterId else {
            return []
        }
        
        let apps: [PetApplication] = try await client.database
            .from("applications")
            .select()
            .eq("adopter_id", value: adopterId.uuidString.lowercased())
            .order("submission_date", ascending: false)
            .execute()
            .value
            
        return apps
    }
    
    private func fetchUserAppointments(userId: UUID) async throws -> [Appointment] {
        let apts: [Appointment] = try await client.database
            .from("appointments")
            .select()
            .eq("user_id", value: userId.uuidString.lowercased())
            .order("appointment_date", ascending: false)
            .execute()
            .value
            
        return apts
    }
}
