import Foundation

protocol NFCServiceProtocol {
    func scanCollar() async throws -> String
}

protocol LocationTrackingServiceProtocol {
    func startTracking(petId: UUID)
    func stopTracking(petId: UUID)
    func getCurrentLocation(petId: UUID) async throws -> (latitude: Double, longitude: Double)
}
