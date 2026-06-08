import SwiftUI

struct SmartCollarView: View {
    @StateObject var viewModel: PetMedicalViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 80))
                .foregroundColor(Theme.primary)
                .padding(.top, 40)
            
            Text("Smart Collar Sync")
                .font(Theme.Fonts.primaryFont(size: 24, weight: .bold))
                .foregroundColor(Theme.textPrimary)
            
            if let collar = viewModel.collar {
                VStack(spacing: 12) {
                    Text("Connected Collar:")
                        .font(Theme.Fonts.primaryFont(size: 16))
                        .foregroundColor(Theme.textSecondary)
                    
                    Text(collar.serialNumber)
                        .font(Theme.Fonts.primaryFont(size: 20, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    if let lastSync = collar.lastSyncTime {
                        Text("Last Sync: \(lastSync.formatted())")
                            .font(Theme.Fonts.primaryFont(size: 14))
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.cardBackground)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            } else {
                Text("No smart collar linked to this pet yet. Hold an NTAG213 collar near the device to sync.")
                    .font(Theme.Fonts.primaryFont(size: 16))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            if viewModel.simulatedNFCSuccess {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Successfully Synced!")
                }
                .foregroundColor(.green)
                .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                .padding()
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(Theme.Fonts.primaryFont(size: 14))
                    .padding()
            }
            
            PrimaryButton(title: viewModel.collar == nil ? "Link Collar (Simulated)" : "Sync Now", isLoading: viewModel.isSyncingCollar) {
                viewModel.simulateNFCSync()
            }
            .padding(.bottom, 40)
        }
        .padding()
        .clawsyScreenBackground()
        .navigationTitle("Smart Collar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.collar == nil {
                viewModel.loadData()
            }
        }
    }
}
