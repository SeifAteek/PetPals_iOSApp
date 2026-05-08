import Foundation
import Supabase

final class SupabasePetService: PetServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func fetchPets() async throws -> [Pet] {
        let pets: [Pet] = try await client.database
            .from("pets")
            .select()
            .execute()
            .value
        return pets
    }
    
    func fetchAvailablePets() async throws -> [Pet] {
        let pets: [Pet] = try await client.database
            .from("pets")
            .select()
            .eq("status", value: "Available")
            .execute()
            .value
        return pets
    }
    
    func fetchUserPets(userId: UUID) async throws -> [Pet] {
        let pets: [Pet] = try await client.database
            .from("pets")
            .select()
            .eq("owner_id", value: userId.uuidString.lowercased())
            .execute()
            .value
        return pets
    }
    
    func fetchPets(by species: String) async throws -> [Pet] {
        let pets: [Pet] = try await client.database
            .from("pets")
            .select()
            .eq("species", value: species)
            .execute()
            .value
        return pets
    }
    
    func fetchPetDetails(id: UUID) async throws -> Pet {
        let pet: Pet = try await client.database
            .from("pets")
            .select()
            .eq("pet_id", value: id.uuidString.lowercased())
            .single()
            .execute()
            .value
        return pet
    }
    
    func addPet(_ pet: Pet) async throws {
        try await client.database
            .from("pets")
            .insert(pet)
            .execute()
    }
    
    func updatePet(_ pet: Pet) async throws {
        try await client.database
            .from("pets")
            .update(pet)
            .eq("pet_id", value: pet.petId.uuidString.lowercased())
            .execute()
    }
    
    func deletePet(id: UUID) async throws {
        try await client.database
            .from("pets")
            .delete()
            .eq("pet_id", value: id.uuidString.lowercased())
            .execute()
    }
    
    func fetchMedicalRecords(for petId: UUID) async throws -> [MedicalRecord] {
        let records: [MedicalRecord] = try await client.database
            .from("medical_records")
            .select()
            .eq("pet_id", value: petId.uuidString.lowercased())
            .order("visit_date", ascending: false)
            .execute()
            .value
        return records
    }
    
    func fetchSmartCollar(for petId: UUID) async throws -> SmartCollar? {
        let collars: [SmartCollar] = try await client.database
            .from("smart_collars")
            .select()
            .eq("pet_id", value: petId.uuidString.lowercased())
            .execute()
            .value
        return collars.first
    }
    
    func syncSmartCollar(serialNumber: String, petId: UUID) async throws {
        // Upsert smart collar
        let collar = SmartCollar(
            collarId: UUID(),
            petId: petId,
            serialNumber: serialNumber,
            lastSyncTime: Date()
        )
        // Upsert by serial number since it's unique
        try await client.database
            .from("smart_collars")
            .upsert(collar, onConflict: "serial_number")
            .execute()
    }
    
    func uploadPetImage(data: Data, fileName: String) async throws -> String {
        let storage = client.storage.from("pet_files")
        let path = "pets/\(fileName)"
        
        try await storage.upload(
            path: path,
            file: data,
            options: FileOptions(contentType: "image/jpeg", upsert: true)
        )
        
        let url = try storage.getPublicURL(path: path)
        return url.absoluteString
    }
}
