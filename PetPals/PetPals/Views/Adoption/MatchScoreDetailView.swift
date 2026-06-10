import SwiftUI

struct MatchScoreDetailView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    let petName: String
    let matchResult: MatchResult
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Pet name
                Text(petName)
                    .font(Theme.Fonts.display(Typography.title2))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.top, Spacing.md)
                
                // Circular progress ring
                ZStack {
                    Circle()
                        .stroke(Theme.primary.opacity(0.15), lineWidth: 12)
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(matchResult.score) / 100.0)
                        .stroke(
                            Theme.brandGradient,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.8), value: matchResult.score)
                    
                    VStack(spacing: 2) {
                        Text("\(matchResult.score)%")
                            .font(Theme.Fonts.display(Typography.title1))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Match")
                            .font(Theme.Fonts.label(Typography.caption, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(.bottom, Spacing.sm)
                
                // Factors header
                HStack {
                    Text("Score Breakdown")
                        .font(Theme.Fonts.headline(Typography.body, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, ScreenLayout.horizontalPadding)
                
                // Factor list
                if matchResult.factors.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.textSecondary.opacity(0.5))
                        Text("No personality profile data available to compute factors.")
                            .font(Theme.Fonts.body(Typography.callout))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(Spacing.lg)
                } else {
                    VStack(spacing: Spacing.xs) {
                        ForEach(matchResult.factors) { factor in
                            factorRow(factor)
                        }
                    }
                    .padding(.horizontal, ScreenLayout.horizontalPadding)
                }
                
                Spacer(minLength: Spacing.lg)
            }
        }
        .petPalsScreenBackground()
    }
    
    private func factorRow(_ factor: MatchFactor) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(factor.points >= 0 ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: factor.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(factor.points >= 0 ? Color.green : Color.red)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(factor.category)
                        .font(Theme.Fonts.headline(Typography.callout, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(factor.points >= 0 ? "+\(factor.points)" : "\(factor.points)")
                        .font(Theme.Fonts.label(Typography.callout, weight: .bold))
                        .foregroundStyle(factor.points >= 0 ? Color.green : Color.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background {
                            Capsule()
                                .fill(factor.points >= 0 ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                        }
                }
                Text(factor.explanation)
                    .font(Theme.Fonts.body(Typography.caption))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Spacing.sm)
        .glassCard(cornerRadius: Radius.md, elevation: .resting)
    }
}
