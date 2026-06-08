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
            OnboardingPage(
                eyebrow: L10n.onboardingWelcomeEyebrow,
                title: L10n.onboardingWelcomeTitle,
                description: L10n.onboardingWelcomeDesc,
                imageName: "pawprint.fill",
                gradient: [Theme.powderBlush, Theme.navy]
            ),
            OnboardingPage(
                eyebrow: L10n.onboardingDiscoverEyebrow,
                title: L10n.onboardingDiscoverTitle,
                description: L10n.onboardingDiscoverDesc,
                imageName: "heart.fill",
                gradient: [Theme.honeydew, Theme.powderBlush]
            ),
            OnboardingPage(
                eyebrow: L10n.onboardingCareEyebrow,
                title: L10n.onboardingCareTitle,
                description: L10n.onboardingCareDesc,
                imageName: "cross.case.fill",
                gradient: [Theme.almondCream, Theme.richCerulean]
            ),
            OnboardingPage(
                eyebrow: L10n.onboardingNearbyEyebrow,
                title: L10n.onboardingNearbyTitle,
                description: L10n.onboardingNearbyDesc,
                imageName: "mappin.and.ellipse",
                gradient: [Theme.powderBlush, Theme.richCerulean]
            ),
            OnboardingPage(
                eyebrow: L10n.onboardingWellnessEyebrow,
                title: L10n.onboardingWellnessTitle,
                description: L10n.onboardingWellnessDesc,
                imageName: "chart.line.uptrend.xyaxis",
                gradient: [Theme.navy, Theme.powderBlush]
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

// MARK: - Dewdrop glow (fluid wobble behind onboarding icon)

private struct OnboardingDewdropGlow: View {
    let gradient: [Color]
    let diameter: CGFloat

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let wobbleX = sin(t * 1.15)
            let wobbleY = cos(t * 0.92)
            let wobbleZ = sin(t * 1.38 + .pi / 3)
            let breathe = 0.5 + 0.5 * sin(t * 0.78)

            ZStack {
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.55 + 0.2 * breathe) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: diameter * (1.02 + 0.14 * wobbleX),
                        height: diameter * (1.08 + 0.18 * wobbleY)
                    )
                    .rotationEffect(.degrees(14 * wobbleZ))
                    .blur(radius: diameter * 0.14)
                    .offset(x: diameter * 0.06 * wobbleY, y: diameter * 0.08 * wobbleX)

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                (gradient.first ?? Theme.powderBlush).opacity(0.75),
                                (gradient.last ?? Theme.navy).opacity(0.35),
                                Color.clear
                            ],
                            center: UnitPoint(
                                x: 0.38 + 0.12 * wobbleX,
                                y: 0.32 + 0.1 * wobbleY
                            ),
                            startRadius: 0,
                            endRadius: diameter * 0.62
                        )
                    )
                    .frame(
                        width: diameter * (0.88 + 0.1 * wobbleY),
                        height: diameter * (1.04 + 0.12 * wobbleX)
                    )
                    .rotationEffect(.degrees(-10 * wobbleX + 6 * wobbleZ))
                    .blur(radius: 3)
                    .offset(x: diameter * 0.04 * wobbleZ, y: diameter * 0.05 * wobbleY)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35 + 0.15 * breathe),
                                (gradient.first ?? Theme.honeydew).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: diameter * 0.28, height: diameter * 0.22)
                    .blur(radius: 6)
                    .offset(
                        x: -diameter * 0.14 + diameter * 0.05 * wobbleX,
                        y: -diameter * 0.16 + diameter * 0.04 * wobbleY
                    )
                    .opacity(0.7 + 0.25 * breathe)
            }
            .frame(width: diameter * 1.45, height: diameter * 1.45)
            .shadow(
                color: Theme.primary.opacity(0.28 + 0.12 * breathe),
                radius: 28 + 8 * breathe,
                y: 14
            )
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
            let driftY = sin(t * 1.05) * 6
            let driftX = cos(t * 0.88) * 4
            let cardTilt = sin(t * 0.95) * 2.5

            ZStack {
                OnboardingDewdropGlow(gradient: page.gradient, diameter: metrics.outerGlow * 1.15)

                GlassSurface(
                    cornerRadius: Radius.xl,
                    padding: metrics.iconBox * 0.2,
                    elevation: .floating
                ) {
                    Image(systemName: page.imageName)
                        .font(.system(size: metrics.symbolSize, weight: .medium))
                        .foregroundStyle(Theme.primary)
                        .frame(width: metrics.iconBox, height: metrics.iconBox)
                }
                .offset(x: driftX, y: driftY)
                .rotationEffect(.degrees(cardTilt))
            }
        }
        .frame(height: metrics.outerGlow * 1.55)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppCoordinator())
}
