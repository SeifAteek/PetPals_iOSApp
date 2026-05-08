import SwiftUI
import CoreBluetooth
import Combine

class CollarPairingManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var discoveredCollars: [CBPeripheral] = []
    @Published var isScanning = false
    
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        isScanning = true
        discoveredCollars.removeAll()
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        }
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn && isScanning {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        if localName == "TestCollar" || peripheral.name == "TestCollar" {
            DispatchQueue.main.async {
                if !self.discoveredCollars.contains(where: { $0.identifier == peripheral.identifier }) {
                    self.discoveredCollars.append(peripheral)
                }
            }
        }
    }
}

struct CollarPairingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var pairingManager = CollarPairingManager()
    let pet: Pet
    let onAssigned: (String) -> Void
    
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            VStack {
                if pairingManager.isScanning {
                    ProgressView("Searching for Smart Collars...")
                        .padding()
                }
                
                if pairingManager.discoveredCollars.isEmpty && !pairingManager.isScanning {
                    VStack(spacing: 16) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No collars found near you.\nMake sure it is powered on.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(pairingManager.discoveredCollars, id: \.identifier) { peripheral in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Smart Collar")
                                        .font(.headline)
                                    Text(peripheral.identifier.uuidString)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button("Assign") {
                                    Task {
                                        await assignCollar(uuid: peripheral.identifier.uuidString)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(isSaving)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Pair Collar for \(pet.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                pairingManager.startScanning()
            }
            .onDisappear {
                pairingManager.stopScanning()
            }
        }
    }
    
    private func assignCollar(uuid: String) async {
        isSaving = true
        do {
            var updatedPet = pet
            updatedPet.collarUUID = uuid.lowercased()
            let petService = DependencyContainer.shared.petService
            try await petService.updatePet(updatedPet)
            
            DispatchQueue.main.async {
                onAssigned(uuid)
                dismiss()
            }
        } catch {
            print("Failed to assign collar: \(error)")
            DispatchQueue.main.async {
                isSaving = false
            }
        }
    }
}
