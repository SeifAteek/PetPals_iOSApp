import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var keyboard: KeyboardObserver
    @ObservedObject private var collarSession = CollarSession.shared
    @State private var selectedTab: PremiumTab = .home

    private var visibleTabs: [PremiumTab] {
        var tabs: [PremiumTab] = [.home, .discover, .community, .care, .you]
        if collarSession.isPaired { tabs.append(.collar) }
        return tabs
    }

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
                case .collar:
                    if let petId = collarSession.pairedPetId {
                        CollarDashboardView(petId: petId, showsBackButton: false)
                    } else {
                        HomeView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(Motion.gentle, value: selectedTab)
            .tabBarScrollInset(keyboard: keyboard)

            if !keyboard.isVisible {
                AIFloatingButton {
                    coordinator.push(.aiAssistant)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, Spacing.md)
                .padding(.bottom, ScreenLayout.aiFabBottomInset)
                .transition(.scale.combined(with: .opacity))
            }

            PremiumTabBar(selected: $selectedTab, tabs: visibleTabs)
        }
        .animation(Motion.tab, value: keyboard.isVisible)
        .animation(Motion.tab, value: collarSession.isPaired)
        .petPalsScreenBackground()
        .onChange(of: collarSession.isPaired) { paired in
            // If the Collar tab disappears while selected, fall back to Home.
            if !paired, selectedTab == .collar { selectedTab = .home }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppCoordinator())
}
