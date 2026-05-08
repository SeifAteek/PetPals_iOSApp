import SwiftUI
import Combine
import CoreLocation

@MainActor
final class CareViewModel: ObservableObject {
    @Published var clinics: [Clinic] = []
    @Published var filteredClinics: [Clinic] = []
    @Published var boardingServices: [Clinic] = [] 
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var categories: [CareCategory] = [
        CareCategory(title: "Veterinary", icon: "cross.case.fill", color: .blue),
        CareCategory(title: "Grooming", icon: "scissors", color: .purple),
        CareCategory(title: "Boarding", icon: "house.fill", color: .orange),
        CareCategory(title: "Pet Shop", icon: "bag.fill", color: .green)
    ]
    
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    private let clinicService: ClinicServiceProtocol
    
    init(clinicService: ClinicServiceProtocol = DependencyContainer.shared.clinicService) {
        self.clinicService = clinicService
        
        locationManager.$location
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterAndSortClinics()
            }
            .store(in: &cancellables)
        
        locationManager.requestPermission()
    }
    
    func loadData(groomingOnly: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let allFetched = try await clinicService.fetchClinics()
                self.boardingServices = allFetched
                var list = allFetched
                if groomingOnly {
                    let all = try await clinicService.fetchAllClinicProcedures()
                    let groomIds = Set(all.filter { $0.name.localizedCaseInsensitiveContains("groom") }.compactMap { $0.clinicId })
                    list = list.filter { groomIds.contains($0.clinicId) }
                }
                self.clinics = list
                self.filterAndSortClinics()
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func filterAndSortClinics() {
        var result = clinics
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let userLocation = locationManager.location {
            result.sort { c1, c2 in
                Self.distanceMeters(clinic: c1, from: userLocation) < Self.distanceMeters(clinic: c2, from: userLocation)
            }
        } else {
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        
        filteredClinics = result
    }
    
    private static func distanceMeters(clinic: Clinic, from user: CLLocation) -> CLLocationDistance {
        guard let la = clinic.latitude, let lo = clinic.longitude, abs(la) > 0.0001, abs(lo) > 0.0001 else {
            return .greatestFiniteMagnitude
        }
        return CLLocation(latitude: la, longitude: lo).distance(from: user)
    }
}

struct CareCategory: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}
