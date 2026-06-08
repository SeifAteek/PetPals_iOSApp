import SwiftUI

struct PetPalsLogoView: View {
    var height: CGFloat = 44

    var body: some View {
        Image("PetPalsLogo")
            .resizable()
            .scaledToFit()
            .frame(height: height)
            .accessibilityLabel("PetPals")
    }
}
