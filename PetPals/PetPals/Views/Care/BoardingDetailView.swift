import SwiftUI

struct BoardingDetailView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let clinicId: UUID
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Facility Image
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Theme.primary.opacity(0.1))
                        .frame(height: 250)
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .foregroundColor(Theme.primary.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Title & Price
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pet Paradise")
                                .font(Theme.Fonts.primaryFont(size: 24, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            Text("Cityville, NY")
                                .font(Theme.Fonts.primaryFont(size: 14))
                                .foregroundColor(Theme.textSecondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(L10n.boardingSamplePrice)
                                .font(Theme.Fonts.primaryFont(size: 24, weight: .bold))
                                .foregroundColor(Theme.primary)
                            Text(L10n.perDay)
                                .font(Theme.Fonts.primaryFont(size: 12))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    
                    // MARK: - Services
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Our Services")
                            .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        
                        VStack(spacing: 12) {
                            serviceRow(icon: "moon.fill", title: "Overnight Boarding", desc: "Cozy and safe environment for your pet.")
                            serviceRow(icon: "figure.walk", title: "Playtime and Exercise", desc: "Regular daily exercise and social play.")
                            serviceRow(icon: "fork.knife", title: "Special Diet", desc: "Customized feeding plans available.")
                        }
                    }
                    
                    // MARK: - About
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About the Facility")
                            .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Text("Pet Paradise is a top-rated boarding facility with over 2000 sq ft of indoor and outdoor space. We provide a home-away-from-home experience for your beloved companions.")
                            .font(Theme.Fonts.primaryFont(size: 15))
                            .foregroundColor(Theme.textSecondary)
                            .lineSpacing(4)
                    }
                    
                    PrimaryButton(title: L10n.bookNow) {
                        coordinator.beginCheckout(
                            CheckoutDraft(
                                clinicId: clinicId,
                                providerDisplayName: "Pet Paradise",
                                amountEGP: 25,
                                serviceSummary: L10n.boardingBookingSummary,
                                kind: .boarding,
                                petId: nil,
                                petName: nil
                            )
                        )
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .padding(24)
                .background(Theme.cardBackground)
                .cornerRadius(30)
                .offset(y: -30)
            }
        }
        .clawsyScreenBackground()
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func serviceRow(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(Theme.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Fonts.primaryFont(size: 15, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                Text(desc)
                    .font(Theme.Fonts.primaryFont(size: 13))
                    .foregroundColor(Theme.textSecondary)
            }
        }
    }
}

#Preview {
    NavigationView {
        BoardingDetailView(clinicId: UUID())
            .environmentObject(AppCoordinator())
    }
}
