import SwiftUI

struct AdoptionView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = AdoptionViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                PremiumScreenHeader(
                    eyebrow: L10n.discoverEyebrow,
                    title: L10n.adoptWithHeart,
                    subtitle: L10n.discoverSubtitle
                )

                PremiumSearchField(placeholder: L10n.searchPetsPlaceholder, text: $viewModel.searchText)
                    .padding(.horizontal, ScreenLayout.horizontalPadding)
                    .onChange(of: viewModel.searchText) { _ in viewModel.applyFilters() }

                speciesFilters

                petGrid
            }
            .padding(.top, Spacing.sm)
        }
        .dismissKeyboardOnSwipe()
        .petPalsScreenBackground()
        .onAppear { viewModel.loadPets() }
    }

    private var speciesFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(viewModel.speciesOptions, id: \.self) { species in
                    let isSelected = (viewModel.selectedSpecies ?? "All") == species
                    PremiumChip(title: species, isSelected: isSelected) {
                        viewModel.selectedSpecies = species == "All" ? nil : species
                        viewModel.applyFilters()
                    }
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)
        }
    }

    @ViewBuilder
    private var petGrid: some View {
        if viewModel.isLoading {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                ForEach(0..<6, id: \.self) { _ in
                    PetGridCardSkeleton()
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)
        } else if viewModel.filteredPets.isEmpty {
            PremiumEmptyState(
                icon: "pawprint.circle",
                title: L10n.noPetsFound,
                message: L10n.noPetsFoundDesc
            )
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                ForEach(viewModel.filteredPets) { pet in
                    PetCard(pet: pet) {
                        coordinator.push(.petDetail(petId: pet.id))
                    }
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)
        }
    }
}

#Preview {
    AdoptionView()
        .environmentObject(AppCoordinator())
}
