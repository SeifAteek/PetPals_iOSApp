import SwiftUI

struct AdoptionConfirmationView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let petId: UUID
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success icon
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.2))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70)
                    .foregroundColor(Theme.primary)
            }
            
            VStack(spacing: 12) {
                Text("Thank You!")
                    .font(Theme.Fonts.primaryFont(size: 28, weight: .bold))
                
                Text("Thank you for submitting your adoption appointment request! We're excited to help you find your new companion.")
                    .font(Theme.Fonts.primaryFont(size: 16))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }
            
            // Appointment summary card
            VStack(alignment: .leading, spacing: 12) {
                Text("What's Next?")
                    .font(Theme.Fonts.primaryFont(size: 15, weight: .bold))
                
                infoRow(icon: "envelope.fill", text: "You'll receive a confirmation email shortly.")
                infoRow(icon: "phone.fill", text: "Our team will call you to confirm the appointment.")
                infoRow(icon: "checkmark.seal.fill", text: "Once approved, you can pick up your new companion!")
            }
            .padding(20)
            .background(Theme.cardBackground)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 24)
            
            Spacer()
            
            PrimaryButton(title: "Back to Home") {
                coordinator.switchRoot(to: .mainTabs)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .clawsyScreenBackground()
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.primary)
                .frame(width: 22)
            Text(text)
                .font(Theme.Fonts.primaryFont(size: 14))
                .foregroundColor(Theme.textSecondary)
        }
    }
}

#Preview {
    AdoptionConfirmationView(petId: UUID())
        .environmentObject(AppCoordinator())
}
