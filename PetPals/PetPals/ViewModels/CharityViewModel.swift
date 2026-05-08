import Foundation
import SwiftUI
import Combine

@MainActor
final class CharityViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var userDonations: [Donation] = []
    
    var totalDonatedAmount: Decimal {
        userDonations.reduce(0) { $0 + $1.amount }
    }
    
    var totalDonationsCount: Int {
        userDonations.count
    }
    
    private let charityService: CharityServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        charityService: CharityServiceProtocol = DependencyContainer.shared.charityService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.charityService = charityService
        self.authService = authService
    }
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                async let fetchCamps = charityService.fetchCampaigns()
                
                var fetchDons: [Donation] = []
                if let user = try await authService.getCurrentUser() {
                    fetchDons = try await charityService.fetchUserDonations(userId: user.userId)
                }
                
                let camps = try await fetchCamps
                
                self.campaigns = camps
                self.userDonations = fetchDons
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
