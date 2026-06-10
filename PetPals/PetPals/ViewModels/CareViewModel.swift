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
    
    @Published var categories: [CareCategory] = []

    func refreshLocalizedCategories() {
        categories = [
            CareCategory(kind: .veterinary, title: L10n.veterinary, icon: "cross.case.fill", color: .blue),
            CareCategory(kind: .petShop, title: L10n.petShop, icon: "bag.fill", color: .green)
        ]
    }
    
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

    // MARK: - Daily Tips (rotates based on day of year)

    var dailyTips: [DailyTip] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let pool = Self.tipsPool
        let idx1 = (dayOfYear * 2) % pool.count
        let idx2 = (dayOfYear * 2 + 1) % pool.count
        return [pool[idx1], pool[idx2]]
    }

    private static let tipsPool: [DailyTip] = [
        DailyTip(title: "Hydration is key", desc: "Fresh water always — especially in warmer months.", icon: "drop.fill", color: .cyan),
        DailyTip(title: "Regular exercise", desc: "Thirty minutes of movement lifts mood and health.", icon: "figure.walk", color: .green),
        DailyTip(title: "Dental hygiene", desc: "Brush your pet's teeth 2-3 times a week to prevent gum disease.", icon: "mouth.fill", color: .mint),
        DailyTip(title: "Balanced nutrition", desc: "Avoid table scraps — stick to vet-recommended pet food.", icon: "fork.knife", color: .orange),
        DailyTip(title: "Mental stimulation", desc: "Puzzle toys keep your pet sharp and reduce boredom.", icon: "brain.head.profile", color: .purple),
        DailyTip(title: "Grooming routine", desc: "Regular brushing removes loose fur and distributes natural oils.", icon: "scissors", color: .pink),
        DailyTip(title: "Socialization matters", desc: "Expose your pet to different people and animals early.", icon: "person.2.fill", color: .blue),
        DailyTip(title: "Regular vet checkups", desc: "Annual visits catch health issues before they become serious.", icon: "cross.case.fill", color: .red),
        DailyTip(title: "Parasite prevention", desc: "Monthly flea and tick treatments keep pests at bay.", icon: "ladybug.fill", color: .brown),
        DailyTip(title: "Safe space", desc: "Give your pet a quiet corner where they can retreat and relax.", icon: "house.fill", color: .indigo),
        DailyTip(title: "Nail trimming", desc: "Keep nails trimmed every 2-3 weeks to prevent discomfort.", icon: "hand.raised.fill", color: .gray),
        DailyTip(title: "Portion control", desc: "Overfeeding leads to obesity — measure meals carefully.", icon: "scalemass.fill", color: .yellow),
        DailyTip(title: "Microchip your pet", desc: "A microchip greatly increases the chance of reunion if lost.", icon: "wave.3.right", color: .teal),
        DailyTip(title: "Heat safety", desc: "Never leave your pet in a parked car — even for a few minutes.", icon: "sun.max.fill", color: .red),
        DailyTip(title: "Training consistency", desc: "Use the same commands and rewards for effective training.", icon: "star.fill", color: .yellow),
        DailyTip(title: "Watch for allergies", desc: "Itching, redness, or sneezing can signal food or seasonal allergies.", icon: "allergens", color: .orange),
        DailyTip(title: "Play daily", desc: "Interactive play strengthens the bond between you and your pet.", icon: "gamecontroller.fill", color: .purple),
        DailyTip(title: "Ear cleaning", desc: "Check ears weekly and clean gently to prevent infections.", icon: "ear.fill", color: .pink),
        DailyTip(title: "Weight monitoring", desc: "Weigh your pet monthly to catch gradual weight changes.", icon: "scalemass.fill", color: .green),
        DailyTip(title: "Toxic foods", desc: "Chocolate, grapes, onions, and xylitol are dangerous for pets.", icon: "exclamationmark.triangle.fill", color: .red),
        DailyTip(title: "Leash manners", desc: "A well-trained leash walker is safer and more enjoyable on walks.", icon: "figure.walk", color: .blue),
        DailyTip(title: "Pet-proof your home", desc: "Secure cables, toxic plants, and small objects pets could swallow.", icon: "shield.fill", color: .green),
        DailyTip(title: "Fresh air exposure", desc: "Open windows or outdoor time benefits indoor pets greatly.", icon: "wind", color: .cyan),
        DailyTip(title: "Crate training", desc: "A crate provides security — never use it as punishment.", icon: "cube.fill", color: .brown),
        DailyTip(title: "Spay or neuter", desc: "Reduces health risks and helps control pet overpopulation.", icon: "heart.fill", color: .pink),
        DailyTip(title: "Vaccination schedule", desc: "Keep vaccines up to date — your vet can provide the right schedule.", icon: "syringe.fill", color: .blue),
        DailyTip(title: "Eye care", desc: "Wipe away discharge gently and watch for redness or cloudiness.", icon: "eye.fill", color: .teal),
        DailyTip(title: "Travel preparation", desc: "Use a secure carrier and bring water, food, and comfort items.", icon: "car.fill", color: .indigo),
        DailyTip(title: "Seasonal coat care", desc: "Pets shed more in spring and fall — brush more during these times.", icon: "leaf.fill", color: .orange),
        DailyTip(title: "Love and patience", desc: "The best thing you can give your pet is your time and affection.", icon: "heart.fill", color: .red),
    ]
}

enum CareCategoryKind {
    case veterinary, petShop
}

struct CareCategory: Identifiable {
    let id = UUID()
    let kind: CareCategoryKind
    let title: String
    let icon: String
    let color: Color
}

struct DailyTip: Identifiable {
    let id = UUID()
    let title: String
    let desc: String
    let icon: String
    let color: Color
}

