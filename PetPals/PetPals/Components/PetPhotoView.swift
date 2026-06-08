import SwiftUI

// MARK: - Standardized pet image sizes (crop to fit, never scale to intrinsic photo size)

enum PetPhotoStyle {
    case gridCard
    case featured
    case detailHero
    case profileHero
    case listThumb
    case smallCircle
}

/// Crops pet photos into a fixed frame using `scaledToFill`.
struct StandardPetPhoto: View {
    var url: URL?
    var style: PetPhotoStyle
    var showsPlaceholderIcon: Bool = true

    var body: some View {
        Group {
            switch style {
            case .gridCard:
                cropContainer(aspectRatio: PetImageMetrics.gridAspect)
            case .featured:
                cropContainer(size: PetImageMetrics.featuredSize)
            case .detailHero:
                cropContainer(size: CGSize(width: 10_000, height: PetImageMetrics.detailHeroHeight), maxWidth: true)
            case .profileHero:
                cropContainer(size: CGSize(width: 10_000, height: PetImageMetrics.profileHeroHeight), maxWidth: true)
            case .listThumb:
                cropContainer(size: PetImageMetrics.listThumbSize)
            case .smallCircle:
                cropContainer(size: CGSize(width: PetImageMetrics.smallAvatarSize, height: PetImageMetrics.smallAvatarSize))
                    .clipShape(Circle())
            }
        }
        .clipShape(clipShapeForStyle)
    }

    // MARK: - Crop container

    @ViewBuilder
    private func cropContainer(aspectRatio: CGFloat) -> some View {
        Color.clear
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay { fillContent }
            .clipped()
    }

    @ViewBuilder
    private func cropContainer(size: CGSize, maxWidth: Bool = false) -> some View {
        Color.clear
            .frame(
                width: maxWidth ? nil : size.width,
                height: size.height
            )
            .frame(maxWidth: maxWidth ? .infinity : nil)
            .overlay { fillContent }
            .clipped()
    }

    @ViewBuilder
    private var fillContent: some View {
        ZStack {
            Theme.honeydew.opacity(0.35)
            if let url {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(
                                minWidth: 0, maxWidth: .infinity,
                                minHeight: 0, maxHeight: .infinity
                            )
                    case .empty:
                        ProgressView().tint(Theme.primary)
                    case .failure:
                        placeholderContent
                    }
                }
            } else {
                placeholderContent
            }
        }
    }

    @ViewBuilder
    private var placeholderContent: some View {
        if showsPlaceholderIcon {
            Image(systemName: "pawprint.fill")
                .font(.system(size: placeholderIconSize, weight: .medium))
                .foregroundStyle(Theme.primary.opacity(0.45))
        }
    }

    private var placeholderIconSize: CGFloat {
        switch style {
        case .gridCard: return 36
        case .featured: return 44
        case .detailHero, .profileHero: return 56
        case .listThumb: return 22
        case .smallCircle: return 18
        }
    }

    private var clipShapeForStyle: AnyShape {
        switch style {
        case .smallCircle:
            return AnyShape(Circle())
        case .detailHero, .profileHero:
            return AnyShape(Rectangle())
        case .gridCard, .featured:
            return AnyShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        case .listThumb:
            return AnyShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
        }
    }
}

extension StandardPetPhoto {
    init(pet: Pet, style: PetPhotoStyle) {
        self.url = pet.avatarUrl.flatMap { ImageURL.from($0) ?? URL(string: $0) }
        self.style = style
    }

    init(avatarUrl: String?, style: PetPhotoStyle) {
        self.url = avatarUrl.flatMap { ImageURL.from($0) ?? URL(string: $0) }
        self.style = style
    }
}

private struct AnyShape: Shape {
    private let pathBuilder: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        pathBuilder = { rect in shape.path(in: rect) }
    }

    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}
