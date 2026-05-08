import SwiftUI

struct AdoptionView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = AdoptionViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Search Bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search by name, breed...", text: $viewModel.searchText)
                        .onChange(of: viewModel.searchText) { _ in viewModel.applyFilters() }
                }
                .padding(12)
                .background(Theme.cardBackground)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                .padding(.horizontal)
                
                // MARK: - Species Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.speciesOptions, id: \.self) { species in
                            let isSelected = (viewModel.selectedSpecies ?? "All") == species
                            Button(action: {
                                viewModel.selectedSpecies = species == "All" ? nil : species
                                viewModel.applyFilters()
                            }) {
                                Text(species)
                                    .font(Theme.Fonts.primaryFont(size: 14, weight: isSelected ? .bold : .regular))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 9)
                                    .background(isSelected ? Theme.primary : Theme.cardBackground)
                                    .foregroundColor(.black)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Pet Grid
                if viewModel.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                        .padding(.top, 60)
                } else if viewModel.filteredPets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "pawprint")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No pets found")
                            .font(Theme.Fonts.primaryFont(size: 17, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.filteredPets) { pet in
                            PetCard(pet: pet) {
                                coordinator.push(.petDetail(petId: pet.id))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Adopt a Pet")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.loadPets() }
    }
}

#Preview {
    AdoptionView()
        .environmentObject(AppCoordinator())
}
