import SwiftUI

struct PetCategoryTag: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color

    init(text: String, backgroundColor: Color = Theme.primary.opacity(0.14), textColor: Color = Theme.brandDeep) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }

    var body: some View {
        Text(text)
            .font(Theme.Fonts.label(Typography.caption, weight: .semibold))
            .foregroundStyle(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule(style: .continuous).fill(backgroundColor))
    }
}
