import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var dependencies: DependencyContainer
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedMatchPet: RecommendedPet? = nil
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
                header
                heroCard
                searchField
                dynamicHeroSection
                servicesGrid
                nearbyVets
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
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(Theme.Fonts.label(Typography.caption, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                Text(coordinator.lastFetchedProfile?.userName ?? L10n.petLover)
                    .font(Theme.Fonts.display(Typography.title2))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            Button { coordinator.push(.settings) } label: {
                settingsAvatar
            }
            .buttonStyle(MagneticPressStyle())
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    @ViewBuilder
    private var settingsAvatar: some View {
        Group {
            if let avatarUrl = coordinator.lastFetchedProfile?.avatarUrl,
               let url = ImageURL.from(avatarUrl) {
                CachedAsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    avatarPlaceholder
                }
            } else {
                avatarPlaceholder
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
        .overlay(Circle().stroke(Theme.glassStroke, lineWidth: 1.5))
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Circle().fill(Theme.primary.opacity(0.15))
            Image(systemName: "person.fill")
                .foregroundStyle(Theme.primary)
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(L10n.homeHeroTitle)
                .font(Theme.Fonts.display(Typography.title1))
                .foregroundStyle(Theme.textOnBrand)
            Text(L10n.homeHeroDesc)
                .font(Theme.Fonts.body(Typography.callout))
                .foregroundStyle(Theme.textOnBrand.opacity(0.9))
            HStack(spacing: Spacing.xs) {
                PrimaryButton(title: L10n.findAPet) {
                    coordinator.push(.adoption)
                }
                SecondaryButton(title: L10n.petCare) {
                    coordinator.push(.vets)
                }
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(Theme.brandGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Theme.primary.opacity(0.35), radius: 24, y: 12)
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    private var searchField: some View {
        Button {
            showGlobalSearch = true
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.textSecondary)
                Text(L10n.searchPlaceholderHome)
                    .font(Theme.Fonts.body(Typography.callout))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 14)
            .glassCard(cornerRadius: Radius.md, elevation: .resting)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    @ViewBuilder
    private var dynamicHeroSection: some View {
        if let order = viewModel.activeOrder {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                PremiumSectionHeader(title: "Current Order")
                ActiveOrderCard(order: order) {
                    coordinator.push(.orderHistory)
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
            }
        } else if viewModel.userHasPets, let post = viewModel.featuredPost {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                PremiumSectionHeader(title: "Featured in Community")
                FeaturedPostCard(post: post) {
                    coordinator.push(.communityPostDetail(postId: post.id))
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
            }
        } else {
            recommendedSection
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            PremiumSectionHeader(title: L10n.recommendedAdoption, actionTitle: L10n.seeAll) {
                coordinator.push(.adoption)
            }
            if viewModel.isLoading {
                ProgressView()
                    .tint(Theme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
            } else if viewModel.recommendedPets.isEmpty {
                PremiumEmptyState(
                    icon: "heart.fill",
                    title: L10n.noRecommendedListings,
                    message: L10n.noRecommendedListingsDesc
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(viewModel.recommendedPets) { item in
                            FeaturedPetCard(
                                pet: item.pet,
                                matchScore: item.matchScore,
                                onMatchTap: {
                                    selectedMatchPet = item
                                }
                            ) {
                                coordinator.push(.petDetail(petId: item.pet.id))
                            }
                        }
                    }
                    .padding(.horizontal, ScreenLayout.horizontalPadding)
                }
            }
        }
        .sheet(item: $selectedMatchPet) { item in
            if let profile = viewModel.personalityProfile {
                MatchScoreDetailView(
                    petName: item.pet.name,
                    matchResult: PetPersonalityMatcher.detailedMatchScore(pet: item.pet, profile: profile)
                )
                .environmentObject(coordinator)
            } else {
                Text("Complete your personality profile to see match details.")
                    .font(Theme.Fonts.body(Typography.callout))
                    .foregroundStyle(Theme.textSecondary)
                    .padding()
            }
        }
    }

    private var servicesGrid: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            PremiumSectionHeader(title: L10n.services)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                PremiumServiceTile(title: L10n.veterinary, icon: "cross.case.fill", tint: Theme.brandDeep) {
                    coordinator.push(.vets)
                }
                PremiumServiceTile(title: L10n.petShop, icon: "bag.fill", tint: Theme.navy) {
                    coordinator.push(.shop)
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)
        }
    }

    private var nearbyVets: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            PremiumSectionHeader(title: L10n.nearbyVets, actionTitle: L10n.viewAll) {
                coordinator.push(.vets)
            }
            VStack(spacing: Spacing.xs) {
                ForEach(viewModel.nearbyVets) { item in
                    ClinicRowCard(clinic: item.clinic, distance: item.formattedDistance) {
                        coordinator.push(.vetDetail(clinicId: item.clinic.id))
                    }
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppCoordinator())
        .environmentObject(DependencyContainer())
}
