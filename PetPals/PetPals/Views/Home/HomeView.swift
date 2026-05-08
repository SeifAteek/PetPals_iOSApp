import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var dependencies: DependencyContainer
    @StateObject private var viewModel = HomeViewModel()
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning 👋"
        case 12..<17: return "Good Afternoon 👋"
        case 17..<22: return "Good Evening 👋"
        default: return "Hello 👋"
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(Theme.Fonts.primaryFont(size: 14))
                            .foregroundColor(Theme.textSecondary)
                        Text(coordinator.lastFetchedProfile?.userName ?? "Pet Lover")
                            .font(Theme.Fonts.primaryFont(size: 20, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                    }
                    Spacer()
                    
                    Button(action: {
                        coordinator.push(.settings)
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(.trailing, 8)
                    
                    if let avatarUrl = coordinator.lastFetchedProfile?.avatarUrl, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.1)
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .onTapGesture {
                            coordinator.push(.settings)
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(Theme.primary)
                            .onTapGesture {
                                coordinator.push(.settings)
                            }
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search for pets...", text: $viewModel.searchText)
                        .font(Theme.Fonts.primaryFont(size: 15))
                        .foregroundColor(Theme.textPrimary)
                }
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                
                // MARK: - Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        CategoryPill(title: "Dogs", icon: "dog.fill", isSelected: viewModel.selectedCategory == "Dogs")
                            .onTapGesture { viewModel.selectedCategory = viewModel.selectedCategory == "Dogs" ? "All" : "Dogs" }
                        CategoryPill(title: "Cats", icon: "cat.fill", isSelected: viewModel.selectedCategory == "Cats")
                            .onTapGesture { viewModel.selectedCategory = viewModel.selectedCategory == "Cats" ? "All" : "Cats" }
                        CategoryPill(title: "Birds", icon: "bird.fill", isSelected: viewModel.selectedCategory == "Birds")
                            .onTapGesture { viewModel.selectedCategory = viewModel.selectedCategory == "Birds" ? "All" : "Birds" }
                        CategoryPill(title: "Rabbits", icon: "hare.fill", isSelected: viewModel.selectedCategory == "Rabbits")
                            .onTapGesture { viewModel.selectedCategory = viewModel.selectedCategory == "Rabbits" ? "All" : "Rabbits" }
                    }
                    .padding(.horizontal, 24)
                }
                
                // MARK: - Urgent Adoption (Carousel)
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Urgent Adoption", actionTitle: "See All") {
                        coordinator.push(.adoption)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView().frame(maxWidth: .infinity).padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(viewModel.featuredPets) { pet in
                                    UrgentPetCard(pet: pet) {
                                        coordinator.push(.petDetail(petId: pet.id))
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                
                // MARK: - Services Grid
                VStack(alignment: .leading, spacing: 16) {
                    Text("Our Services")
                        .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.horizontal, 24)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ServiceCard(title: "Veterinary", icon: "cross.case.fill", color: Color.blue.opacity(0.1)) {
                            coordinator.push(.vets)
                        }
                        ServiceCard(title: "Grooming", icon: "scissors", color: Color.purple.opacity(0.1)) {
                            coordinator.push(.groomingVets)
                        }
                        ServiceCard(title: "Pet Shop", icon: "bag.fill", color: Color.orange.opacity(0.1)) {
                            coordinator.push(.shop)
                        }
                        ServiceCard(title: "Training", icon: "star.fill", color: Color.green.opacity(0.1)) {
                            coordinator.push(.vets)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // MARK: - Nearby Vets
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Nearby Vets", actionTitle: "View All") {
                        coordinator.push(.vets)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(viewModel.nearbyVets) { clinic in
                            ClinicRowCard(clinic: clinic) {
                                coordinator.push(.vetDetail(clinicId: clinic.id))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.vertical, 20)
        }
        .background(Theme.background.ignoresSafeArea())
        .onAppear {
            viewModel.loadData()
            Task {
                if let profile = try? await dependencies.authService.getCurrentUser() {
                    await MainActor.run { coordinator.lastFetchedProfile = profile }
                }
            }
        }
    }
}

// MARK: - Subviews

struct SectionHeader: View {
    let title: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                .foregroundColor(Theme.textPrimary)
            Spacer()
            Button(action: action) {
                Text(actionTitle)
                    .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                    .foregroundColor(Theme.primary)
            }
        }
        .padding(.horizontal, 24)
    }
}

struct CategoryPill: View {
    let title: String
    let icon: String
    var isSelected: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isSelected ? Theme.primary : Theme.cardBackground)
        .foregroundColor(isSelected ? .white : Theme.textSecondary)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct UrgentPetCard: View {
    let pet: Pet
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                if let avatarUrl = pet.avatarUrl, let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                    .frame(width: 240, height: 160)
                    .clipped()
                } else {
                    ZStack {
                        Color.gray.opacity(0.1)
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(Theme.primary.opacity(0.5))
                    }
                    .frame(width: 240, height: 160)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(pet.name)
                            .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Text("\(pet.age ?? 0) Yrs")
                            .font(Theme.Fonts.primaryFont(size: 12))
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Text(pet.breed ?? "Unknown Breed")
                        .font(Theme.Fonts.primaryFont(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(12)
            }
            .frame(width: 240)
            .background(Theme.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
        }
    }
}

struct ServiceCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .foregroundColor(Theme.textPrimary)
                }
                Text(title)
                    .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Theme.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppCoordinator())
        .environmentObject(DependencyContainer())
}
