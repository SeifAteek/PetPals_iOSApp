import SwiftUI

struct PetCard: View {
    let pet: Pet
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                StandardPetPhoto(pet: pet, style: .gridCard)

                Text(pet.name)
                    .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                if let breed = pet.breed {
                    Text(breed)
                        .font(Theme.Fonts.body(Typography.caption))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }

                if let age = pet.age {
                    PetCategoryTag(
                        text: "\(age) yr\(age == 1 ? "" : "s")",
                        backgroundColor: Theme.primary.opacity(0.14),
                        textColor: Theme.brandDeep
                    )
                }
            }
            .padding(Spacing.sm)
            .glassCard(cornerRadius: Radius.lg, elevation: .raised)
        }
        .buttonStyle(MagneticPressStyle())
    }
}

struct ClinicRowCard: View {
    let clinic: Clinic
    var distance: String? = nil
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(Theme.primary.opacity(0.14))
                        .frame(width: 52, height: 52)
                    Image(systemName: "cross.case.fill")
                        .foregroundStyle(Theme.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(clinic.name)
                        .font(Theme.Fonts.headline(Typography.callout, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    if let location = clinic.location {
                        Text(location)
                            .font(Theme.Fonts.body(Typography.caption))
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(1)
                    }
                    if let distance {
                        Label(distance, systemImage: "location.fill")
                            .font(Theme.Fonts.body(Typography.caption))
                            .foregroundStyle(Theme.primary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.5))
            }
            .padding(Spacing.sm)
            .glassCard(cornerRadius: Radius.md, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }
}

struct CampaignBannerCard: View {
    let campaign: Campaign
    let onDonate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(campaign.title)
                .font(Theme.Fonts.headline(Typography.body, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)

            if let current = campaign.currentAmount {
                let progress = min(
                    Double(truncating: current as NSDecimalNumber) / Double(truncating: campaign.goalAmount as NSDecimalNumber),
                    1
                )
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.brandDark.opacity(0.08))
                        Capsule()
                            .fill(Theme.brandGradient)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(CurrencyFormatting.egp(current)) raised")
                    Spacer()
                    Text("Goal \(CurrencyFormatting.egp(campaign.goalAmount))")
                        .foregroundStyle(Theme.textSecondary)
                }
                .font(Theme.Fonts.body(Typography.caption))
            }

            PrimaryButton(title: "Donate Now", action: onDonate)
        }
        .padding(Spacing.md)
        .background {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Theme.heroGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .stroke(Theme.glassStroke, lineWidth: 1)
                )
        }
    }
}

struct FeaturedPetCard: View {
    let pet: Pet
    var matchScore: Int = 0
    var onMatchTap: (() -> Void)? = nil
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    StandardPetPhoto(pet: pet, style: .featured)
                    if matchScore > 0 {
                        matchBadge
                            .padding(8)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(pet.name)
                            .font(Theme.Fonts.headline(Typography.body, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        if let age = pet.age {
                            Text(L10n.petAgeYears(age))
                                .font(Theme.Fonts.label(Typography.caption))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    Text(pet.breed ?? L10n.readyForLove)
                        .font(Theme.Fonts.body(Typography.caption))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(Spacing.sm)
            }
            .frame(width: PetImageMetrics.featuredSize.width)
            .background {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                            .stroke(Theme.glassStroke, lineWidth: 1)
                    )
            }
        }
        .buttonStyle(MagneticPressStyle())
    }

    @ViewBuilder
    private var matchBadge: some View {
        let label = Text(L10n.matchScorePercent(matchScore))
            .font(Theme.Fonts.label(Typography.caption, weight: .bold))
            .foregroundStyle(Theme.textOnBrand)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                Capsule().fill(Theme.brandGradient)
            }

        if let onMatchTap {
            Button {
                onMatchTap()
            } label: {
                label
            }
            .buttonStyle(.plain)
        } else {
            label
        }
    }
}

// MARK: - Active Order Card

struct ActiveOrderCard: View {
    let order: ShopOrder
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: statusIcon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Theme.brandGradient)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Order #\(String(order.orderId.uuidString.prefix(8).uppercased()))")
                            .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Status: \(order.status?.rawValue ?? "Processing")")
                            .font(Theme.Fonts.label(Typography.caption))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Theme.textSecondary.opacity(0.5))
                }
            }
            .padding(Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                            .stroke(Theme.glassStroke, lineWidth: 1)
                    )
            }
        }
        .buttonStyle(MagneticPressStyle())
    }
    
    private var statusIcon: String {
        switch order.status {
        case .processing: return "cart.fill"
        case .shipped: return "shippingbox.fill"
        case .delivered: return "house.fill"
        case .cancelled: return "xmark.circle.fill"
        default: return "shippingbox.fill"
        }
    }
}

// MARK: - Featured Post Card

struct FeaturedPostCard: View {
    let post: CommunityPost
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Featured Community Post")
                            .font(Theme.Fonts.label(Typography.caption, weight: .bold))
                            .foregroundStyle(Theme.brandDeep)
                        
                        Text(post.title)
                            .font(Theme.Fonts.headline(Typography.body, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(2)
                        
                        Text(post.body)
                            .font(Theme.Fonts.body(Typography.callout))
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(Theme.brandWarm)
                        Text("\(post.score)")
                            .font(Theme.Fonts.label(Typography.caption, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    Spacer()
                    Text("Read more")
                        .font(Theme.Fonts.label(Typography.caption, weight: .bold))
                        .foregroundStyle(Theme.brandDeep)
                }
                .padding(.top, Spacing.xs)
            }
            .padding(Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                            .stroke(Theme.glassStroke, lineWidth: 1)
                    )
            }
        }
        .buttonStyle(MagneticPressStyle())
    }
}
