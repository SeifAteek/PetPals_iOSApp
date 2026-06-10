import SwiftUI
import Combine

enum GlobalSearchResult: Hashable {
    case product(PetProduct)
    case clinic(Clinic)
    case pet(Pet)
    case post(CommunityPost)
}

@MainActor
final class GlobalSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [GlobalSearchResult] = []
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    
    private let petService: PetServiceProtocol
    private let clinicService: ClinicServiceProtocol
    private let shopService: ShopServiceProtocol
    private let communityService: CommunityServiceProtocol
    private let authService: AuthServiceProtocol

    init(
        petService: PetServiceProtocol = DependencyContainer.shared.petService,
        clinicService: ClinicServiceProtocol = DependencyContainer.shared.clinicService,
        shopService: ShopServiceProtocol = DependencyContainer.shared.shopService,
        communityService: CommunityServiceProtocol = DependencyContainer.shared.communityService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.petService = petService
        self.clinicService = clinicService
        self.shopService = shopService
        self.communityService = communityService
        self.authService = authService
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            results = []
            return
        }
        
        isLoading = true
        
        Task {
            var newResults: [GlobalSearchResult] = []
            
            // Search Pets
            if let pets = try? await petService.fetchAvailablePets() {
                let filtered = pets.filter { ($0.name.localizedCaseInsensitiveContains(query)) || ($0.breed?.localizedCaseInsensitiveContains(query) == true) || ($0.species?.localizedCaseInsensitiveContains(query) == true) }
                newResults.append(contentsOf: filtered.map { .pet($0) })
            }
            
            // Search Clinics
            if let clinics = try? await clinicService.fetchClinics() {
                let filtered = clinics.filter { $0.name.localizedCaseInsensitiveContains(query) || ($0.location?.localizedCaseInsensitiveContains(query) == true) }
                newResults.append(contentsOf: filtered.map { .clinic($0) })
            }
            
            // Search Products
            if let products = try? await shopService.fetchProducts() {
                let filtered = products.filter { $0.name.localizedCaseInsensitiveContains(query) || ($0.category?.localizedCaseInsensitiveContains(query) == true) }
                newResults.append(contentsOf: filtered.map { .product($0) })
            }
            
            // Search Posts
            if let profile = try? await authService.getCurrentUser(), let posts = try? await communityService.fetchPosts(subredditId: nil, userId: profile.userId) {
                let filtered = posts.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.body.localizedCaseInsensitiveContains(query) }
                newResults.append(contentsOf: filtered.map { .post($0) })
            }
            
            self.results = newResults
            self.isLoading = false
        }
    }
}
