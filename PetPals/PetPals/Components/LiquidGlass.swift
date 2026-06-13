import SwiftUI

// MARK: - Screen Background (flat warm canvas — "the chrome stays quiet")

struct PetPalsAmbientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            Theme.background

            // Subtle sand wash at the very top of the canvas (the one sanctioned flourish).
            if colorScheme == .light {
                RadialGradient(
                    colors: [Theme.sandSoft.opacity(0.9), Theme.sandSoft.opacity(0)],
                    center: .top,
                    startRadius: 0,
                    endRadius: 420
                )
                .frame(height: 420)
                .frame(maxWidth: .infinity)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Card Surface

struct GlassSurface<Content: View>: View {
    var cornerRadius: CGFloat = Radius.xl
    var padding: CGFloat = Spacing.sm
    var elevation: Elevation = .resting
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Theme.borderSubtle, lineWidth: 1)
                    )
                    .shadow(
                        color: elevation.shadowColor,
                        radius: elevation.radius,
                        x: 0,
                        y: elevation.y
                    )
            }
    }
}

// MARK: - Card Modifier (white surface · sand hairline · warm shadow)

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = Radius.xl
    var elevation: Elevation = .resting

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Theme.borderSubtle, lineWidth: 1)
                    )
                    .shadow(
                        color: elevation.shadowColor,
                        radius: elevation.radius,
                        x: 0,
                        y: elevation.y
                    )
            }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = Radius.xl, elevation: Elevation = .resting) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, elevation: elevation))
    }

    /// Warm sand panel — for secondary surfaces that shouldn't read as cards.
    func warmPanel(cornerRadius: CGFloat = Radius.lg) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Theme.surfaceWarm)
        }
    }

    func petPalsScreenBackground() -> some View {
        background(PetPalsAmbientBackground())
    }

    /// Legacy alias used across detail screens
    func clawsyScreenBackground() -> some View {
        petPalsScreenBackground()
    }
}

// MARK: - Shimmer Loading

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion {
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.45),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.6)
                        .offset(x: geo.size.width * phase)
                        .onAppear {
                            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                                phase = 1.4
                            }
                        }
                    }
                    .mask(content)
                }
            }
    }
}

struct PremiumLoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ProgressView()
                .tint(Theme.primary)
                .scaleEffect(1.1)
            Text(message)
                .font(Theme.Fonts.label(Typography.caption))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .glassCard(cornerRadius: Radius.lg)
    }
}

// MARK: - Magnetic Press (press = scale, never a color-only change)

struct MagneticPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(Motion.quick, value: configuration.isPressed)
    }
}
