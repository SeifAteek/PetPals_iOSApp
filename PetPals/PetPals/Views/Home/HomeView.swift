import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var dependencies: DependencyContainer
    @StateObject private var viewModel = HomeViewModel()
    @State private var showGlobalSearch = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return L10n.goodMorning
        case 12..<17: return L10n.goodAfternoon
        case 17..<22: return L10n.goodEvening
        default: return L10n.hello
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                header           // greeting + search + notifications
                heroCarousel     // 1 · auto-rotating hero (promo · donation · vet tips)
                myPetsSection    // 2 · horizontal row of pet cards
                servicesGrid     // 3 · icon grid of services
                nearbySection    // 4 · nearby clinics
                communitySection // 5 · community cards
            }
            .padding(.top, Spacing.sm)
        }
        .dismissKeyboardOnSwipe()
        .petPalsScreenBackground()
        .fullScreenCover(isPresented: $showGlobalSearch) {
            GlobalSearchView()
        }
        .onAppear {
            viewModel.loadData()
            Task {
                if let profile = try? await dependencies.authService.getCurrentUser() {
                    await MainActor.run { coordinator.lastFetchedProfile = profile }
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(greeting)
                    .font(Theme.Fonts.body(Typography.caption, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                Text(coordinator.lastFetchedProfile?.userName ?? L10n.petLover)
                    .font(Theme.Fonts.display(26))
                    .tracking(-0.5)
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            HStack(spacing: Spacing.xs) {
                PPIconButton(icon: "magnifyingglass") {
                    showGlobalSearch = true
                }
                .accessibilityLabel(L10n.searchPlaceholderHome)

                NotificationBellButton {
                    coordinator.push(.notifications)
                }
                .accessibilityLabel("Notifications")
            }
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    // MARK: - 1 · Hero carousel

    private var heroCarousel: some View {
        HomeHeroCarousel(
            donationTitle: viewModel.activeCampaigns.first?.title,
            onFindPet: { coordinator.push(.adoption) },
            onPetCare: { coordinator.push(.vets) },
            onDonate: openDonation,
            onVetTips: { coordinator.push(.vets) }
        )
    }

    private func openDonation() {
        if let campaign = viewModel.activeCampaigns.first {
            coordinator.push(.donation(campaign: campaign))
        } else {
            coordinator.push(.charity)
        }
    }

    /// Pet whose collar the "Collar →" shortcut opens — the paired one, else the first pet.
    private var collarPetId: UUID? {
        CollarSession.shared.pairedPetId ?? viewModel.myPets.first?.petId
    }

    private func openCollar() {
        guard let pet = viewModel.myPets.first(where: { $0.petId == collarPetId }) ?? viewModel.myPets.first else { return }
        CollarSession.shared.pair(petId: pet.petId, petName: pet.name)
        coordinator.push(.collarDashboard(petId: pet.petId))
    }

    // MARK: - 2 · My pets

    private var myPetsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            PremiumSectionHeader(title: L10n.myPets, actionTitle: collarPetId != nil ? "Collar →" : nil) {
                openCollar()
            }
            if viewModel.myPets.isEmpty {
                Button {
                    coordinator.push(.addPetFlow)
                } label: {
                    HStack(spacing: Spacing.sm) {
                        PPIconTile(icon: "plus", tint: Theme.forest, background: Theme.forestSoft, size: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Add your first pal")
                                .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                                .foregroundStyle(Theme.textPrimary)
                            Text("Track health, reminders and their collar")
                                .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.textFaint)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard(cornerRadius: Radius.lg, elevation: .resting)
                }
                .buttonStyle(MagneticPressStyle())
                .padding(.horizontal, ScreenLayout.horizontalPadding)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(viewModel.myPets) { pet in
                            PetCard(pet: pet) {
                                coordinator.push(.petProfile(petId: pet.petId))
                            }
                            .frame(width: 230)
                        }
                    }
                    .padding(.horizontal, ScreenLayout.horizontalPadding)
                }
            }
        }
    }

    // MARK: - 3 · Services

    private var servicesGrid: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            PremiumSectionHeader(title: L10n.services)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                PremiumServiceTile(title: L10n.findAPet, subtitle: "Find a match", icon: "heart.fill", tint: Theme.forest, tileBackground: Theme.forestSoft) {
                    coordinator.push(.adoption)
                }
                PremiumServiceTile(title: L10n.veterinary, subtitle: "Book a visit", icon: "stethoscope", tint: Theme.statusInfo, tileBackground: Theme.statusInfoSoft) {
                    coordinator.push(.vets)
                }
                PremiumServiceTile(title: L10n.petShop, subtitle: "For your pals", icon: "bag.fill", tint: Theme.forest, tileBackground: Theme.forestSoft) {
                    coordinator.push(.shop)
                }
                PremiumServiceTile(title: "Symptom check", subtitle: "Ask PetPals AI", icon: "sparkles", tint: Theme.coralDeep, tileBackground: Theme.coralSoft) {
                    coordinator.push(.aiAssistant)
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)
        }
    }

    // MARK: - 4 · Nearby

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            PremiumSectionHeader(title: L10n.nearbyVets, actionTitle: L10n.viewAll) {
                coordinator.push(.vets)
            }
            VStack(spacing: Spacing.xs) {
                ForEach(viewModel.nearbyVets.prefix(4)) { item in
                    ClinicRowCard(clinic: item.clinic, distance: item.formattedDistance) {
                        coordinator.push(.vetDetail(clinicId: item.clinic.id))
                    }
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)
        }
    }

    // MARK: - 5 · Community

    @ViewBuilder
    private var communitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            PremiumSectionHeader(title: L10n.communityTitle, actionTitle: L10n.communityNewPost) {
                coordinator.push(.createCommunityPost(subredditId: nil))
            }
            if viewModel.communityPosts.isEmpty {
                PremiumEmptyState(
                    icon: "text.bubble.fill",
                    title: L10n.communityNoPosts,
                    message: L10n.communityNoPostsDesc
                )
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(viewModel.communityPosts.prefix(3)) { post in
                        FeaturedPostCard(post: post) {
                            coordinator.push(.communityPostDetail(postId: post.id))
                        }
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
            }
        }
        .padding(.bottom, Spacing.md)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppCoordinator())
        .environmentObject(DependencyContainer())
}
