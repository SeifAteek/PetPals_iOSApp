import SwiftUI

struct DonationView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let campaign: Campaign
    @State private var amount: String = ""
    @State private var selectedAmount: Int? = 50
    @State private var isLoading = false
    @State private var showSuccess = false
    
    let presets = [10, 25, 50, 100]
    
    var body: some View {
        VStack {
            if showSuccess {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                    Text("Thank You!")
                        .font(Theme.Fonts.primaryFont(size: 24, weight: .bold))
                    Text("Your donation to \(campaign.title) was successful.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Theme.textSecondary)
                    PrimaryButton(title: "Back to Home") {
                        coordinator.popToRoot()
                    }
                }
                .padding(24)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Support \(campaign.title)")
                                .font(Theme.Fonts.primaryFont(size: 24, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            Text("Your contribution helps provide medical care and shelter.")
                                .font(Theme.Fonts.primaryFont(size: 15))
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select Amount")
                                .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(presets, id: \.self) { preset in
                                    Button(action: {
                                        selectedAmount = preset
                                        amount = ""
                                    }) {
                                        Text(CurrencyFormatting.egp(Decimal(preset)))
                                            .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .background(selectedAmount == preset ? Theme.primary : Theme.cardBackground)
                                            .foregroundColor(selectedAmount == preset ? .white : Theme.textPrimary)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedAmount == preset ? Theme.primary : Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            
                            HStack {
                                Text("EGP")
                                    .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                                TextField("Other Amount", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: amount) { _ in
                                        selectedAmount = nil
                                    }
                            }
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        PrimaryButton(title: "Confirm Donation", isLoading: isLoading) {
                            confirmDonation()
                        }
                    }
                    .padding(24)
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Donate")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func confirmDonation() {
        isLoading = true
        let donationAmount = selectedAmount.map { Decimal($0) } ?? Decimal(string: amount) ?? 0
        
        Task {
            do {
                let profile = try await DependencyContainer.shared.authService.getCurrentUser()
                
                let donation = Donation(
                    donationId: UUID(),
                    campaignId: campaign.campaignId,
                    userId: profile?.userId,
                    amount: donationAmount,
                    donationDate: Date()
                )
                
                try await DependencyContainer.shared.charityService.createDonation(donation)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.showSuccess = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Optionally show error state
                }
            }
        }
    }
}
