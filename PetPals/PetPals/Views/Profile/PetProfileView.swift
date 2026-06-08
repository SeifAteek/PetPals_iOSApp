import SwiftUI

struct PetProfileView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let petId: UUID
    
    @State private var pet: Pet? = nil
    @State private var isLoading = true
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var isOwner: Bool = true
    @State private var ownerProfile: Profile? = nil
    @State private var showRemindersAlert = false
    
    var body: some View {
        ScrollView {
            if isLoading {
                VStack { ProgressView() }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
            } else if let pet = pet {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Header (standardized crop)
                    ZStack(alignment: .bottom) {
                        StandardPetPhoto(pet: pet, style: .profileHero)
                            .id(pet.avatarUrl ?? "")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(pet.name)
                                    .font(Theme.Fonts.primaryFont(size: 26, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Button(action: {
                                    coordinator.push(.editPet(pet: pet))
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(Theme.primary)
                                }
                            }
                            
                            HStack {
                                Text(pet.breed ?? pet.species ?? "Companion")
                                    .font(Theme.Fonts.primaryFont(size: 16))
                                    .foregroundColor(Theme.textSecondary)
                                Spacer()
                                Text(pet.status?.rawValue ?? "Active")
                                    .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(20)
                        .background(Theme.cardBackground)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .offset(y: 30)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    
                    // MARK: - Stats Row
                    HStack(spacing: 16) {
                        StatPill(title: "Age", value: "\(pet.age ?? 0) yrs")
                        StatPill(title: "Weight", value: "12 kg")
                        StatPill(title: "Gender", value: "Male")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 50)
                    
                    if isOwner {
                        // MARK: - Action Grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Management")
                                .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal, 24)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                Button(action: { coordinator.push(.medicalRecords(petId: pet.petId)) }) {
                                    ActionCard(icon: "heart.text.square", title: "Health Records", color: .blue)
                                }
                                Button(action: { coordinator.push(.activity) }) {
                                    ActionCard(icon: "calendar", title: "Appointments", color: .orange)
                                }
                                Button(action: { showRemindersAlert = true }) {
                                    ActionCard(icon: "bell", title: "Reminders", color: .purple)
                                }
                                Button(action: { coordinator.push(.editPet(pet: pet)) }) {
                                    ActionCard(icon: "gearshape", title: "Edit Details", color: .gray)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 24)
                        
                        // MARK: - TestCollar Smart Collar
                        TestCollarTelemetryView(bluetoothManager: bluetoothManager, pet: Binding(get: { self.pet! }, set: { self.pet = $0 }))
                    } else if let owner = ownerProfile {
                        // MARK: - Owner Contact Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Owner Contact Info")
                                .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal, 24)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(Theme.primary)
                                    Text(owner.userName)
                                        .font(Theme.Fonts.primaryFont(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.textPrimary)
                                }
                                if let phone = owner.phoneNumber {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(Theme.primary)
                                        Text(phone)
                                            .font(Theme.Fonts.primaryFont(size: 16))
                                            .foregroundColor(Theme.textPrimary)
                                    }
                                }
                                if let email = owner.email {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(Theme.primary)
                                        Text(email)
                                            .font(Theme.Fonts.primaryFont(size: 16))
                                            .foregroundColor(Theme.textPrimary)
                                    }
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.cardBackground)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .clawsyScreenBackground()
        .ignoresSafeArea(edges: .top)
        .task { await loadPet() }
        .onAppear {
            bluetoothManager.startScanning()
        }
        .onDisappear {
            bluetoothManager.cancelPeripheralConnection()
        }
        .alert("Reminders", isPresented: $showRemindersAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Pet reminders are coming soon! You'll be able to set feeding times, medication schedules, and vet appointments.")
        }
    }
    
    private func loadPet() async {
        do {
            let petService = DependencyContainer.shared.petService
            let fetchedPet = try await petService.fetchPetDetails(id: petId)
            self.pet = fetchedPet
            
            let authService = DependencyContainer.shared.authService
            if let currentUser = try await authService.getCurrentUser() {
                if currentUser.userId == fetchedPet.ownerId {
                    self.isOwner = true
                } else {
                    self.isOwner = false
                    if let ownerId = fetchedPet.ownerId {
                        self.ownerProfile = try await authService.getProfile(userId: ownerId)
                    }
                }
            }
        } catch {
            print("Failed to load pet or owner details: \(error)")
        }
        isLoading = false
    }
}

struct StatPill: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(Theme.Fonts.primaryFont(size: 12))
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

struct ActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    PetProfileView(petId: UUID())
        .environmentObject(AppCoordinator())
}

struct TestCollarTelemetryView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @Binding var pet: Pet
    @State private var showCopiedAlert = false
    @State private var showRadar = false
    @State private var showPairing = false
    @State private var showGlobalMap = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("TestCollar Telemetry")
                    .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                
                if bluetoothManager.connectionState == .connected {
                    HStack(spacing: 4) {
                        Image(systemName: "battery.100")
                            .foregroundColor(.green)
                        Text("\(bluetoothManager.batteryLevel)%")
                            .font(Theme.Fonts.primaryFont(size: 12, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                    }
                    .padding(.trailing, 4)
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(bluetoothManager.connectionState == .connected ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                        .opacity(bluetoothManager.connectionState == .searching ? 0.6 : 1.0)
                    Text(bluetoothManager.connectionState.description)
                        .font(Theme.Fonts.primaryFont(size: 12, weight: .semibold))
                        .foregroundColor(bluetoothManager.connectionState == .connected ? .green : .orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(bluetoothManager.connectionState == .connected ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
                )
            }
            
            if bluetoothManager.connectionState == .connected {
                HStack(spacing: 16) {
                    // BPM Monitor (Academic/Clinical UI)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "heart.text.square.fill")
                                .foregroundColor(.red)
                            Text("Heart Rate")
                                .font(Theme.Fonts.primaryFont(size: 12, weight: .medium))
                                .foregroundColor(Theme.textSecondary)
                                .textCase(.uppercase)
                        }
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(bluetoothManager.currentBPM)")
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.textPrimary)
                            Text("BPM")
                                .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Theme.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                    
                    // Radar Tracking
                    Button(action: { showRadar = true }) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "location.viewfinder")
                                    .foregroundColor(.purple)
                                Text("Tracker")
                                    .font(Theme.Fonts.primaryFont(size: 12, weight: .medium))
                                    .foregroundColor(Theme.textSecondary)
                                    .textCase(.uppercase)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Find Pet")
                                    .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                Text("Tap to open Radar")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.purple)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                    }
                    .sheet(isPresented: $showRadar) {
                        RadarView(bluetoothManager: bluetoothManager, assignedUUID: pet.collarUUID)
                    }
                }
            } else {
                HStack {
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("Awaiting telemetry stream...")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.vertical, 8)
            }
            
            // Global Map Button (Always visible)
            Button(action: { showGlobalMap = true }) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "globe.americas.fill")
                            .foregroundColor(.blue)
                        Text("Global Network")
                            .font(Theme.Fonts.primaryFont(size: 12, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                            .textCase(.uppercase)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Community Map")
                            .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Text("See last known crowdsourced location")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Theme.cardBackground)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            }
            .sheet(isPresented: $showGlobalMap) {
                GlobalMapView(pet: pet)
            }
            
            // NFC Program Button
            Button(action: {
                let code = "https://petpals-kappa.vercel.app/pet?id=\(pet.petId.uuidString)"
                UIPasteboard.general.string = code
                showCopiedAlert = true
            }) {
                HStack {
                    Image(systemName: "doc.on.clipboard.fill")
                    Text("Copy NFC Tag Code")
                        .font(Theme.Fonts.primaryFont(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your pet's public profile URL has been copied. Paste it into NFC Tools (or any NFC writer app) to program the tag.")
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground).opacity(0.6))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 40)
    }
}
