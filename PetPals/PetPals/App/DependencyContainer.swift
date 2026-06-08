import Foundation
import Combine

/// Centralized Dependency Container for the PetPals application.
/// This acts as a single source of truth for all service implementations, allowing for easy dependency injection and mocking.
@MainActor
final class DependencyContainer: ObservableObject {
    
    // MARK: - Services
    let authService: AuthServiceProtocol
    let petService: PetServiceProtocol
    let clinicService: ClinicServiceProtocol
    let charityService: CharityServiceProtocol
    let shopService: ShopServiceProtocol
    let chatService: ChatServiceProtocol
    let reviewService: ReviewServiceProtocol
    let communityService: CommunityServiceProtocol
    let personalityService: PersonalityServiceProtocol
    let hardwareNFCService: NFCServiceProtocol
    let locationTrackingService: LocationTrackingServiceProtocol
    
    // MARK: - Initialization
    init(
        authService: AuthServiceProtocol = SupabaseAuthService(),
        petService: PetServiceProtocol = SupabasePetService(),
        clinicService: ClinicServiceProtocol = SupabaseClinicService(),
        charityService: CharityServiceProtocol = SupabaseCharityService(),
        shopService: ShopServiceProtocol = SupabaseShopService(),
        chatService: ChatServiceProtocol = SupabaseChatService(),
        reviewService: ReviewServiceProtocol = SupabaseReviewService(),
        communityService: CommunityServiceProtocol = SupabaseCommunityService(),
        personalityService: PersonalityServiceProtocol = SupabasePersonalityService(),
        hardwareNFCService: NFCServiceProtocol = RealNFCService(),
        locationTrackingService: LocationTrackingServiceProtocol = CoreLocationTrackingService()
    ) {
        self.authService = authService
        self.petService = petService
        self.clinicService = clinicService
        self.charityService = charityService
        self.shopService = shopService
        self.chatService = chatService
        self.reviewService = reviewService
        self.communityService = communityService
        self.personalityService = personalityService
        self.hardwareNFCService = hardwareNFCService
        self.locationTrackingService = locationTrackingService
    }
    
    // MARK: - Shared Instance (Optional, depending on injection preference)
    static let shared = DependencyContainer()
}
