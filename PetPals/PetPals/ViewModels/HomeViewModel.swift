import SwiftUI
import Combine
import Foundation
import Supabase
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var featuredPets: [Pet] = []
    private var allFeaturedPets: [Pet] = []
    
    @Published var nearbyVets: [Clinic] = []
    private var allClinics: [Clinic] = []
    
    @Published var activeCampaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var selectedCategory: String = "All" {
        didSet { filterPets() }
    }
    @Published var searchText: String = "" {
        didSet { filterPets() }
    }
    
    private let petService: PetServiceProtocol
    private let clinicService: ClinicServiceProtocol
    private let charityService: CharityServiceProtocol
    
    init(
        petService: PetServiceProtocol = DependencyContainer.shared.petService,
        clinicService: ClinicServiceProtocol = DependencyContainer.shared.clinicService,
        charityService: CharityServiceProtocol = DependencyContainer.shared.charityService
    ) {
        self.petService = petService
        self.clinicService = clinicService
        self.charityService = charityService
        
        locationManager.$location
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.sortClinics()
            }
            .store(in: &cancellables)
            
        locationManager.requestPermission()
    }
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let pets = try await petService.fetchAvailablePets()
                
                async let clinics = clinicService.fetchClinics()
                async let campaigns = charityService.fetchCampaigns()
                
                let (fetchedClinics, fetchedCampaigns) = try await (clinics, campaigns)
                
                self.allFeaturedPets = pets
                self.allClinics = fetchedClinics
                self.activeCampaigns = Array(fetchedCampaigns.prefix(1))
                
                self.sortClinics()
                self.filterPets()
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func sortClinics() {
        var result = allClinics
        
        if let userLocation = locationManager.location {
            result.sort { c1, c2 in
                distanceMeters(clinic: c1, from: userLocation) < distanceMeters(clinic: c2, from: userLocation)
            }
        } else {
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        
        self.nearbyVets = Array(result.prefix(8))
    }
    
    private func distanceMeters(clinic: Clinic, from user: CLLocation) -> CLLocationDistance {
        guard let la = clinic.latitude, let lo = clinic.longitude, abs(la) > 0.0001, abs(lo) > 0.0001 else {
            return .greatestFiniteMagnitude
        }
        return CLLocation(latitude: la, longitude: lo).distance(from: user)
    }
    
    private func filterPets() {
        var filtered = allFeaturedPets
        
        if selectedCategory != "All" {
            let categoryLower = selectedCategory.lowercased()
            // Assume category is plural like "Dogs", "Cats", "Birds", match species "Dog", "Cat", "Bird" or exact match
            let singularCategory = String(categoryLower.dropLast())
            filtered = filtered.filter { 
                let species = $0.species?.lowercased() ?? ""
                return species == categoryLower || species == singularCategory
            }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) || 
                ($0.breed?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        self.featuredPets = Array(filtered.prefix(10))
    }
}
