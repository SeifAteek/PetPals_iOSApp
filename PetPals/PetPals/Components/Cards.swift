import SwiftUI

struct PetCard: View {
    let pet: Pet
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 160, height: 140)
                    
                    if let avatarUrl = pet.avatarUrl, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 160, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            case .failure:
                                Image(systemName: "pawprint.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .foregroundColor(Theme.primary.opacity(0.7))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "pawprint.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .foregroundColor(Theme.primary.opacity(0.7))
                    }
                }
                
                Text(pet.name)
                    .font(Theme.Fonts.primaryFont(size: 15, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                
                if let breed = pet.breed {
                    Text(breed)
                        .font(Theme.Fonts.primaryFont(size: 12, weight: .regular))
                        .foregroundColor(Theme.textSecondary)
                }
                
                if let age = pet.age {
                    PetCategoryTag(
                        text: "\(age) yr\(age == 1 ? "" : "s") old",
                        backgroundColor: Theme.primary.opacity(0.15),
                        textColor: .black
                    )
                }
            }
            .frame(width: 160)
            .padding(12)
            .background(Theme.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 4)
        }
    }
}

struct ClinicRowCard: View {
    let clinic: Clinic
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: "cross.case.fill")
                        .foregroundColor(Theme.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(clinic.name)
                        .font(Theme.Fonts.primaryFont(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                    if let location = clinic.location {
                        Text(location)
                            .font(Theme.Fonts.primaryFont(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(14)
            .background(Theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
    }
}

struct CampaignBannerCard: View {
    let campaign: Campaign
    let onDonate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(campaign.title)
                .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            if let current = campaign.currentAmount {
                let progress = Double(truncating: current as NSDecimalNumber) / Double(truncating: campaign.goalAmount as NSDecimalNumber)
                ProgressView(value: min(progress, 1.0))
                    .tint(Theme.primary)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .cornerRadius(4)
                
                HStack {
                    Text("\(CurrencyFormatting.egp(current)) raised")
                        .font(Theme.Fonts.primaryFont(size: 13))
                    Spacer()
                    Text("Goal: \(CurrencyFormatting.egp(campaign.goalAmount))")
                        .font(Theme.Fonts.primaryFont(size: 13))
                        .foregroundColor(.gray)
                }
            }
            
            PrimaryButton(title: "Donate Now", action: onDonate)
        }
        .padding(18)
        .background(Theme.primary.opacity(0.15))
        .cornerRadius(20)
    }
}
