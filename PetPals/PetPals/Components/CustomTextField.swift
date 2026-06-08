import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var iconName: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    @State private var isPasswordVisible = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.xs) {
            if let iconName {
                Image(systemName: iconName)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 20)
            }

            Group {
                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .keyboardType(keyboardType)
            .textInputAutocapitalization(isSecure ? .never : .sentences)
            .autocorrectionDisabled(isSecure)
            .font(Theme.Fonts.body(Typography.callout))
            .foregroundStyle(Theme.textPrimary)
            .focused($isFocused)

            if isSecure {
                Button { isPasswordVisible.toggle() } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 14)
        .glassCard(cornerRadius: Radius.md, elevation: .resting)
        .overlay {
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .stroke(isFocused ? Theme.primary.opacity(0.5) : Color.clear, lineWidth: 1.5)
        }
        .animation(Motion.quick, value: isFocused)
    }
}

#Preview {
    VStack(spacing: 12) {
        CustomTextField(placeholder: "Email address", text: .constant(""), iconName: "envelope.fill")
        CustomTextField(placeholder: "Password", text: .constant(""), iconName: "lock.fill", isSecure: true)
    }
    .padding()
    .petPalsScreenBackground()
}
