import SwiftUI

// MARK: - Ambient Screen Background (photo-style mesh)

struct PetPalsAmbientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                // Dark mode: Navy → Powder Blush gradient only
                Theme.darkBackgroundGradient
            } else {
                Theme.background

                Theme.meshGradient
                    .opacity(0.72)
                    .blur(radius: 32)
                    .scaleEffect(1.35)

                LinearGradient(
                    colors: [
                        Theme.powderBlush.opacity(0.35),
                        Theme.honeydew.opacity(0.25),
                        Theme.navy.opacity(0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                ForEach(PetPalsPalette.meshOrbs(colorScheme: colorScheme)) { orb in
                    Circle()
                        .fill(orb.color.opacity(orb.opacity(for: colorScheme)))
                        .frame(width: orb.size, height: orb.size)
                        .blur(radius: orb.blur)
                        .offset(orb.offset)
                }

                LinearGradient(
                    colors: [Color.clear, Theme.navy.opacity(0.06)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Glass Surface

struct GlassSurface<Content: View>: View {
    var cornerRadius: CGFloat = Radius.lg
    var padding: CGFloat = Spacing.sm
    var elevation: Elevation = .raised
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Theme.cardBackground)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Theme.heroGradient.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Theme.glassStroke, lineWidth: 1)
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

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = Radius.lg
    var elevation: Elevation = .raised

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Theme.cardBackground)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Theme.brandGradient.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Theme.glassStroke, lineWidth: 1)
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
    func glassCard(cornerRadius: CGFloat = Radius.lg, elevation: Elevation = .raised) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, elevation: elevation))
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

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Theme.powderBlush.opacity(0.4),
                            Theme.honeydew.opacity(0.35),
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
        .glassCard()
    }
}

// MARK: - Magnetic Press

struct MagneticPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(Motion.spring, value: configuration.isPressed)
    }
}
