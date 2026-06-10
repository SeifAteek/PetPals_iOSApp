import SwiftUI
import Combine
import Foundation
import Supabase
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recommendedPets: [RecommendedPet] = []
    private var allPets: [Pet] = []
    @Published var personalityProfile: UserPersonalityProfile?

    @Published var nearbyVets: [NearbyClinic] = []
    private var allClinics: [Clinic] = []

    @Published var activeCampaigns: [Campaign] = []
    
    // Dynamic Hero State
    @Published var activeOrder: ShopOrder?
    @Published var featuredPost: CommunityPost?
    @Published var userHasPets: Bool = false
    
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
    private let shopService: ShopServiceProtocol
    private let communityService: CommunityServiceProtocol

    init(
        petService: PetServiceProtocol = DependencyContainer.shared.petService,
        clinicService: ClinicServiceProtocol = DependencyContainer.shared.clinicService,
        charityService: CharityServiceProtocol = DependencyContainer.shared.charityService,
        personalityService: PersonalityServiceProtocol = DependencyContainer.shared.personalityService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService,
        shopService: ShopServiceProtocol = DependencyContainer.shared.shopService,
        communityService: CommunityServiceProtocol = DependencyContainer.shared.communityService
    ) {
        self.petService = petService
        self.clinicService = clinicService
        self.charityService = charityService
        self.personalityService = personalityService
        self.authService = authService
        self.shopService = shopService
        self.communityService = communityService

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
                var (fetchedClinics, fetchedCampaigns) = try await (clinicsTask, campaignsTask)

                if let profile = try? await authService.getCurrentUser() {
                    personalityProfile = try? await personalityService.fetchProfile(userId: profile.userId)
                    
                    let userPets = (try? await petService.fetchUserPets(userId: profile.userId)) ?? []
                    userHasPets = !userPets.isEmpty
                    
                    if let orders = try? await shopService.fetchUserOrders(userId: profile.userId) {
                        activeOrder = orders.first(where: { $0.status == .processing || $0.status == .shipped })
                    }
                    
                    if activeOrder == nil && userHasPets {
                        if let posts = try? await communityService.fetchPosts(subredditId: nil, userId: profile.userId) {
                            let fiveDaysAgo = Date().addingTimeInterval(-5 * 86400)
                            let recentPosts = posts.filter { ($0.createdAt ?? Date()) > fiveDaysAgo }
                            
                            if let topRecent = recentPosts.max(by: { $0.score < $1.score }) {
                                featuredPost = topRecent
                            } else if let topAny = posts.max(by: { $0.score < $1.score }) {
                                featuredPost = topAny
                            } else {
                                featuredPost = nil
                            }
                        }
                    }
                } else {
                    personalityProfile = nil
                    userHasPets = false
                    activeOrder = nil
                    featuredPost = nil
                }

                // Geocode clinics that have an address but no coordinates
                await geocodeClinics(&fetchedClinics)

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

    private func geocodeClinics(_ clinics: inout [Clinic]) async {
        let geocoder = CLGeocoder()
        for i in clinics.indices {
            if (clinics[i].latitude == nil || abs(clinics[i].latitude ?? 0) < 0.0001),
               let address = clinics[i].location, !address.isEmpty {
                if let placemarks = try? await geocoder.geocodeAddressString(address),
                   let coord = placemarks.first?.location?.coordinate {
                    clinics[i].latitude = coord.latitude
                    clinics[i].longitude = coord.longitude
                }
            }
        }
    }

    private func sortClinics() {
        var result = allClinics

        if let userLocation = locationManager.location {
            result.sort { c1, c2 in
                distanceMeters(clinic: c1, from: userLocation) < distanceMeters(clinic: c2, from: userLocation)
            }
            nearbyVets = Array(result.prefix(8)).map { clinic in
                let dist = distanceMeters(clinic: clinic, from: userLocation)
                return NearbyClinic(clinic: clinic, distanceMeters: dist == .greatestFiniteMagnitude ? nil : dist)
            }
        } else {
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            nearbyVets = Array(result.prefix(8)).map { NearbyClinic(clinic: $0, distanceMeters: nil) }
        }
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

struct NearbyClinic: Identifiable {
    var id: UUID { clinic.id }
    let clinic: Clinic
    let distanceMeters: Double?

    var formattedDistance: String? {
        guard let meters = distanceMeters else { return nil }
        if meters < 1000 {
            return "\(Int(meters)) m away"
        } else {
            return String(format: "%.1f km away", meters / 1000)
        }
    }
}
