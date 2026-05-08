import Foundation
import CoreBluetooth
import CoreLocation
import Combine
import Supabase

// Codable model for the collar_sightings Supabase table
struct CollarSighting: Codable {
    let collarUuid: String
    let lat: Double
    let lon: Double
    let seenAt: Date
    
    enum CodingKeys: String, CodingKey {
        case collarUuid = "collar_uuid"
        case lat
        case lon
        case seenAt = "seen_at"
    }
}

extension Notification.Name {
    /// Posted after a collar sighting row is written to Supabase (`collar_uuid` in userInfo).
    static let petPalsCollarSightingUploaded = Notification.Name("petPalsCollarSightingUploaded")
}

class MeshNetworkManager: NSObject, ObservableObject, CBCentralManagerDelegate, CLLocationManagerDelegate {
    static let shared = MeshNetworkManager()
    
    private var centralManager: CBCentralManager!
    private var locationManager: CLLocationManager!
    
    // Throttle tracking: Dictionary mapping collarUUID to the last upload timestamp
    private var lastUploadedSighting: [String: Date] = [:]
    /// Minimum gap between Supabase uploads for the same collar (BLE can fire many times/sec).
    private let throttleInterval: TimeInterval = 1
    
    /// How often we push a local map preview (same device saw collar + has GPS) without waiting on network.
    private let localPreviewMinInterval: TimeInterval = 0.35
    private var lastLocalPreviewAt: [String: Date] = [:]
    
    /// BLE saw this collar but we did not have a GPS fix yet — upload after `requestLocation()` delivers.
    private var pendingCollarUUID: String?
    
    @Published var isRunning = false
    
    var currentLocation: CLLocationCoordinate2D? {
        return locationManager?.location?.coordinate
    }
    
    private override init() {
        super.init()
        setupManagers()
    }
    
    private func setupManagers() {
        // We use a specific background queue for Bluetooth to ensure it runs independently of the main UI
        let bleQueue = DispatchQueue(label: "com.petpals.meshnetwork.ble", qos: .background)
        centralManager = CBCentralManager(delegate: self, queue: bleQueue, options: [CBCentralManagerOptionRestoreIdentifierKey: "com.petpals.mesh.restore"])
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // Info.plist does not declare background location; leaving this false avoids inconsistent fixes.
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = false
        // Fresh fixes for mesh uploads (50m filter meant `location` was often stale or nil when BLE fired).
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        requestPermissions()
    }
    
    func requestPermissions() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startMeshNetwork() {
        DispatchQueue.main.async {
            self.isRunning = true
            self.locationManager.startUpdatingLocation()
            self.locationManager.requestLocation()
            
            if self.centralManager.state == .poweredOn {
                self.startScanning()
            }
        }
    }
    
    func stopMeshNetwork() {
        DispatchQueue.main.async {
            self.isRunning = false
            self.locationManager.stopUpdatingLocation()
            self.centralManager.stopScan()
        }
    }
    
    private func startScanning() {
        // Continuous background scanning required for mesh network
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn && isRunning {
            startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        // Handle state restoration if the app was killed by iOS
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        if localName == "TestCollar" || peripheral.name == "TestCollar" {
            let collarUUID = peripheral.identifier.uuidString
            handleCollarSighting(collarUUID: collarUUID)
        }
    }
    
    // MARK: - Core Logic
    
    private func postLocalMapPreviewIfNeeded(collarUUID: String, lat: Double, lon: Double) {
        let now = Date()
        if let last = lastLocalPreviewAt[collarUUID], now.timeIntervalSince(last) < localPreviewMinInterval {
            return
        }
        lastLocalPreviewAt[collarUUID] = now
        NotificationCenter.default.post(
            name: .petPalsCollarSightingUploaded,
            object: nil,
            userInfo: [
                "collar_uuid": collarUUID.lowercased(),
                "lat": lat,
                "lon": lon,
                "local_preview": true,
            ]
        )
    }
    
    private func handleCollarSighting(collarUUID: String) {
        DispatchQueue.main.async {
            let normalized = collarUUID.lowercased()
            if let loc = self.locationManager.location, self.isUsableLocation(loc) {
                self.postLocalMapPreviewIfNeeded(
                    collarUUID: normalized,
                    lat: loc.coordinate.latitude,
                    lon: loc.coordinate.longitude
                )
                _ = self.enqueueUploadIfAllowed(collarUUID: normalized, location: loc)
            } else {
                self.pendingCollarUUID = normalized
                self.locationManager.requestLocation()
            }
        }
    }
    
    private func isUsableLocation(_ location: CLLocation) -> Bool {
        guard location.horizontalAccuracy >= 0 else { return false }
        return location.horizontalAccuracy <= 2500
    }
    
    /// Returns whether an upload was scheduled (throttled otherwise).
    @discardableResult
    private func enqueueUploadIfAllowed(collarUUID: String, location: CLLocation) -> Bool {
        let now = Date()
        if let lastUpload = lastUploadedSighting[collarUUID], now.timeIntervalSince(lastUpload) < throttleInterval {
            return false
        }
        lastUploadedSighting[collarUUID] = now
        Task {
            await uploadSighting(collarUUID: collarUUID, lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
        return true
    }
    
    private func uploadSighting(collarUUID: String, lat: Double, lon: Double) async {
        do {
            let client = SupabaseClientManager.shared.client
            let sighting = CollarSighting(collarUuid: collarUUID.lowercased(), lat: lat, lon: lon, seenAt: Date())
            print("🚀 [MESH] Uploading sighting for collar \(collarUUID) at lat: \(lat), lon: \(lon)")
            try await client.database
                .from("collar_sightings")
                .upsert(sighting, onConflict: "collar_uuid") // Keep only the latest sighting per collar
                .execute()
            print("✅ [MESH] Successfully recorded sighting in Supabase.")
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .petPalsCollarSightingUploaded,
                    object: nil,
                    userInfo: [
                        "collar_uuid": collarUUID.lowercased(),
                        "lat": lat,
                        "lon": lon,
                        "local_preview": false,
                    ]
                )
            }
        } catch {
            print("❌ [MESH] Failed to upload sighting: \(error)")
            DispatchQueue.main.async {
                self.lastUploadedSighting.removeValue(forKey: collarUUID.lowercased())
            }
        }
    }
    
    // MARK: - Fetch Last Known Sighting (for GlobalMapView)
    
    func fetchLastSighting(collarUUID: String) async throws -> CollarSighting? {
        let client = SupabaseClientManager.shared.client
        let key = collarUUID.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let results: [CollarSighting] = try await client.database
            .from("collar_sightings")
            .select()
            .eq("collar_uuid", value: key)
            .order("seen_at", ascending: false)
            .limit(1)
            .execute()
            .value
        return results.first
    }

    /// Fetches the most recent sighting across all collars.
    /// Useful when the caller doesn't yet have `pet.collarUUID` populated.
    func fetchLatestSighting() async throws -> CollarSighting? {
        let client = SupabaseClientManager.shared.client
        let results: [CollarSighting] = try await client.database
            .from("collar_sightings")
            .select()
            .order("seen_at", ascending: false)
            .limit(1)
            .execute()
            .value
        return results.first
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last, isUsableLocation(loc) else { return }
        guard let pending = pendingCollarUUID else { return }
        postLocalMapPreviewIfNeeded(collarUUID: pending, lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
        if enqueueUploadIfAllowed(collarUUID: pending, location: loc) {
            pendingCollarUUID = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        pendingCollarUUID = nil
        print("⚠️ [MESH] Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            if isRunning {
                manager.startUpdatingLocation()
            }
        }
    }
}
