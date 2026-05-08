import SwiftUI
import Combine

struct DonationHistoryView: View {
    @StateObject private var viewModel = DonationHistoryViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if viewModel.donations.isEmpty {
                    Text("No donation history found.")
                        .foregroundColor(Theme.textSecondary)
                        .padding(.top, 50)
                } else {
                    ForEach(viewModel.donations) { donation in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Donation to Campaign")
                                    .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                
                                if let date = donation.donationDate {
                                    Text(date, style: .date)
                                        .font(Theme.Fonts.primaryFont(size: 14))
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            Text(CurrencyFormatting.egp(donation.amount))
                                .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                                .foregroundColor(Theme.accent)
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Donation History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadDonations()
        }
    }
}

@MainActor
final class DonationHistoryViewModel: ObservableObject {
    @Published var donations: [Donation] = []
    @Published var isLoading = false
    
    private let charityService: CharityServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        charityService: CharityServiceProtocol = DependencyContainer.shared.charityService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.charityService = charityService
        self.authService = authService
    }
    
    func loadDonations() {
        isLoading = true
        Task {
            do {
                if let profile = try await authService.getCurrentUser() {
                    self.donations = try await charityService.fetchUserDonations(userId: profile.userId)
                }
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }
}
