import SwiftUI

/// Post attachment image with standardized crop.
struct CommunityPostImageView: View {
    let imageUrl: String?
    var cornerRadius: CGFloat = Radius.md
    var maxHeight: CGFloat = 220

    var body: some View {
        Group {
            if let urlString = imageUrl, let url = ImageURL.from(urlString) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Theme.primary.opacity(0.08))
                        .overlay {
                            ProgressView()
                        }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: maxHeight)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
