import Foundation
import CoreBluetooth
import Combine

class RadarManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var signalStrength: Double = 0.0
    @Published var distanceText: String = "Searching..."
    @Published var isBluetoothEnabled: Bool = false
    @Published var isVeryClose: Bool = false
    
    private var centralManager: CBCentralManager!
    private let targetPeripheralName = "TestCollar"
    private var timer: Timer?
    private var lastSeen: Date?
    var assignedUUID: String?
    
    override init() {
        super.init()
    }
    
    func startRadar() {
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .userInitiated))
        } else if centralManager.state == .poweredOn {
            startScanning()
        }
        
        // Timer to reset signal strength if we haven't seen the tracker recently
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                guard let self = self, let lastSeen = self.lastSeen else { return }
                if Date().timeIntervalSince(lastSeen) > 3.0 {
                    self.updateSignalStrength(rssi: -100) // Reset if lost
                }
            }
        }
    }
    
    func stopRadar() {
        centralManager?.stopScan()
        timer?.invalidate()
        timer = nil
        DispatchQueue.main.async {
            self.signalStrength = 0.0
            self.distanceText = "Searching..."
        }
    }
    
    private func startScanning() {
        // Continuous scan by allowing duplicate keys to get constant RSSI updates
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        DispatchQueue.main.async {
            self.distanceText = "Searching..."
            self.signalStrength = 0.0
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.isBluetoothEnabled = (central.state == .poweredOn)
        }
        if central.state == .poweredOn {
            startScanning()
        } else {
            DispatchQueue.main.async {
                self.signalStrength = 0.0
                self.distanceText = "Bluetooth Off"
                self.timer?.invalidate()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        if localName == targetPeripheralName || peripheral.name == targetPeripheralName {
            if let assigned = assignedUUID, peripheral.identifier.uuidString != assigned {
                return // Ignore other collars
            }
            lastSeen = Date()
            updateSignalStrength(rssi: RSSI.doubleValue)
        }
    }
    
    private func updateSignalStrength(rssi: Double) {
        // Map RSSI: -30 (close) to -100 (far)
        let maxRSSI: Double = -30.0
        let minRSSI: Double = -100.0
        
        var strength = (rssi - minRSSI) / (maxRSSI - minRSSI)
        strength = max(0.0, min(1.0, strength)) // Clamp between 0 and 1
        
        DispatchQueue.main.async {
            self.signalStrength = strength
            self.isVeryClose = strength >= 0.85
            
            if strength >= 0.9 {
                self.distanceText = "Right Here"
            } else if strength >= 0.6 {
                self.distanceText = "Hot"
            } else if strength >= 0.3 {
                self.distanceText = "Getting Warmer"
            } else if strength > 0.0 {
                self.distanceText = "Cold"
            } else {
                self.distanceText = "Searching..."
            }
        }
    }
}
