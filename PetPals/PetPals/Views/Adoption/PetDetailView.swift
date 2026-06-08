import SwiftUI

struct PetDetailView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let petId: UUID
    
    @State private var pet: Pet? = nil
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            if isLoading {
                VStack { ProgressView() }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
            } else if let pet = pet {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Hero (standardized 4:3 crop — fixed height)
                    ZStack(alignment: .bottom) {
                        StandardPetPhoto(pet: pet, style: .detailHero)
                        
                        // Name overlay card
                        VStack(alignment: .leading, spacing: 8) {
                            Text(pet.name)
                                .font(Theme.Fonts.primaryFont(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            HStack(spacing: 8) {
                                if let species = pet.species {
                                    PetCategoryTag(text: species, backgroundColor: Theme.primary.opacity(0.3))
                                }
                                if let breed = pet.breed {
                                    PetCategoryTag(text: breed, backgroundColor: Color.blue.opacity(0.15))
                                }
                                if let age = pet.age {
                                    PetCategoryTag(text: "\(age) yr\(age == 1 ? "" : "s")", backgroundColor: Color.purple.opacity(0.15))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Theme.cardBackground)
                        )
                        .padding(.horizontal)
                        .offset(y: 40)
                    }
                    
                    // MARK: - Details
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Status badge
                        if let status = pet.status {
                            HStack {
                                Circle()
                                    .fill(status == .available ? Color.green : Color.orange)
                                    .frame(width: 10, height: 10)
                                Text(status.rawValue)
                                    .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                                    .foregroundColor(status == .available ? .green : .orange)
                            }
                        }
                        
                        // About
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About \(pet.name)")
                                .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                            if let history = pet.medicalHistory {
                                Text(history)
                                    .font(Theme.Fonts.primaryFont(size: 15))
                                    .foregroundColor(Theme.textSecondary)
                                    .lineSpacing(4)
                            } else {
                                Text("No medical history available.")
                                    .font(Theme.Fonts.primaryFont(size: 15))
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                        
                        // Adopt button
                        HStack(spacing: 16) {
                            Button(action: {
                                if let shelterId = pet.shelterId {
                                    coordinator.push(.chatRoom(clinicId: nil, shelterId: shelterId, displayName: "Shelter"))
                                }
                            }) {
                                Image(systemName: "message.fill")
                                    .padding()
                                    .background(Theme.cardBackground)
                                    .foregroundColor(Theme.primary)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            
                            PrimaryButton(title: "Adopt Me 🐾") {
                                coordinator.push(.adoptionRules(petId: petId))
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .clawsyScreenBackground()
        .ignoresSafeArea(edges: .top)
        .task { await loadPet() }
    }
    
    private func loadPet() async {
        do {
            let service = DependencyContainer.shared.petService
            pet = try await service.fetchPetDetails(id: petId)
        } catch {
            // handle error
        }
        isLoading = false
    }
}

#Preview {
    PetDetailView(petId: UUID())
        .environmentObject(AppCoordinator())
}
