import SwiftUI

/// "You" tab hub — each row opens its own screen via navigation push.
struct ProfileHubView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var petViewModel = PetViewModel()
    @StateObject private var chatViewModel = ChatViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                PremiumScreenHeader(
                    eyebrow: L10n.yourSpace,
                    title: coordinator.lastFetchedProfile?.userName ?? L10n.petParentDefault,
                    subtitle: L10n.yourSubtitleShort
                )

                avatarStrip

                VStack(spacing: Spacing.sm) {
                    PremiumHubRow(
                        icon: "pawprint.fill",
                        title: L10n.myPets,
                        subtitle: petSubtitle,
                        badge: petViewModel.myPets.isEmpty ? nil : "\(petViewModel.myPets.count)"
                    ) {
                        coordinator.push(.myPets)
                    }

                    PremiumHubRow(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: L10n.messages,
                        subtitle: L10n.clinicsShelters,
                        badge: chatViewModel.chatThreads.isEmpty ? nil : "\(chatViewModel.chatThreads.count)"
                    ) {
                        coordinator.push(.messages)
                    }

                    PremiumHubRow(
                        icon: "heart.circle.fill",
                        title: L10n.giveBack,
                        subtitle: L10n.campaignsDonations
                    ) {
                        coordinator.push(.charity)
                    }

                    PremiumHubRow(
                        icon: "gearshape.fill",
                        title: L10n.settings,
                        subtitle: L10n.profileSettingsSubtitle
                    ) {
                        coordinator.push(.settings)
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
            }
            .padding(.top, Spacing.sm)
        }
        .dismissKeyboardOnSwipe()
        .petPalsScreenBackground()
        .onAppear {
            petViewModel.loadMyPets()
            chatViewModel.loadThreads()
        }
    }

    @ViewBuilder
    private var avatarStrip: some View {
        HStack(spacing: Spacing.sm) {
            Group {
                if let urlString = coordinator.lastFetchedProfile?.avatarUrl,
                   let url = ImageURL.from(urlString) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipped()
                    } placeholder: {
                        avatarPlaceholder
                    }
                } else {
                    avatarPlaceholder
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
            .overlay(Circle().stroke(Theme.borderStrong, lineWidth: 2))

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.memberSince.uppercased())
                    .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                    .foregroundStyle(Theme.textFaint)
                    .tracking(1.0)
                Text(L10n.managePetFamily)
                    .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
        }
        .padding(Spacing.sm)
        .glassCard(cornerRadius: Radius.xl, elevation: .resting)
        .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Circle().fill(Theme.forestSoft)
            Image(systemName: "person.fill")
                .foregroundStyle(Theme.forest)
        }
    }

    private var petSubtitle: String {
        if petViewModel.myPets.isEmpty { return L10n.addFirstCompanion }
        return L10n.companionsCount(petViewModel.myPets.count)
    }
}

#Preview {
    ProfileHubView()
        .environmentObject(AppCoordinator())
}
