import SwiftUI

struct PrimaryButton: View {
    let title: String
    var style: PrimaryButtonStyle = .filled
    var icon: String? = nil
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    /// Design-system button variants.
    /// `.filled` = primary (forest) · `.glass` = secondary (white + forest border)
    /// `.subtle` = ghost · `.accent` = coral · `.danger` = critical red
    enum PrimaryButtonStyle {
        case filled, glass, subtle, accent, danger
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
                    HStack(spacing: Spacing.xs) {
                        if let icon {
                            Image(systemName: icon)
                                .font(.system(size: 17, weight: .semibold))
                        }
                        Text(title)
                            .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                    }
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background {
                Capsule(style: .continuous).fill(backgroundFill)
            }
            .overlay {
                if style == .glass {
                    Capsule(style: .continuous)
                        .stroke(Theme.borderStrong, lineWidth: 1.5)
                }
            }
            .shadow(
                color: isEnabled && style == .filled ? Theme.shadowInk.opacity(0.14) : .clear,
                radius: 10,
                y: 5
            )
        }
        .buttonStyle(MagneticPressStyle())
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.45)
    }

    private var foregroundColor: Color {
        switch style {
        case .filled: return Theme.textOnBrand
        case .glass: return Theme.primary
        case .subtle: return Theme.textBody
        case .accent: return Theme.onAccent
        case .danger: return .white
        }
    }

    private var backgroundFill: Color {
        guard isEnabled else {
            return Theme.surfaceWarm
        }
        switch style {
        case .filled: return Theme.forest
        case .glass: return Theme.surface
        case .subtle: return Theme.surfaceWarm
        case .accent: return Theme.coral
        case .danger: return Theme.statusCritical
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
        PrimaryButton(title: "Book a visit") {}
        PrimaryButton(title: "Meet Luna", style: .glass) {}
        PrimaryButton(title: "Keep chatting", style: .subtle) {}
        PrimaryButton(title: "Adopt me", style: .accent, icon: "heart.fill") {}
        PrimaryButton(title: "Talk to a vet now", style: .danger, icon: "phone.fill") {}
        PrimaryButton(title: "Loading", isLoading: true) {}
    }
    .padding()
    .petPalsScreenBackground()
}
