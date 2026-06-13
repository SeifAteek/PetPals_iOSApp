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

                        // Name card overlapping the photo
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(pet.name)
                                    .font(Theme.Fonts.display(Typography.title2))
                                    .tracking(-0.4)
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                if let status = pet.status {
                                    PPBadge(
                                        text: status.rawValue,
                                        tone: status == .available ? .healthy : .warn,
                                        dot: true
                                    )
                                }
                            }

                            HStack(spacing: 7) {
                                if let species = pet.species {
                                    PPTag(text: species, icon: "pawprint.fill")
                                }
                                if let breed = pet.breed {
                                    PPTag(text: breed)
                                }
                                if let age = pet.age {
                                    PPTag(text: "\(age) yr\(age == 1 ? "" : "s")")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Spacing.sm)
                        .glassCard(cornerRadius: Radius.xl, elevation: .raised)
                        .padding(.horizontal, ScreenLayout.horizontalPadding)
                        .offset(y: 40)
                    }

                    // MARK: - Details
                    VStack(alignment: .leading, spacing: 20) {

                        // About
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About \(pet.name)")
                                .font(Theme.Fonts.display(Typography.title3))
                                .tracking(-0.3)
                                .foregroundStyle(Theme.textPrimary)
                            if let history = pet.medicalHistory {
                                Text(history)
                                    .font(Theme.Fonts.body(Typography.callout))
                                    .foregroundStyle(Theme.textBody)
                                    .lineSpacing(5)
                            } else {
                                Text("No medical history available.")
                                    .font(Theme.Fonts.body(Typography.callout))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }

                        // Actions
                        HStack(spacing: 12) {
                            Button(action: {
                                if let shelterId = pet.shelterId {
                                    coordinator.push(.chatRoom(clinicId: nil, shelterId: shelterId, displayName: "Shelter"))
                                }
                            }) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Theme.forest)
                                    .frame(width: 50, height: 50)
                                    .background {
                                        Circle().fill(Theme.surface)
                                    }
                                    .overlay {
                                        Circle().stroke(Theme.borderStrong, lineWidth: 1.5)
                                    }
                            }
                            .buttonStyle(MagneticPressStyle())

                            PrimaryButton(title: "Adopt \(pet.name)", style: .accent, icon: "heart.fill") {
                                coordinator.push(.adoptionRules(petId: petId))
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.top, 64)
                    .padding(.horizontal, ScreenLayout.horizontalPadding)
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
