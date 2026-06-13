import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let eyebrow: String
    let title: String
    let description: String
    let imageName: String
    let gradient: [Color]
}

struct OnboardingView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var dragOffset: CGFloat = 0

    private var pages: [OnboardingPage] {
        [
            // gradient[0] = soft halo tint · gradient[1] = icon tint
            OnboardingPage(
                eyebrow: L10n.onboardingWelcomeEyebrow,
                title: L10n.onboardingWelcomeTitle,
                description: L10n.onboardingWelcomeDesc,
                imageName: "pawprint.fill",
                gradient: [Theme.forestSoft, Theme.forest]
            ),
            OnboardingPage(
                eyebrow: L10n.onboardingDiscoverEyebrow,
                title: L10n.onboardingDiscoverTitle,
                description: L10n.onboardingDiscoverDesc,
                imageName: "heart.fill",
                gradient: [Theme.coralSoft, Theme.coral]
            ),
            OnboardingPage(
                eyebrow: L10n.onboardingCareEyebrow,
                title: L10n.onboardingCareTitle,
                description: L10n.onboardingCareDesc,
                imageName: "stethoscope",
                gradient: [Theme.statusInfoSoft, Theme.statusInfo]
            ),
            OnboardingPage(
                eyebrow: L10n.onboardingNearbyEyebrow,
                title: L10n.onboardingNearbyTitle,
                description: L10n.onboardingNearbyDesc,
                imageName: "mappin.and.ellipse",
                gradient: [Theme.statusWarnSoft, Theme.statusWarn]
            ),
            OnboardingPage(
                eyebrow: L10n.onboardingWellnessEyebrow,
                title: L10n.onboardingWellnessTitle,
                description: L10n.onboardingWellnessDesc,
                imageName: "chart.line.uptrend.xyaxis",
                gradient: [Theme.sandSoft, Theme.forestDeep]
            )
        ]
    }

    var body: some View {
        ZStack {
            PetPalsAmbientBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(L10n.skip) {
                        Haptic.light()
                        viewModel.completeOnboarding(coordinator: coordinator)
                    }
                    .font(Theme.Fonts.label(Typography.callout, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(Motion.spring, value: viewModel.currentPage)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                pageIndicator
                bottomControls
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { i in
                Capsule()
                    .fill(i == viewModel.currentPage ? Theme.primary : Theme.textSecondary.opacity(0.25))
                    .frame(width: i == viewModel.currentPage ? 28 : 8, height: 8)
                    .animation(Motion.spring, value: viewModel.currentPage)
            }
        }
        .padding(.vertical, Spacing.md)
    }

    private var bottomControls: some View {
        VStack(spacing: Spacing.sm) {
            if viewModel.currentPage == pages.count - 1 {
                PrimaryButton(title: L10n.onboardingGetStarted) {
                    Haptic.success()
                    viewModel.completeOnboarding(coordinator: coordinator)
                }
            } else {
                PrimaryButton(title: L10n.onboardingContinue) {
                    Haptic.light()
                    withAnimation(Motion.spring) { viewModel.nextPage() }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.xl)
    }
}

// MARK: - Responsive layout for onboarding pages

private struct OnboardingLayoutMetrics {
    let size: CGSize

    var isCompactHeight: Bool { size.height < 700 }
    var isNarrow: Bool { size.width < 360 }

    var outerGlow: CGFloat {
        min(280, size.width * (isCompactHeight ? 0.54 : 0.62))
    }

    var iconBox: CGFloat { outerGlow * 0.62 }
    var symbolSize: CGFloat { iconBox * 0.48 }
    var verticalSpacing: CGFloat { isCompactHeight ? Spacing.sm : Spacing.lg }

    var titleSize: CGFloat {
        let scaled = size.width * (isNarrow ? 0.078 : 0.085)
        return min(Typography.title1, max(24, scaled))
    }

    var bodySize: CGFloat {
        min(Typography.body, max(14, size.width * 0.04))
    }

    var eyebrowSize: CGFloat {
        min(Typography.micro, max(10, size.width * 0.028))
    }
}

// MARK: - Calm halo (flat concentric circles behind the onboarding icon)

private struct OnboardingHalo: View {
    let gradient: [Color]
    let diameter: CGFloat

    private var halo: Color { gradient.first ?? Theme.forestSoft }

    var body: some View {
        ZStack {
            Circle()
                .fill(halo.opacity(0.45))
                .frame(width: diameter * 1.3, height: diameter * 1.3)
            Circle()
                .fill(halo)
                .frame(width: diameter, height: diameter)
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        GeometryReader { geo in
            let metrics = OnboardingLayoutMetrics(size: geo.size)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: metrics.verticalSpacing) {
                    heroIcon(metrics: metrics)

                    VStack(spacing: Spacing.sm) {
                        Text(page.eyebrow.uppercased())
                            .font(Theme.Fonts.label(metrics.eyebrowSize, weight: .bold))
                            .foregroundStyle(Theme.textSecondary)
                            .tracking(1.4)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.center)

                        Text(page.title)
                            .font(Theme.Fonts.display(metrics.titleSize))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .minimumScaleFactor(0.65)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)

                        Text(page.description)
                            .font(Theme.Fonts.body(metrics.bodySize))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .lineLimit(6)
                            .minimumScaleFactor(0.85)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xs)
                .frame(minHeight: geo.size.height, alignment: .center)
            }
        }
    }

    @ViewBuilder
    private func heroIcon(metrics: OnboardingLayoutMetrics) -> some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let driftY = sin(t * 0.9) * 5

            ZStack {
                OnboardingHalo(gradient: page.gradient, diameter: metrics.outerGlow * 1.05)

                GlassSurface(
                    cornerRadius: Radius.xl,
                    padding: metrics.iconBox * 0.2,
                    elevation: .raised
                ) {
                    Image(systemName: page.imageName)
                        .font(.system(size: metrics.symbolSize, weight: .medium))
                        .foregroundStyle(page.gradient.last ?? Theme.forest)
                        .frame(width: metrics.iconBox, height: metrics.iconBox)
                }
                .offset(y: driftY)
            }
        }
        .frame(height: metrics.outerGlow * 1.55)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppCoordinator())
}
