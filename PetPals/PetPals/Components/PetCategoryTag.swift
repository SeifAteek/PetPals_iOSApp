import SwiftUI

struct PetCategoryTag: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    
    init(text: String, backgroundColor: Color = Theme.secondary, textColor: Color = .black) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
    
    var body: some View {
        Text(text)
            .font(Theme.Fonts.primaryFont(size: 12, weight: .semibold))
            .foregroundColor(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .cornerRadius(12)
    }
}

#Preview {
    HStack {
        PetCategoryTag(text: "Dog", backgroundColor: Color.blue.opacity(0.2))
        PetCategoryTag(text: "Female", backgroundColor: Color.pink.opacity(0.2))
        PetCategoryTag(text: "2 years old", backgroundColor: Color.green.opacity(0.2))
    }
    .padding()
}
