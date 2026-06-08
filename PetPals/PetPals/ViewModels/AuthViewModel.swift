import SwiftUI
import Combine
import Foundation
import Supabase
import Auth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var firstName = ""
    @Published var lastName = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = DependencyContainer.shared.authService) {
        self.authService = authService
    }
    
    func login(coordinator: AppCoordinator) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let profile = try await authService.login(email: email, password: password)
                isLoading = false
                handlePostAuthRouting(profile: profile, coordinator: coordinator)
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func register(coordinator: AppCoordinator) {
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let userName = "\(firstName) \(lastName)"
                let profile = try await authService.register(email: email, password: password, userName: userName, type: .adopter)
                isLoading = false
                handlePostAuthRouting(profile: profile, coordinator: coordinator)
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signInWithGoogle(coordinator: AppCoordinator) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let url = try await SupabaseClientManager.shared.client.auth.getOAuthSignInURL(provider: .google)
                
                await MainActor.run {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    isLoading = false
                }
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func handlePostAuthRouting(profile: Profile, coordinator: AppCoordinator) {
        coordinator.lastFetchedProfile = profile
        Task {
            await coordinator.routeSignedInUser()
        }
    }
}
