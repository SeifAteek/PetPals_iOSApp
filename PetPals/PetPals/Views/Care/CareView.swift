import SwiftUI

struct CareView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = CareViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                PremiumScreenHeader(
                    eyebrow: L10n.wellness,
                    title: L10n.petCareTitle,
                    subtitle: L10n.careSubtitle
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                    ForEach(viewModel.categories) { category in
                        PremiumServiceTile(
                            title: category.title,
                            icon: category.icon,
                            tint: category.color
                        ) {
                            route(for: category.kind)
                        }
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)

                PremiumSectionHeader(title: L10n.topVeterinarians, actionTitle: L10n.seeAll) {
                    coordinator.push(.vets)
                }

                if viewModel.isLoading {
                    PremiumLoadingView()
                        .padding(.horizontal, ScreenLayout.horizontalPadding)
                } else {
                    VStack(spacing: Spacing.xs) {
                        ForEach(Array(viewModel.filteredClinics.prefix(8))) { clinic in
                            ClinicRowCard(clinic: clinic) {
                                coordinator.push(.vetDetail(clinicId: clinic.id))
                            }
                        }
                    }
                    .padding(.horizontal, ScreenLayout.horizontalPadding)
                }

                PremiumSectionHeader(title: L10n.dailyPetTips)

                VStack(spacing: Spacing.sm) {
                    ForEach(viewModel.dailyTips) { tip in
                        TipCard(
                            title: tip.title,
                            desc: tip.desc,
                            icon: tip.icon,
                            color: tip.color
                        )
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
            }
            .padding(.top, Spacing.sm)
        }
        .dismissKeyboardOnSwipe()
        .petPalsScreenBackground()
        .onAppear {
            viewModel.refreshLocalizedCategories()
            viewModel.loadData()
        }
    }

    private func route(for kind: CareCategoryKind) {
        switch kind {
        case .veterinary: coordinator.push(.vets)
        case .petShop: coordinator.push(.shop)
        }
    }
}

struct TipCard: View {
    let title: String
    let desc: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(desc)
                    .font(Theme.Fonts.body(Typography.caption))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(Spacing.sm)
        .glassCard(cornerRadius: Radius.lg, elevation: .resting)
    }
}

#Preview {
    CareView()
        .environmentObject(AppCoordinator())
}
