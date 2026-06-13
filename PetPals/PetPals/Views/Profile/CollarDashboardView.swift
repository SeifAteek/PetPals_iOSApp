import SwiftUI
import MapKit

/// Smart-collar dashboard — driven entirely by live collar data.
/// Heart rate / battery / connection come from `BluetoothManager` (the real BLE collar feed),
/// "Near" uses the radar (BLE RSSI proximity) and "Far" plots the collar's actual last-known
/// location on the map. NFC scanning links the physical collar.
struct CollarDashboardView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var collarSession = CollarSession.shared
    let petId: UUID
    /// Shown when pushed onto a navigation stack; hidden when hosted as a bottom-nav tab.
    var showsBackButton: Bool = true

    // Live collar feed (BLE)
    @StateObject private var bluetooth = BluetoothManager()

    @State private var pet: Pet?
    @State private var collar: SmartCollar?
    @State private var locationRange = "near"   // near | far

    // Radar / map presentation
    @State private var showRadar = false
    @State private var showFullMap = false

    // Far-location (actual collar coordinates via the mesh network)
    @State private var sighting: SightingLocation?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var isLocating = true

    // NFC tag programming
    @State private var showCopied = false

    private var collarName: String {
        if let pet { return "\(pet.name)'s collar" }
        if let name = collarSession.pairedPetName { return "\(name)'s collar" }
        return "Smart collar"
    }

    private var isConnected: Bool { bluetooth.connectionState == .connected }
    private var hasBPM: Bool { bluetooth.currentBPM > 0 }

    private var connection: (text: String, color: Color) {
        switch bluetooth.connectionState {
        case .connected: return ("Connected", Theme.statusHealthy)
        case .searching: return ("Scanning…", Theme.statusWarn)
        case .disconnected: return ("Disconnected", Theme.textSecondary)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            collarHeader
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.md) {
                    heartRateHero
                    deviceStatusCard
                    locationSection
                    nfcSection
                }
                .padding(ScreenLayout.horizontalPadding)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .petPalsScreenBackground()
        .navigationBarHidden(true)
        .onAppear { bluetooth.startScanning() }
        .onDisappear { bluetooth.cancelPeripheralConnection() }
        .task {
            if pet == nil {
                pet = try? await DependencyContainer.shared.petService.fetchPetDetails(id: petId)
                if let pet { collarSession.pair(petId: pet.petId, petName: pet.name) }
            }
            collar = try? await DependencyContainer.shared.petService.fetchSmartCollar(for: petId)
            MeshNetworkManager.shared.startMeshNetwork()
            await loadLastLocation()
        }
        .fullScreenCover(isPresented: $showRadar) {
            RadarView(bluetoothManager: bluetooth, assignedUUID: pet?.collarUUID)
        }
        .sheet(isPresented: $showFullMap) {
            if let pet { GlobalMapView(pet: pet) }
        }
        .alert("Copied!", isPresented: $showCopied) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your pet's public profile URL has been copied. Paste it into NFC Tools (or any NFC writer app) to program the tag.")
        }
    }

    // MARK: - Header (back · pet name + connection)  — no settings icon

    private var collarHeader: some View {
        HStack(spacing: Spacing.sm) {
            if showsBackButton {
                Button { Haptic.light(); dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Theme.surface))
                        .overlay(Circle().stroke(Theme.borderDefault, lineWidth: 1.5))
                }
                .buttonStyle(MagneticPressStyle())
                .accessibilityLabel("Back")
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(collarName)
                    .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: 5) {
                    Circle().fill(connection.color).frame(width: 7, height: 7)
                    Text(connection.text)
                        .font(Theme.Fonts.label(Typography.micro, weight: .heavy))
                        .foregroundStyle(connection.color)
                }
            }
            Spacer()
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
        .padding(.vertical, Spacing.xs)
    }

    // MARK: - Heart rate hero (live bpm)

    private var heartRateHero: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(hasBPM ? "\(bluetooth.currentBPM)" : "--")
                            .font(Theme.Fonts.mono(46, weight: .bold))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                        Text("bpm")
                            .font(Theme.Fonts.mono(18, weight: .bold))
                            .foregroundStyle(PetPalsPalette.forest200)
                    }
                    Text("HEART RATE · RESTING")
                        .font(Theme.Fonts.label(Typography.micro, weight: .heavy))
                        .tracking(0.8)
                        .foregroundStyle(PetPalsPalette.forest200)
                }
                Spacer()
                heartStatusBadge
            }
            HeartbeatView(
                color: isConnected ? PetPalsPalette.coral400 : Color.white.opacity(0.3),
                bpm: hasBPM ? bluetooth.currentBPM : 76,
                height: 56,
                segmentWidth: 94,
                active: isConnected && hasBPM
            )
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(PetPalsPalette.forest700)
        }
        .animation(Motion.gentle, value: bluetooth.currentBPM)
    }

    @ViewBuilder
    private var heartStatusBadge: some View {
        if isConnected && hasBPM {
            PPBadge(text: "Normal", tone: .healthy, solid: true, icon: "checkmark")
        } else if bluetooth.connectionState == .searching {
            PPBadge(text: "Scanning", tone: .warn, solid: true)
        } else {
            PPBadge(text: "Offline", tone: .neutral, solid: true)
        }
    }

    // MARK: - Device status (name · connection · live battery)

    private var deviceStatusCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                PPIconTile(icon: "antenna.radiowaves.left.and.right", tint: Theme.forest, background: Theme.forestSoft, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(collarName)
                        .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(deviceSubtitle)
                        .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
                PPBadge(text: connection.text, tone: isConnected ? .healthy : .neutral, dot: true)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Battery", systemImage: "battery.75")
                        .font(Theme.Fonts.label(Typography.caption, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text(bluetooth.batteryLevel > 0 ? "\(bluetooth.batteryLevel)%" : "—")
                        .font(Theme.Fonts.mono(Typography.callout, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                        .contentTransition(.numericText())
                }
                batteryBar
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: Radius.lg, elevation: .resting)
    }

    private var deviceSubtitle: String {
        if let collar { return "Serial \(collar.serialNumber)" }
        if let uuid = pet?.collarUUID, !uuid.isEmpty { return "Tag \(uuid.prefix(8))" }
        return "PetPals Tracker"
    }

    private var batteryBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.surfaceWarm)
                Capsule()
                    .fill(bluetooth.batteryLevel < 20 ? Theme.statusCritical : Theme.statusHealthy)
                    .frame(width: geo.size.width * CGFloat(max(0, min(100, bluetooth.batteryLevel))) / 100)
            }
        }
        .frame(height: 8)
        .accessibilityLabel("Battery \(bluetooth.batteryLevel) percent")
    }

    // MARK: - Location (Near = radar · Far = actual map location)

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                sectionTitle("Location")
                Spacer()
                PPSegmentedTabs(
                    items: [(value: "near", label: "Near"), (value: "far", label: "Far")],
                    selection: $locationRange
                )
                .frame(width: 150)
            }

            if locationRange == "near" {
                nearRadarPanel
            } else {
                farMapPanel
            }
        }
    }

    // Near — live BLE proximity radar
    private var nearRadarPanel: some View {
        Button { Haptic.medium(); showRadar = true } label: {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: Spacing.xs) {
                    PPIconTile(icon: "dot.radiowaves.left.and.right", tint: Theme.coralDeep, background: Theme.coralSoft, size: 38)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Pet radar")
                            .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text(isConnected ? bluetooth.distanceText : "Searching for collar…")
                            .font(Theme.Fonts.body(Typography.caption, weight: .bold))
                            .foregroundStyle(bluetooth.isVeryClose ? Theme.statusHealthy : Theme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.textFaint)
                }
                // Signal-strength meter (RSSI)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.surfaceWarm)
                        Capsule()
                            .fill(Theme.coral)
                            .frame(width: geo.size.width * CGFloat(bluetooth.signalStrength))
                            .animation(Motion.gentle, value: bluetooth.signalStrength)
                    }
                }
                .frame(height: 8)
                Text("Tap to open the live radar")
                    .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                    .foregroundStyle(Theme.textFaint)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: Radius.lg, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }

    // Far — actual collar location on the map
    private var farMapPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: sighting.map { [$0] } ?? []) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        ZStack {
                            Circle().fill(Theme.coral).frame(width: 26, height: 26)
                                .shadow(color: Theme.shadowInk.opacity(0.3), radius: 4, y: 2)
                            Circle().fill(.white).frame(width: 9, height: 9)
                        }
                    }
                }
                .allowsHitTesting(false)

                if isLocating {
                    ProgressView()
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.sm))
                } else if sighting == nil {
                    Text("No location recorded yet")
                        .font(Theme.Fonts.body(Typography.caption, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.sm))
                }

                Button { Haptic.light(); showFullMap = true } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                        .frame(width: 34, height: 34)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Open full map")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(8)
            }
            .frame(height: 188)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .stroke(Theme.borderSubtle, lineWidth: 1)
            }

            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.coral)
                Text(lastSeenText)
                    .font(Theme.Fonts.body(Typography.caption, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    private var lastSeenText: String {
        guard let sighting else { return "Locating via PetPals network…" }
        return "Last update \(sighting.timestamp.formatted(.relative(presentation: .numeric)))"
    }

    // MARK: - Scan collar NFC (replaces collar settings)

    private var nfcSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionTitle("Smart collar")
            PrimaryButton(title: "Copy NFC tag code", icon: "doc.on.clipboard", action: copyNFCCode)
            Text("Copy the tag code, then paste it into NFC Tools (or any NFC writer app) to program the collar's tag.")
                .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func copyNFCCode() {
        let code = "https://petpals-kappa.vercel.app/pet?id=\(petId.uuidString)"
        UIPasteboard.general.string = code
        Haptic.success()
        showCopied = true
    }

    // MARK: - Helpers

    private func loadLastLocation() async {
        let uuid = pet?.collarUUID?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        do {
            let record: CollarSighting?
            if let uuid, !uuid.isEmpty {
                record = try await MeshNetworkManager.shared.fetchLastSighting(collarUUID: uuid)
            } else {
                record = try await MeshNetworkManager.shared.fetchLatestSighting()
            }
            if let record, record.lat != 0 || record.lon != 0 {
                let coord = CLLocationCoordinate2D(latitude: record.lat, longitude: record.lon)
                if CLLocationCoordinate2DIsValid(coord) {
                    sighting = SightingLocation(id: uuid ?? record.collarUuid, coordinate: coord, timestamp: record.seenAt)
                    region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                }
            }
        } catch {
            print("[Collar] location fetch failed: \(error)")
        }
        isLocating = false
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(Theme.Fonts.display(Typography.title3))
            .tracking(-0.3)
            .foregroundStyle(Theme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
