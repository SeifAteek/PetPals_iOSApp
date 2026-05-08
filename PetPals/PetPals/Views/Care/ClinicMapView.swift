import SwiftUI
import MapKit

struct ClinicMapView: View {
    let clinic: Clinic
    @State private var region: MKCoordinateRegion
    
    init(clinic: Clinic) {
        self.clinic = clinic
        let lat = clinic.latitude ?? 0
        let lon = clinic.longitude ?? 0
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [clinic]) { item in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: item.latitude ?? 0, longitude: item.longitude ?? 0), tint: Theme.primary)
        }
    }
}

struct FullMapView: View {
    let clinic: Clinic
    @Environment(\.dismiss) var dismiss
    @State private var region: MKCoordinateRegion
    @State private var showActionSheet = false
    
    init(clinic: Clinic) {
        self.clinic = clinic
        let lat = clinic.latitude ?? 0
        let lon = clinic.longitude ?? 0
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $region, annotationItems: [clinic]) { item in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: item.latitude ?? 0, longitude: item.longitude ?? 0), tint: Theme.primary)
                }
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Button(action: {
                        showActionSheet = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            Text("Get Directions")
                                .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primary)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .shadow(radius: 10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(clinic.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let text = "Check out this clinic: \(clinic.name) at \(clinic.location ?? "")"
                        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            rootVC.present(av, animated: true)
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .confirmationDialog("Select an action", isPresented: $showActionSheet, titleVisibility: .visible) {
                Button("Open in Maps") {
                    openInAppleMaps()
                }
                Button("Open in Google Maps") {
                    openInGoogleMaps()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    private func openInAppleMaps() {
        let lat = clinic.latitude ?? 0
        let lon = clinic.longitude ?? 0
        let url = URL(string: "maps://?q=\(clinic.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&ll=\(lat),\(lon)")!
        UIApplication.shared.open(url)
    }
    
    private func openInGoogleMaps() {
        let lat = clinic.latitude ?? 0
        let lon = clinic.longitude ?? 0
        let url = URL(string: "comgooglemaps://?q=\(lat),\(lon)&zoom=14")!
        let webUrl = URL(string: "https://www.google.com/maps/search/?api=1&query=\(lat),\(lon)")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.open(webUrl)
        }
    }
}
