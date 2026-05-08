import SwiftUI
import Supabase
import Combine
import Foundation

@MainActor
final class AdoptionViewModel: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var filteredPets: [Pet] = []
    @Published var searchText = ""
    @Published var selectedSpecies: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Adoption form fields
    @Published var formFirstName = ""
    @Published var formLastName = ""
    @Published var formEmail = ""
    @Published var formPhone = ""
    @Published var formAddress = ""
    @Published var formCity = ""
    @Published var formZip = ""
    @Published var formHousingType = ""
    @Published var formHasOtherPets = false
    @Published var preferredDate: Date = Date().addingTimeInterval(86400)
    @Published var preferredTime = "Morning"
    
    let speciesOptions = ["All", "Dog", "Cat", "Bird", "Rabbit", "Other"]
    let timeOptions = ["Morning", "Afternoon", "Evening"]
    
    private let petService: PetServiceProtocol
    
    init(petService: PetServiceProtocol = DependencyContainer.shared.petService) {
        self.petService = petService
    }
    
    func loadPets() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                self.pets = try await petService.fetchAvailablePets()
                applyFilters()
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func applyFilters() {
        var result = pets
        if let species = selectedSpecies, species != "All" {
            result = result.filter { $0.species?.lowercased() == species.lowercased() }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.breed?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        filteredPets = result
    }
    
    func submitAdoptionApplication(for petId: UUID) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let client = SupabaseClientManager.shared.client
        guard let userId = try? await client.auth.session.user.id else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // 1. Check/Create Adopter Profile
        var adopterId: UUID
        let existingProfile: [AdopterProfile] = try await client.database
            .from("adopter_profiles")
            .select()
            .eq("user_id", value: userId.uuidString.lowercased())
            .execute()
            .value
            
        if let first = existingProfile.first {
            adopterId = first.adopterId
        } else {
            adopterId = UUID()
            let newProfile = AdopterProfile(
                adopterId: adopterId,
                userId: userId,
                housingType: formHousingType.isEmpty ? nil : formHousingType,
                hasOtherPets: formHasOtherPets
            )
            try await client.database
                .from("adopter_profiles")
                .insert(newProfile)
                .execute()
        }
        
        // 2. Simulate AI Compatibility Score
        let baseScore = Int.random(in: 75...90)
        let bonus = formHasOtherPets ? 5 : 0 // Simple mock AI logic
        let aiMatchScore = min(baseScore + bonus, 99)
        
        // 3. Insert Application
        let application = PetApplication(
            applicationId: UUID(),
            petId: petId,
            adopterId: adopterId,
            submissionDate: Date(),
            status: .underReview,
            matchScore: aiMatchScore
        )
        
        try await client.database
            .from("applications")
            .insert(application)
            .execute()
    }
}
