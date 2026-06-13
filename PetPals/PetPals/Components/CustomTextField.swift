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
        HStack(spacing: 10) {
            if let iconName {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.textFaint)
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
                        .foregroundStyle(Theme.textFaint)
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background {
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(Theme.surface)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .stroke(isFocused ? Theme.borderStrong : Theme.borderDefault, lineWidth: 1.5)
        }
        .background {
            // Soft focus glow (--shadow: 0 0 0 4px forest-50)
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .stroke(Theme.forestSoft, lineWidth: isFocused ? 8 : 0)
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
