import SwiftUI

struct PrimaryButton: View {
    let title: String
    var style: PrimaryButtonStyle = .filled
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    enum PrimaryButtonStyle {
        case filled, glass, subtle
    }

    var body: some View {
        Button {
            Haptic.light()
            action()
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                } else {
                    Text(title)
                        .font(Theme.Fonts.headline(Typography.body, weight: .bold))
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background { backgroundShape }
            .overlay {
                if style == .glass {
                    RoundedRectangle(cornerRadius: Radius.pill, style: .continuous)
                        .stroke(Theme.glassStroke, lineWidth: 1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.pill, style: .continuous))
            .shadow(
                color: isEnabled && style == .filled ? Theme.primary.opacity(0.35) : .clear,
                radius: 14,
                y: 6
            )
        }
        .buttonStyle(MagneticPressStyle())
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.5)
    }

    private var foregroundColor: Color {
        switch style {
        case .filled: return Theme.textOnBrand
        case .glass, .subtle: return Theme.primary
        }
    }

    @ViewBuilder
    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: Radius.pill, style: .continuous)
            .fill(backgroundFill)
    }

    private var backgroundFill: AnyShapeStyle {
        guard isEnabled else {
            return AnyShapeStyle(Color.gray.opacity(0.25))
        }
        switch style {
        case .filled:
            return AnyShapeStyle(Theme.brandGradient)
        case .glass:
            return AnyShapeStyle(.ultraThinMaterial)
        case .subtle:
            return AnyShapeStyle(Theme.primary.opacity(0.12))
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        PrimaryButton(title: title, style: .glass, action: action)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Get Started") {}
        PrimaryButton(title: "Glass CTA", style: .glass) {}
        PrimaryButton(title: "Loading", isLoading: true) {}
    }
    .padding()
    .petPalsScreenBackground()
}
