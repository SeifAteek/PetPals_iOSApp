import Foundation
import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    @Published var currentPage = 0
    let totalPages = 5
    
    func nextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        }
    }
    
    func completeOnboarding(coordinator: AppCoordinator) {
        hasCompletedOnboarding = true
        coordinator.switchRoot(to: .auth)
    }
}
