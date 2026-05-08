import SwiftUI
import Combine
import Foundation
import Supabase
import Auth

/// Context for `AppointmentBookingView` (vet visit or boarding request), set before navigating to `.appointmentBooking`.
struct CheckoutDraft: Equatable {
    enum Kind: Equatable {
        case vetConsultation
        case boarding
    }
    let clinicId: UUID
    let providerDisplayName: String
    let amountEGP: Decimal
    let serviceSummary: String
    let kind: Kind
    /// Required for vet bookings; optional for boarding.
    let petId: UUID?
    let petName: String?
}

enum AppRoute: Hashable {
    // Auth
    case onboarding
    case auth
    case profileSetup
    // Core
    case mainTabs
    // Adoption
    case adoption
    case petDetail(petId: UUID)
    case adoptionRules(petId: UUID)
    case adoptionForm(petId: UUID)
    case adoptionScheduler(petId: UUID)
    case adoptionConfirmation(petId: UUID)
    // My Pets
    case addPetFlow
    case petProfile(petId: UUID)
    case editPet(pet: Pet)
    case medicalRecords(petId: UUID)
    case smartCollar(petId: UUID)
    // Care
    case vets
    case vetDetail(clinicId: UUID)
    case boardingDetail(clinicId: UUID)
    // Booking (no payment — appointment request only)
    case appointmentBooking
    // Charity
    case charityDetail(campaignId: UUID)
    case donation(campaign: Campaign)
    // Settings & Profile
    case settings
    case activity
    case donationHistory
    // Shop
    case shop
    case shopDetail(shop: Shop)
    case productDetail(product: PetProduct)
    case cart
    case orderHistory
    // Chat
    case chatRoom(clinicId: UUID?, shelterId: UUID?, displayName: String)
    // AI
    case aiAssistant
    case aiChat(prompt: String)
    case groomingVets
}
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var currentRoot: AppRoute
    @Published var lastFetchedProfile: Profile?
    /// When non-nil, `AppointmentBookingView` shows this booking context (vet / boarding).
    @Published var checkoutDraft: CheckoutDraft?
    
    init() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.currentRoot = hasCompletedOnboarding ? .auth : .onboarding
        
        Task {
            do {
                let _ = try await SupabaseClientManager.shared.client.auth.session
                let profile = try await DependencyContainer.shared.authService.getCurrentUser()
                await MainActor.run {
                    self.lastFetchedProfile = profile
                    self.currentRoot = .mainTabs
                }
            } catch {
                // Not logged in, keep current root
            }
        }
    }
    
    func push(_ route: AppRoute) {
        path.append(route)
    }
    
    func beginCheckout(_ draft: CheckoutDraft) {
        checkoutDraft = draft
        push(.appointmentBooking)
    }
    
    func clearCheckoutDraft() {
        checkoutDraft = nil
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func switchRoot(to route: AppRoute) {
        path.removeLast(path.count)
        currentRoot = route
    }
}
