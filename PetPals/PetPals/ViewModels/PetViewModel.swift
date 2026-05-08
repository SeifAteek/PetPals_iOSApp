import Foundation
import SwiftUI
import Combine
import Supabase
import PhotosUI

@MainActor
final class PetViewModel: ObservableObject {
    @Published var myPets: [Pet] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Add Pet form fields
    @Published var newPetName = ""
    @Published var newPetSpecies = "Dog"
    @Published var newPetBreed = ""
    @Published var newPetAge = ""
    @Published var newPetMedicalHistory = ""
    @Published var newPetWeight = ""
    @Published var newPetVaccinationStatus = ""
    @Published var newPetChipNumber = ""
    
    // Image selection
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet { Task { await loadSelectedImage() } }
    }
    @Published var selectedImageData: Data? = nil
    
    let speciesOptions = ["Dog", "Cat", "Bird", "Rabbit", "Other"]
    
    private let petService: PetServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        petService: PetServiceProtocol = DependencyContainer.shared.petService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.petService = petService
        self.authService = authService
    }
    
    func loadMyPets() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                guard let profile = try await authService.getCurrentUser() else {
                    self.myPets = []
                    self.isLoading = false
                    return
                }
                self.myPets = try await petService.fetchUserPets(userId: profile.userId)
                self.errorMessage = nil
                self.isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadSelectedImage() async {
        guard let item = selectedItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            selectedImageData = data
        }
    }
    
    func addNewPet(coordinator: AppCoordinator) {
        guard !newPetName.isEmpty else { return }
        isLoading = true
        
        Task {
            do {
                guard let userId = try await authService.getCurrentUser()?.userId else {
                    throw NSError(domain: "Pet", code: 401, userInfo: [NSLocalizedDescriptionKey: "You must be signed in to add a pet."])
                }
                let petId = UUID()
                var avatarUrl: String? = nil
                
                if let imageData = selectedImageData {
                    let fileName = "\(petId.uuidString.lowercased()).jpg"
                    avatarUrl = try await petService.uploadPetImage(data: imageData, fileName: fileName)
                }
                
                let pet = Pet(
                    petId: petId,
                    shelterId: nil,
                    name: newPetName,
                    breed: newPetBreed.isEmpty ? nil : newPetBreed,
                    age: Int(newPetAge),
                    status: .active,
                    medicalHistory: newPetMedicalHistory.isEmpty ? nil : newPetMedicalHistory,
                    clinicId: nil,
                    guestOwnerName: nil,
                    avatarUrl: avatarUrl,
                    guestPhone: nil,
                    species: newPetSpecies,
                    ownerId: userId,
                    createdAt: Date()
                )
                
                try await petService.addPet(pet)
                myPets.append(pet)
                isLoading = false
                coordinator.pop()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
