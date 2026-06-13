import SwiftUI
import Combine

/// Tracks the currently paired smart collar so the app can surface a Collar tab in the
/// bottom navigation only when a collar is paired. Persisted across launches.
@MainActor
final class CollarSession: ObservableObject {
    static let shared = CollarSession()

    private let petIdKey = "paired_collar_pet_id"
    private let petNameKey = "paired_collar_pet_name"

    @Published private(set) var pairedPetId: UUID?
    @Published private(set) var pairedPetName: String?

    var isPaired: Bool { pairedPetId != nil }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: petIdKey) {
            pairedPetId = UUID(uuidString: raw)
        }
        pairedPetName = UserDefaults.standard.string(forKey: petNameKey)
    }

    func pair(petId: UUID, petName: String) {
        pairedPetId = petId
        pairedPetName = petName
        UserDefaults.standard.set(petId.uuidString, forKey: petIdKey)
        UserDefaults.standard.set(petName, forKey: petNameKey)
    }

    func unpair() {
        pairedPetId = nil
        pairedPetName = nil
        UserDefaults.standard.removeObject(forKey: petIdKey)
        UserDefaults.standard.removeObject(forKey: petNameKey)
    }

    /// Adopts the first pet that already has a collar UUID, if nothing is paired yet.
    func adoptIfNeeded(from pets: [Pet]) {
        guard !isPaired else { return }
        if let pet = pets.first(where: { ($0.collarUUID?.isEmpty == false) }) {
            pair(petId: pet.petId, petName: pet.name)
        }
    }
}
