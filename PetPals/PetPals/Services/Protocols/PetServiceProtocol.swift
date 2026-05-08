import Foundation

protocol PetServiceProtocol {
    func fetchPets() async throws -> [Pet]
    func fetchAvailablePets() async throws -> [Pet]
    func fetchUserPets(userId: UUID) async throws -> [Pet]
    func fetchPets(by species: String) async throws -> [Pet]
    func fetchPetDetails(id: UUID) async throws -> Pet
    func addPet(_ pet: Pet) async throws
    func updatePet(_ pet: Pet) async throws
    func uploadPetImage(data: Data, fileName: String) async throws -> String
    func deletePet(id: UUID) async throws
    
    func fetchMedicalRecords(for petId: UUID) async throws -> [MedicalRecord]
    func fetchSmartCollar(for petId: UUID) async throws -> SmartCollar?
    func syncSmartCollar(serialNumber: String, petId: UUID) async throws
}
