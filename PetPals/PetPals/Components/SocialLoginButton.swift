import SwiftUI

enum SocialPlatform: String {
    case apple = "Apple"
    case google = "Google"
    case facebook = "Facebook"
    
    var iconName: String {
        switch self {
        case .apple: return "applelogo"
        case .google: return "g.circle.fill" // Standard SF symbol placeholder for Google
        case .facebook: return "f.circle.fill" // Standard SF symbol placeholder for Facebook
        }
    }
}

struct SocialLoginButton: View {
    let platform: SocialPlatform
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: platform.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(platform == .apple ? .black : (platform == .google ? .red : .blue))
                
                Text("Continue with \(platform.rawValue)")
                    .font(Theme.Fonts.primaryFont(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.cardBackground)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SocialLoginButton(platform: .apple, action: {})
        SocialLoginButton(platform: .google, action: {})
        SocialLoginButton(platform: .facebook, action: {})
    }
    .padding()
}
