//
//  ContentView.swift
//  PetPals
//
//  Created by Seif Ateek on 24/04/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var dependencies: DependencyContainer
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        CoordinatorView()
            .environmentObject(coordinator)
            .environmentObject(dependencies)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                updateWindowStyle(isDark: isDarkMode)
            }
            .onChange(of: isDarkMode) { newValue in
                updateWindowStyle(isDark: newValue)
            }
    }
    
    private func updateWindowStyle(isDark: Bool) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
        }
    }
}

#Preview {
    ContentView()
}
