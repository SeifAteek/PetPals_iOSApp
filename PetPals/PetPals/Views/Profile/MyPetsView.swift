import SwiftUI

struct MyPetsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = PetViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.top, 100)
                } else if let err = viewModel.errorMessage, !err.isEmpty {
                    Text(err)
                        .font(Theme.Fonts.primaryFont(size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                } else if viewModel.myPets.isEmpty {
                    EmptyMyPetsView()
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.myPets) { pet in
                            MyPetRowCard(pet: pet) {
                                coordinator.push(.petProfile(petId: pet.id))
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    PrimaryButton(title: "Add Another Pet") {
                        coordinator.push(.addPetFlow)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .padding(.vertical)
            .padding(.bottom, ScreenLayout.tabBarScrollInset)
        }
        .dismissKeyboardOnSwipe()
        .petPalsScreenBackground()
        .navigationTitle(L10n.myPets)
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.loadMyPets() }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { coordinator.push(.addPetFlow) }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Theme.primary)
                }
            }
        }
    }
}

struct EmptyMyPetsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 200, height: 200)
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .foregroundColor(Theme.primary.opacity(0.5))
            }
            
            VStack(spacing: 12) {
                Text("You haven't added or adopted any pets yet.")
                    .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text("Start your journey by adopting a pet or add your existing companion to PetPals.")
                    .font(Theme.Fonts.primaryFont(size: 14))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 16) {
                PrimaryButton(title: "Adopt a pet") {
                    coordinator.push(.adoption)
                }
                
                Button(action: { coordinator.push(.addPetFlow) }) {
                    Text("Already have a pet")
                        .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.cardBackground)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(minHeight: 500)
    }
}

struct MyPetRowCard: View {
    let pet: Pet
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                StandardPetPhoto(pet: pet, style: .listThumb)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(pet.name)
                        .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text(pet.breed ?? pet.species ?? "Companion")
                        .font(Theme.Fonts.primaryFont(size: 14))
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(Spacing.sm)
            .glassCard(cornerRadius: Radius.md, elevation: .resting)
        }
    }
}

#Preview {
    NavigationView {
        MyPetsView()
            .environmentObject(AppCoordinator())
    }
}
