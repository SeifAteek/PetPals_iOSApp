import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var keyboard: KeyboardObserver
    @State private var selectedTab: PremiumTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .discover:
                    AdoptionView()
                case .community:
                    CommunityFeedView()
                case .care:
                    CareView()
                case .you:
                    ProfileHubView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(Motion.gentle, value: selectedTab)
            .tabBarScrollInset(keyboard: keyboard)

            PremiumTabBar(selected: $selectedTab) {
                coordinator.push(.aiAssistant)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.sm)
        }
        .petPalsScreenBackground()
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppCoordinator())
}
