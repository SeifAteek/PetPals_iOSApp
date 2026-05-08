//
//  PetPalsApp.swift
//  PetPals
//
//  Created by Seif Ateek on 24/04/2026.
//

import SwiftUI

@main
struct PetPalsApp: App {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var dependencies = DependencyContainer()
    @AppStorage("app_preferred_language") private var appPreferredLanguage = "system"
    
    private var appLocale: Locale {
        switch appPreferredLanguage {
        case "en": return Locale(identifier: "en_US_POSIX")
        case "ar": return Locale(identifier: "ar_EG")
        default: return Locale.current
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appPreferredLanguage {
                case "ar":
                    coordinatorRoot.environment(\.layoutDirection, .rightToLeft)
                case "en":
                    coordinatorRoot.environment(\.layoutDirection, .leftToRight)
                default:
                    coordinatorRoot
                }
            }
        }
    }
    
    private var coordinatorRoot: some View {
        CoordinatorView()
            .environmentObject(coordinator)
            .environmentObject(dependencies)
            .environment(\.locale, appLocale)
            .onOpenURL { url in
                handleIncomingURL(url)
            }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "petpals" else { return }
        
        if url.host == "pet" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let idString = components?.queryItems?.first(where: { $0.name == "id" })?.value,
               let petId = UUID(uuidString: idString) {
                
                // Allow a brief moment for the app state to settle before pushing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    coordinator.push(.petProfile(petId: petId))
                }
            }
        }
    }
}
