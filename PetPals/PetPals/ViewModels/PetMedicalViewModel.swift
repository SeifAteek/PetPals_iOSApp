import Foundation
import Combine
import SwiftUI

@MainActor
final class PetMedicalViewModel: ObservableObject {
    let petId: UUID
    @Published var records: [MedicalRecord] = []
    @Published var collar: SmartCollar?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSyncingCollar = false
    @Published var simulatedNFCSuccess = false
    
    private let petService: PetServiceProtocol
    
    init(petId: UUID, petService: PetServiceProtocol = DependencyContainer.shared.petService) {
        self.petId = petId
        self.petService = petService
    }
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                async let fetchRecords = petService.fetchMedicalRecords(for: petId)
                async let fetchCollar = petService.fetchSmartCollar(for: petId)
                
                let (recs, col) = try await (fetchRecords, fetchCollar)
                
                self.records = recs
                self.collar = col
                
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func simulateNFCSync() {
        isSyncingCollar = true
        errorMessage = nil
        
        Task {
            do {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 2_000_000_000)
                
                let serial = "SC-\(UUID().uuidString.prefix(8))"
                try await petService.syncSmartCollar(serialNumber: serial, petId: petId)
                
                // Reload
                self.collar = try await petService.fetchSmartCollar(for: petId)
                
                self.isSyncingCollar = false
                self.simulatedNFCSuccess = true
            } catch {
                self.errorMessage = error.localizedDescription
                self.isSyncingCollar = false
            }
        }
    }
}
