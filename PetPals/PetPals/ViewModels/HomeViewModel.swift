import SwiftUI
import Combine
import Foundation
import Supabase
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recommendedPets: [RecommendedPet] = []
    private var allPets: [Pet] = []
    private var personalityProfile: UserPersonalityProfile?

    @Published var nearbyVets: [Clinic] = []
    private var allClinics: [Clinic] = []

    @Published var activeCampaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    @Published var selectedCategory: String = "All" {
        didSet { applyFiltersAndRank() }
    }
    @Published var searchText: String = "" {
        didSet { applyFiltersAndRank() }
    }

    private let petService: PetServiceProtocol
    private let clinicService: ClinicServiceProtocol
    private let charityService: CharityServiceProtocol
    private let personalityService: PersonalityServiceProtocol
    private let authService: AuthServiceProtocol

    init(
        petService: PetServiceProtocol = DependencyContainer.shared.petService,
        clinicService: ClinicServiceProtocol = DependencyContainer.shared.clinicService,
        charityService: CharityServiceProtocol = DependencyContainer.shared.charityService,
        personalityService: PersonalityServiceProtocol = DependencyContainer.shared.personalityService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.petService = petService
        self.clinicService = clinicService
        self.charityService = charityService
        self.personalityService = personalityService
        self.authService = authService

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
                async let petsTask = petService.fetchAvailablePets()
                async let clinicsTask = clinicService.fetchClinics()
                async let campaignsTask = charityService.fetchCampaigns()

                let pets = try await petsTask
                let (fetchedClinics, fetchedCampaigns) = try await (clinicsTask, campaignsTask)

                if let profile = try? await authService.getCurrentUser() {
                    personalityProfile = try? await personalityService.fetchProfile(userId: profile.userId)
                } else {
                    personalityProfile = nil
                }

                allPets = pets
                allClinics = fetchedClinics
                activeCampaigns = Array(fetchedCampaigns.prefix(1))

                sortClinics()
                applyFiltersAndRank()
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
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

        nearbyVets = Array(result.prefix(8))
    }

    private func distanceMeters(clinic: Clinic, from user: CLLocation) -> CLLocationDistance {
        guard let la = clinic.latitude, let lo = clinic.longitude, abs(la) > 0.0001, abs(lo) > 0.0001 else {
            return .greatestFiniteMagnitude
        }
        return CLLocation(latitude: la, longitude: lo).distance(from: user)
    }

    private func applyFiltersAndRank() {
        var filtered = allPets

        if selectedCategory != "All" {
            let categoryLower = selectedCategory.lowercased()
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

        let ranked = PetPersonalityMatcher.rank(pets: filtered, profile: personalityProfile)
        recommendedPets = Array(ranked.prefix(10))
    }
}
