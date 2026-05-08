import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var iconName: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        HStack {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
            }
            
            if isSecure && !isPasswordVisible {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .foregroundColor(Theme.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(isSecure ? .none : .sentences)
                    .foregroundColor(Theme.textPrimary)
            }
            
            if isSecure {
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack {
        CustomTextField(placeholder: "Email address", text: .constant(""), iconName: "envelope.fill")
        CustomTextField(placeholder: "Password", text: .constant(""), iconName: "lock.fill", isSecure: true)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
