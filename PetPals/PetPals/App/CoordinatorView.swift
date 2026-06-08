import SwiftUI

struct CoordinatorView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var dependencies: DependencyContainer
    @StateObject private var cartViewModel = CartViewModel()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Group {
                switch coordinator.currentRoot {
                case .onboarding:
                    OnboardingView()
                case .auth:
                    AuthMainView()
                case .profileSetup:
                    ProfileSetupView(initialProfile: coordinator.lastFetchedProfile)
                case .personalitySetup:
                    PersonalitySetupView()
                case .mainTabs:
                    MainTabView()
                        .navigationBarHidden(true)
                default:
                    Text("Unknown Root View")
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .petDetail(let petId):
                    PetDetailView(petId: petId)
                case .adoption:
                    AdoptionView()
                case .adoptionRules(let petId):
                    AdoptionRulesView(petId: petId)
                case .adoptionForm(let petId):
                    AdoptionFormView(petId: petId)
                case .adoptionScheduler(let petId):
                    AdoptionSchedulerView(petId: petId)
                case .adoptionConfirmation(let petId):
                    AdoptionConfirmationView(petId: petId)
                case .addPetFlow:
                    AddPetView()
                case .petProfile(let petId):
                    PetProfileView(petId: petId)
                case .editPet(let pet):
                    EditPetView(pet: pet)
                case .medicalRecords(let petId):
                    MedicalRecordsListView(viewModel: PetMedicalViewModel(petId: petId))
                case .smartCollar(let petId):
                    SmartCollarView(viewModel: PetMedicalViewModel(petId: petId))
                case .vets:
                    VeterinarianListView()
                case .vetDetail(let clinicId):
                    VetDetailView(clinicId: clinicId)
                case .boardingDetail(let clinicId):
                    BoardingDetailView(clinicId: clinicId)
                case .charityDetail(let campaignId):
                    CharityDetailView(campaignId: campaignId)
                case .myPets:
                    MyPetsView()
                case .messages:
                    MessagesListView()
                case .charity:
                    CharityView()
                case .settings:
                    SettingsView()
                case .activity:
                    MyActivityView()
                case .donationHistory:
                    DonationHistoryView()
                case .donation(let campaign):
                    DonationView(campaign: campaign)
                case .appointmentBooking:
                    AppointmentBookingView()
                case .shop:
                    ShopMainView()
                case .shopDetail(let shop):
                    ShopDetailView(shop: shop)
                case .productDetail(let product):
                    PetProductDetailView(product: product)
                case .cart:
                    CartView()
                case .orderHistory:
                    OrderHistoryView()
                case .chatRoom(let clinicId, let shelterId, let displayName):
                    ChatRoomView(clinicId: clinicId, shelterId: shelterId, displayName: displayName)
                case .aiAssistant:
                    AIAssistantView()
                case .aiChat(let prompt):
                    AIChatView(initialPrompt: prompt)
                case .groomingVets:
                    VeterinarianListView(groomingOnly: true)
                case .communityPostDetail(let postId):
                    CommunityPostDetailView(postId: postId)
                case .createCommunityPost(let subredditId):
                    CreateCommunityPostView(preselectedSubredditId: subredditId)
                default:
                    EmptyView()
                }
            }
        }
        .dismissKeyboardOnSwipe()
        .environmentObject(cartViewModel)
    }
}
