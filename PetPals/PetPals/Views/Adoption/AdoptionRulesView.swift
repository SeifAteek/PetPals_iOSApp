import SwiftUI

struct AdoptionRulesView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let petId: UUID
    
    let rules: [(title: String, body: String)] = [
        ("Responsible Ownership", "By proceeding with the adoption process, please review the following adoption rules carefully. Adopters must provide a safe, caring home environment for the animal."),
        ("Health & Veterinary Care", "All adopted pets must receive regular veterinary check-ups, vaccinations, and preventative care as recommended by a licensed veterinarian."),
        ("Proper Identification", "All pets must have proper identification such as a microchip or ID tag with the owner's contact information at all times."),
        ("No Abandonment", "Adopters agree not to abandon or release pets to the wild. If you can no longer care for the pet, please contact the shelter for re-homing assistance."),
        ("Commitment", "Adoption is a lifelong commitment. Pets require time, love, financial resources, and consistent care for their entire lives.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Hero illustration
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.primary.opacity(0.2))
                        .frame(height: 200)
                    Image(systemName: "text.badge.checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70)
                        .foregroundColor(Theme.primary)
                }
                
                Text("Before proceeding with the adoption process, please review the following adoption rules carefully.")
                    .font(Theme.Fonts.primaryFont(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .lineSpacing(4)
                
                // Rules list
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(rules.enumerated()), id: \.offset) { index, rule in
                        HStack(alignment: .top, spacing: 14) {
                            Text("\(index + 1)")
                                .font(Theme.Fonts.primaryFont(size: 13, weight: .bold))
                                .frame(width: 28, height: 28)
                                .background(Theme.primary)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rule.title)
                                    .font(Theme.Fonts.primaryFont(size: 15, weight: .semibold))
                                Text(rule.body)
                                    .font(Theme.Fonts.primaryFont(size: 14))
                                    .foregroundColor(Theme.textSecondary)
                                    .lineSpacing(3)
                            }
                        }
                    }
                }
                
                PrimaryButton(title: "I Understand, Continue") {
                    coordinator.push(.adoptionForm(petId: petId))
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .clawsyScreenBackground()
        .navigationTitle("Adoption Rules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AdoptionRulesView(petId: UUID())
        .environmentObject(AppCoordinator())
}
