import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                AdoptionView()
                    .tabItem {
                        Label("Adopt", systemImage: "heart.fill")
                    }
                    .tag(1)
                
                MyPetsView()
                    .tabItem {
                        Label("My Pets", systemImage: "pawprint.fill")
                    }
                    .tag(2)
                
                MessagesListView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(3)
                
                CharityView()
                    .tabItem {
                        Label("Campaigns", systemImage: "heart.text.square.fill")
                    }
                    .tag(4)
            }
            .tint(Theme.primary)
            
            // Floating AI Button
            Button(action: {
                coordinator.push(.aiAssistant)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.primary)
                        .frame(width: 60, height: 60)
                        .shadow(color: Theme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 80) // Above tab bar
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppCoordinator())
}
