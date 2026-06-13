import SwiftUI

// MARK: - Pet Card (signature: photo header · display name · warm tags)

struct PetCard: View {
    let pet: Pet
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                StandardPetPhoto(pet: pet, style: .gridCard)

                VStack(alignment: .leading, spacing: 5) {
                    Text(pet.name)
                        .font(Theme.Fonts.display(18))
                        .tracking(-0.3)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)

                    if let breed = pet.breed {
                        Text(breed)
                            .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(1)
                    }

                    if let age = pet.age {
                        PPTag(text: "\(age) yr\(age == 1 ? "" : "s")")
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            .glassCard(cornerRadius: Radius.lg, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }
}

// MARK: - Clinic Row

struct ClinicRowCard: View {
    let clinic: Clinic
    var distance: String? = nil
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                PPIconTile(icon: "cross.case.fill", tint: Theme.statusInfo, background: Theme.statusInfoSoft, size: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(clinic.name)
                        .font(Theme.Fonts.headline(14, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    if let location = clinic.location {
                        Text(location)
                            .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(1)
                    }
                    if let distance {
                        Label(distance, systemImage: "location.fill")
                            .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                            .foregroundStyle(Theme.forest)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textFaint)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .glassCard(cornerRadius: Radius.lg, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }
}

// MARK: - Campaign Banner (inverse forest card · coral CTA)

struct CampaignBannerCard: View {
    let campaign: Campaign
    let onDonate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(campaign.title)
                .font(Theme.Fonts.display(Typography.title3))
                .tracking(-0.3)
                .foregroundStyle(.white)
                .lineLimit(2)

            if let current = campaign.currentAmount {
                let progress = min(
                    Double(truncating: current as NSDecimalNumber) / Double(truncating: campaign.goalAmount as NSDecimalNumber),
                    1
                )
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.16))
                        Capsule()
                            .fill(Theme.coral)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(CurrencyFormatting.egp(current)) raised")
                        .foregroundStyle(.white)
                    Spacer()
                    Text("Goal \(CurrencyFormatting.egp(campaign.goalAmount))")
                        .foregroundStyle(PetPalsPalette.forest200)
                }
                .font(Theme.Fonts.label(Typography.caption, weight: .bold))
            }

            PrimaryButton(title: "Donate now", style: .accent, action: onDonate)
        }
        .padding(Spacing.md)
        .background {
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(Theme.surfaceInverse)
        }
    }
}

// MARK: - Featured Pet Card (horizontal rail card · coral match badge)

struct FeaturedPetCard: View {
    let pet: Pet
    var matchScore: Int = 0
    var onMatchTap: (() -> Void)? = nil
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    StandardPetPhoto(pet: pet, style: .featured)
                    if matchScore > 0 {
                        matchBadge
                            .padding(10)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(pet.name)
                            .font(Theme.Fonts.display(18))
                            .tracking(-0.3)
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        if let age = pet.age {
                            Text(L10n.petAgeYears(age))
                                .font(Theme.Fonts.label(Typography.caption, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    Text(pet.breed ?? L10n.readyForLove)
                        .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(14)
            }
            .frame(width: PetImageMetrics.featuredSize.width)
            .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
            .glassCard(cornerRadius: Radius.xl, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }

    @ViewBuilder
    private var matchBadge: some View {
        let label = PPBadge(text: L10n.matchScorePercent(matchScore), tone: .coral, solid: true, icon: "sparkles")

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
            HStack(spacing: 12) {
                PPIconTile(icon: statusIcon, tint: Theme.statusInfo, background: Theme.statusInfoSoft, size: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Order #\(String(order.orderId.uuidString.prefix(8).uppercased()))")
                        .font(Theme.Fonts.headline(14, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    PPBadge(text: order.status?.rawValue ?? "Processing", tone: badgeTone, dot: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textFaint)
            }
            .padding(14)
            .glassCard(cornerRadius: Radius.lg, elevation: .resting)
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

    private var badgeTone: PPBadgeTone {
        switch order.status {
        case .delivered: return .healthy
        case .cancelled: return .critical
        default: return .info
        }
    }
}

// MARK: - Featured Post Card

struct FeaturedPostCard: View {
    let post: CommunityPost
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("From the community".uppercased())
                    .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                    .foregroundStyle(Theme.textFaint)
                    .tracking(1.0)

                Text(post.title)
                    .font(Theme.Fonts.display(17))
                    .tracking(-0.3)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(post.body)
                    .font(Theme.Fonts.body(Typography.caption, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack {
                    PPBadge(text: "\(post.score)", tone: .coral, icon: "arrow.up")
                    Spacer()
                    Text("Read more")
                        .font(Theme.Fonts.label(Typography.caption, weight: .heavy))
                        .foregroundStyle(PetPalsPalette.forest500)
                }
                .padding(.top, 4)
            }
            .padding(Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: Radius.xl, elevation: .resting)
        }
        .buttonStyle(MagneticPressStyle())
    }
}
