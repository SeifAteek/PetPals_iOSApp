import Foundation
import CoreLocation

final class CoreLocationTrackingService: NSObject, LocationTrackingServiceProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var currentLocations: [UUID: (latitude: Double, longitude: Double)] = [:]
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startTracking(petId: UUID) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking(petId: UUID) {
        locationManager.stopUpdatingLocation()
    }
    
    func getCurrentLocation(petId: UUID) async throws -> (latitude: Double, longitude: Double) {
        // Return last known location or a default if none
        return currentLocations[petId] ?? (latitude: 0, longitude: 0)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // In a real app, we would map this to the specific pet being tracked
        // For now, we update a global state
        print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
}
