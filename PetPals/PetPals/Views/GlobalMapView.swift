import SwiftUI
import MapKit
import Combine

// Model for map pin: stable `id` (collar key) so the annotation updates in place instead of a new UUID every fetch.
struct SightingLocation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
}

struct GlobalMapView: View {
    let pet: Pet
    @Environment(\.dismiss) var dismiss
    
    @State private var resolvedPet: Pet
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to SF
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var sighting: SightingLocation?
    @State private var isLoading = true
    @State private var noSightingFound = false
    
    init(pet: Pet) {
        self.pet = pet
        _resolvedPet = State(initialValue: pet)
    }
    var body: some View {
        NavigationView {
            ZStack {
                // Map Layer
                Map(coordinateRegion: $region, annotationItems: sighting != nil ? [sighting!] : []) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack(spacing: 4) {
                            if let url = ImageURL.from(resolvedPet.avatarUrl) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        ZStack {
                                            Circle().fill(Color.gray)
                                            Image(systemName: "pawprint.fill")
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                                .shadow(radius: 5)
                            } else {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 50, height: 50)
                                    .overlay(Image(systemName: "pawprint.fill").foregroundColor(.white))
                                    .shadow(radius: 5)
                            }
                            
                            Text("Seen \(timeAgo(from: location.timestamp))")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(6)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .shadow(radius: 3)
                        }
                    }
                }
                .id("\(sighting?.id ?? "")-\(sighting?.timestamp.timeIntervalSince1970 ?? 0)")
                .frame(minWidth: 2, minHeight: 220)
                .edgesIgnoringSafeArea(.bottom)
                
                // UI Overlays
                if isLoading {
                    VStack {
                        ProgressView("Locating via PetPals Network...")
                            .padding()
                            .background(Color.white.opacity(0.85))
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    }
                } else if noSightingFound {
                    VStack(spacing: 12) {
                        Image(systemName: "mappin.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No community sighting recorded yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("The collar will appear here once a PetPals user detects it nearby.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding()
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
            }
            .navigationTitle("Global Radar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            MeshNetworkManager.shared.startMeshNetwork()
        }
        .task {
            await refreshPetFromServer()
            fetchLastKnownLocation()
        }
        .onReceive(NotificationCenter.default.publisher(for: .petPalsCollarSightingUploaded)) { note in
            guard let uploaded = note.userInfo?["collar_uuid"] as? String else { return }
            let uploadedLower = uploaded.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let _ = (note.userInfo?["local_preview"] as? Bool) ?? false

            func doubleFromUserInfo(_ key: String) -> Double? {
                if let d = note.userInfo?[key] as? Double { return d }
                if let n = note.userInfo?[key] as? NSNumber { return n.doubleValue }
                if let s = note.userInfo?[key] as? String { return Double(s) }
                return nil
            }

            if let lat = doubleFromUserInfo("lat"),
               let lon = doubleFromUserInfo("lon") {
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                if CLLocationCoordinate2DIsValid(coord) {
                    sighting = SightingLocation(
                        id: uploadedLower,
                        coordinate: coord,
                        timestamp: Date()
                    )
                    region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    noSightingFound = false
                    isLoading = false
                    return
                }
            }

            // If we couldn't parse lat/lon from the notification, fall back to a server fetch.
            fetchLastKnownLocation()
        }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
            fetchLastKnownLocation()
        }
    }
    
    private func fetchLastKnownLocation() {
        Task {
            do {
                let collarUUID = resolvedPet.collarUUID?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let sightingRecord: CollarSighting?
                if let collarUUID, !collarUUID.isEmpty {
                    sightingRecord = try await MeshNetworkManager.shared.fetchLastSighting(collarUUID: collarUUID)
                } else {
                    // If pet has no collar UUID populated yet, show the latest collar sighting.
                    sightingRecord = try await MeshNetworkManager.shared.fetchLatestSighting()
                }
                
                DispatchQueue.main.async {
                    if let record = sightingRecord, record.lat != 0 || record.lon != 0 {
                        let coordinate = CLLocationCoordinate2D(latitude: record.lat, longitude: record.lon)
                        if CLLocationCoordinate2DIsValid(coordinate) {
                            self.sighting = SightingLocation(
                                id: collarUUID ?? record.collarUuid,
                                coordinate: coordinate,
                                timestamp: record.seenAt
                            )
                            self.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                            self.noSightingFound = false
                        } else {
                            self.noSightingFound = (self.sighting == nil)
                        }
                    } else {
                        self.noSightingFound = (self.sighting == nil)
                    }
                    self.isLoading = false
                }
            } catch {
                print("[GlobalMap] Failed to fetch sighting: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func refreshPetFromServer() async {
        do {
            let fresh = try await DependencyContainer.shared.petService.fetchPetDetails(id: pet.petId)
            await MainActor.run {
                self.resolvedPet = fresh
            }
        } catch {
            // Keep bundled `pet` snapshot on failure
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
