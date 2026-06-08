import SwiftUI

struct CharityView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = CharityViewModel()
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                PremiumScreenHeader(
                    eyebrow: L10n.impact,
                    title: L10n.giveBackTitle,
                    subtitle: L10n.giveBackSubtitle
                )
                charityBody
            }
            .padding(.top, Spacing.sm)
            .padding(.bottom, ScreenLayout.tabBarScrollInset)
        }
        .dismissKeyboardOnSwipe()
        .petPalsScreenBackground()
        .navigationTitle(L10n.giveBack)
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.loadData() }
    }

    private var charityBody: some View {
        Group {
            impactBanner
            campaignsCarousel
            donationHistory
        }
    }

    private var impactBanner: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.white)
                Text(L10n.yourImpact)
                    .font(Theme.Fonts.label(Typography.caption, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            Text(CurrencyFormatting.egp(viewModel.totalDonatedAmount))
                .font(Theme.Fonts.display(Typography.title1))
                .foregroundStyle(.white)
            Text(L10n.donatedAcross(campaignCount: viewModel.totalDonationsCount))
                .font(Theme.Fonts.body(Typography.callout))
                .foregroundStyle(.white.opacity(0.88))
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Theme.brandGradient)
                .shadow(color: Theme.primary.opacity(0.3), radius: 20, y: 10)
        }
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    @ViewBuilder
    private var campaignsCarousel: some View {
        if viewModel.isLoading {
            PremiumLoadingView()
                .padding(.horizontal, ScreenLayout.horizontalPadding)
        } else if viewModel.campaigns.isEmpty {
            PremiumEmptyState(
                icon: "heart.circle",
                title: L10n.noActiveCampaigns,
                message: L10n.noActiveCampaignsDesc
            )
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(viewModel.campaigns) { campaign in
                        CampaignBannerCard(campaign: campaign) {
                            coordinator.push(.charityDetail(campaignId: campaign.id))
                        }
                        .frame(width: 300)
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
            }
        }
    }

    private var donationHistory: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            PremiumSectionHeader(title: L10n.donationHistoryTitle)
            if viewModel.userDonations.isEmpty {
                Text(L10n.noDonationsYet)
                    .font(Theme.Fonts.body(Typography.callout))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, ScreenLayout.horizontalPadding)
            } else {
                VStack(spacing: Spacing.xs) {
                    ForEach(viewModel.userDonations) { donation in
                        HStack(spacing: Spacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(Theme.primary.opacity(0.14))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "arrow.up.right")
                                    .foregroundStyle(Theme.primary)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Donation")
                                    .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                                    .foregroundStyle(Theme.textPrimary)
                                if let date = donation.donationDate {
                                    Text(date, style: .date)
                                        .font(Theme.Fonts.body(Typography.caption))
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                            Spacer()
                            Text(CurrencyFormatting.egp(donation.amount))
                                .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                                .foregroundStyle(Theme.primary)
                        }
                        .padding(Spacing.sm)
                        .glassCard(cornerRadius: Radius.md, elevation: .resting)
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
            }
        }
    }
}

#Preview {
    CharityView()
        .environmentObject(AppCoordinator())
}
