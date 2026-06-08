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

    init() {
        ImageCacheManager.configure()
        ScrollKeyboardConfig.applyGlobalInteractiveDismiss()
    }
    
    private var appLocale: Locale {
        AppLanguage.locale
    }

    private var layoutDirection: LayoutDirection {
        AppLanguage.layoutDirection
    }

    var body: some Scene {
        WindowGroup {
            coordinatorRoot
                .environment(\.layoutDirection, layoutDirection)
                .id(appPreferredLanguage)
        }
    }
    
    private var coordinatorRoot: some View {
        ContentView()
            .environmentObject(coordinator)
            .environmentObject(dependencies)
            .environment(\.locale, appLocale)
            .onOpenURL { url in
                handleIncomingURL(url)
            }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard let petId = Self.petId(from: url) else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            coordinator.push(.petProfile(petId: petId))
        }
    }
    
    /// Supports `petpals://pet?id=` and Universal Links `https://petpals-kappa.vercel.app/pet?id=`
    private static func petId(from url: URL) -> UUID? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if url.scheme == "petpals", url.host == "pet" {
            return uuid(from: components)
        }
        
        if url.scheme == "https",
           url.host == "petpals-kappa.vercel.app",
           url.path == "/pet" || url.path.hasPrefix("/pet/") {
            if let pathId = url.path.split(separator: "/").last.flatMap({ UUID(uuidString: String($0)) }) {
                return pathId
            }
            return uuid(from: components)
        }
        
        return nil
    }
    
    private static func uuid(from components: URLComponents?) -> UUID? {
        guard let idString = components?.queryItems?.first(where: { $0.name == "id" })?.value else { return nil }
        return UUID(uuidString: idString)
    }
}
