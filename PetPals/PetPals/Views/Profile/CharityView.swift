import SwiftUI

struct CharityView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = CharityViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Impact Banner
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                        Text("YOUR IMPACT")
                            .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Text(CurrencyFormatting.egp(viewModel.totalDonatedAmount))
                        .font(Theme.Fonts.primaryFont(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("donated across \(viewModel.totalDonationsCount) campaigns")
                        .font(Theme.Fonts.primaryFont(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.primary)
                .cornerRadius(24)
                .padding(.horizontal)
                
                // MARK: - Campaigns
                if viewModel.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }.padding(.top, 20)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.campaigns) { campaign in
                                CampaignBannerCard(campaign: campaign) {
                                    coordinator.push(.charityDetail(campaignId: campaign.id))
                                }
                                .frame(width: 300)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // MARK: - Donation History
                VStack(alignment: .leading, spacing: 16) {
                    Text("MY DONATION HISTORY")
                        .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal)
                    
                    if viewModel.userDonations.isEmpty {
                        Text("No donation history yet.")
                            .font(Theme.Fonts.primaryFont(size: 15))
                            .foregroundColor(Theme.textSecondary)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.userDonations) { donation in
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "arrow.up.right")
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Donation")
                                            .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                                            .foregroundColor(Theme.textPrimary)
                                        
                                        if let date = donation.donationDate {
                                            Text(date, style: .date)
                                                .font(Theme.Fonts.primaryFont(size: 14))
                                                .foregroundColor(Theme.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text(CurrencyFormatting.egp(donation.amount))
                                        .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                                        .foregroundColor(Theme.textPrimary)
                                }
                                .padding()
                                .background(Theme.cardBackground)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
                
                Spacer(minLength: 40)
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Campaigns")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.loadData() }
    }
}

#Preview {
    NavigationView {
        CharityView()
            .environmentObject(AppCoordinator())
    }
}
