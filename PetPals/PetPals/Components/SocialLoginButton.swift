import SwiftUI

enum SocialPlatform: String {
    case apple = "Apple"
    case google = "Google"
    case facebook = "Facebook"

    var iconName: String {
        switch self {
        case .apple: return "applelogo"
        case .google: return "g.circle.fill"
        case .facebook: return "f.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .apple: return Theme.textPrimary
        case .google: return Theme.coral
        case .facebook: return Theme.statusInfo
        }
    }
}

struct SocialLoginButton: View {
    let platform: SocialPlatform
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptic.light()
            action()
        }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: platform.iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(platform.tint)
                Text("Continue with \(platform.rawValue)")
                    .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background {
                Capsule(style: .continuous).fill(Theme.surface)
            }
            .overlay {
                Capsule(style: .continuous).stroke(Theme.borderDefault, lineWidth: 1.5)
            }
        }
        .buttonStyle(MagneticPressStyle())
    }
}
