import SwiftUI

struct PersonalitySetupView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var dependencies: DependencyContainer
    @State private var answers: [String: String] = [:]
    @State private var completed = false
    @State private var showTest = true

    var body: some View {
        VStack(spacing: Spacing.lg) {
            PremiumScreenHeader(
                eyebrow: L10n.personalitySetupEyebrow,
                title: L10n.personalitySetupTitle,
                subtitle: L10n.personalitySetupSubtitle
            )
            .padding(.horizontal, ScreenLayout.horizontalPadding)
            Spacer()
        }
        .petPalsScreenBackground()
        .fullScreenCover(isPresented: $showTest) {
            PersonalityTestSheetView(answers: $answers, completed: $completed) { submitted in
                guard let userId = coordinator.lastFetchedProfile?.userId else {
                    throw NSError(domain: "PersonalitySetup", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired."])
                }
                _ = try await dependencies.personalityService.saveProfile(userId: userId, answers: submitted)
            }
        }
        .onChange(of: completed) { _, done in
            if done { coordinator.switchRoot(to: .mainTabs) }
        }
    }
}
