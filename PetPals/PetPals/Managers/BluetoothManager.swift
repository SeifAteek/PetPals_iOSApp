import Foundation
import CoreBluetooth
import Combine

enum ConnectionState {
    case disconnected
    case searching
    case connected
    
    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .searching: return "Scanning for TestCollar..."
        case .connected: return "Connected"
        }
    }
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var connectionState: ConnectionState = .disconnected
    @Published var currentBPM: Int = 0
    @Published var isTrackingActive: Bool = false
    @Published var batteryLevel: Int = 0
    
    // Radar properties
    @Published var signalStrength: Double = 0.0
    @Published var distanceText: String = "Searching..."
    @Published var isVeryClose: Bool = false
    private var rssiTimer: Timer?
    
    private var centralManager: CBCentralManager!
    private var pandaPeripheral: CBPeripheral?
    
    // NUS UUIDs
    private let nusServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    private let nusTxCharacteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    
    override init() {
        super.init()
        // Delay initialization of CBCentralManager until explicitly started to avoid unnecessary prompt
        // if user hasn't engaged with the view yet, but it will be initialized in startScanning.
    }
    
    func startScanning() {
        // Initialize if nil
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        
        connectionState = .searching
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func cancelPeripheralConnection() {
        if let peripheral = pandaPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        centralManager?.stopScan()
        pandaPeripheral = nil
        
        DispatchQueue.main.async {
            self.connectionState = .disconnected
            self.currentBPM = 0
            self.isTrackingActive = false
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if connectionState == .searching {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
        } else {
            DispatchQueue.main.async {
                self.connectionState = .disconnected
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        if localName == "TestCollar" || peripheral.name == "TestCollar" {
            updateSignalStrength(rssi: RSSI.doubleValue)
            centralManager.stopScan()
            pandaPeripheral = peripheral
            pandaPeripheral?.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.connectionState = .connected
        }
        peripheral.discoverServices([nusServiceUUID])
        
        // Start continuous RSSI reading
        DispatchQueue.main.async {
            self.rssiTimer?.invalidate()
            self.rssiTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
                self?.pandaPeripheral?.readRSSI()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        rssiTimer?.invalidate()
        rssiTimer = nil
        
        DispatchQueue.main.async {
            self.connectionState = .disconnected
            self.currentBPM = 0
            self.isTrackingActive = false
            self.signalStrength = 0.0
            self.distanceText = "Searching..."
            self.isVeryClose = false
        }
        
        // Reconnect if it was unintentionally disconnected but we want to remain connected
        // Wait, the rule is to NOT hold connection in background, but if we are still active in the view, we should reconnect.
        // Actually, startScanning() handles reconnect logic if we are still meant to be searching. Let's just go back to searching if it drops unexpectedly.
        // If we purposefully cancelled, `cancelPeripheralConnection` already sets us to disconnected.
        if connectionState != .disconnected {
            startScanning()
        }
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == nusServiceUUID {
                peripheral.discoverCharacteristics([nusTxCharacteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == nusTxCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == nusTxCharacteristicUUID {
            guard let data = characteristic.value,
                  let stringValue = String(data: data, encoding: .utf8) else {
                return
            }
            parseIncomingData(stringValue)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if error == nil {
            updateSignalStrength(rssi: RSSI.doubleValue)
        }
    }
    
    private func updateSignalStrength(rssi: Double) {
        let maxRSSI: Double = -30.0
        let minRSSI: Double = -100.0
        
        var strength = (rssi - minRSSI) / (maxRSSI - minRSSI)
        strength = max(0.0, min(1.0, strength))
        
        DispatchQueue.main.async {
            self.signalStrength = strength
            self.isVeryClose = strength >= 0.65
            
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
    
    private func parseIncomingData(_ dataString: String) {
        // Format: BPM:75|RADAR:ACTIVE|BAT:87
        let components = dataString.split(separator: "|")
        
        var parsedBPM: Int? = nil
        var parsedTracking: Bool? = nil
        var parsedBattery: Int? = nil
        
        for component in components {
            if component.hasPrefix("BPM:") {
                let bpmString = component.replacingOccurrences(of: "BPM:", with: "")
                if let bpm = Int(bpmString) {
                    parsedBPM = bpm
                }
            } else if component.hasPrefix("LOC:") || component.hasPrefix("RADAR:") {
                let locString = component.replacingOccurrences(of: "LOC:", with: "").replacingOccurrences(of: "RADAR:", with: "")
                parsedTracking = (locString == "ACTIVE")
            } else if component.hasPrefix("BAT:") {
                let batString = component.replacingOccurrences(of: "BAT:", with: "")
                if let bat = Int(batString) {
                    parsedBattery = bat
                }
            }
        }
        
        DispatchQueue.main.async {
            if let bpm = parsedBPM {
                self.currentBPM = bpm
            }
            if let tracking = parsedTracking {
                self.isTrackingActive = tracking
            }
            if let bat = parsedBattery {
                self.batteryLevel = bat
            }
        }
    }
}
