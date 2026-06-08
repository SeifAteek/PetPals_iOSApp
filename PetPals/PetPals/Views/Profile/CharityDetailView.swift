import SwiftUI

struct CharityDetailView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let campaignId: UUID
    
    @State private var campaign: Campaign? = nil
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView().frame(maxWidth: .infinity).padding(.top, 50)
            } else if let campaign = campaign {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Banner
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Theme.primary.opacity(0.1))
                            .frame(height: 200)
                        Image(systemName: "heart.text.square.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .foregroundColor(Theme.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(campaign.title)
                            .font(Theme.Fonts.primaryFont(size: 24, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        
                        Text(campaign.description ?? "Help us make a difference in the lives of pets in need.")
                            .font(Theme.Fonts.primaryFont(size: 15))
                            .foregroundColor(Theme.textSecondary)
                            .lineSpacing(4)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            let raised = campaign.currentAmount ?? 0
                            let goal = campaign.goalAmount
                            let progress = min(Double(truncating: raised as NSDecimalNumber) / Double(truncating: goal as NSDecimalNumber), 1.0)
                            
                            HStack {
                                Text("\(CurrencyFormatting.egp(raised)) raised")
                                    .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                                    .foregroundColor(Theme.primary)
                                Spacer()
                                Text("\(Int(progress * 100))%")
                                    .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            
                            ProgressView(value: progress)
                                .tint(Theme.primary)
                                .scaleEffect(x: 1, y: 2)
                                .cornerRadius(4)
                            
                            Text("Goal: \(CurrencyFormatting.egp(goal))")
                                .font(Theme.Fonts.primaryFont(size: 13))
                                .foregroundColor(Theme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(20)
                        .background(Theme.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About the Charity")
                                .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("Every contribution makes a difference. Your donation goes directly to food, shelter, and medical bills for our feline residents.")
                                .font(Theme.Fonts.primaryFont(size: 14))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }

                    PrimaryButton(title: "Donate Now") {
                        coordinator.push(.donation(campaign: campaign))
                    }

                    if let shelterId = campaign.shelterId {
                        EntityReviewsSection(entityType: .shelter, entityId: shelterId)
                    }
                }
                .padding(.bottom, 40)
            } else {
                Text("Campaign not found").padding()
            }
        }
        .padding(24)
        .clawsyScreenBackground()
        .navigationTitle("Campaign Details")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadData() }
    }
    
    private func loadData() async {
        do {
            campaign = try await DependencyContainer.shared.charityService.fetchCampaignDetails(id: campaignId)
        } catch {
            // Error handling
        }
        isLoading = false
    }
}

#Preview {
    NavigationView {
        CharityDetailView(campaignId: UUID())
            .environmentObject(AppCoordinator())
    }
}
