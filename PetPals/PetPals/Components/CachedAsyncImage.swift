import SwiftUI
import Combine

enum CachedImagePhase {
    case empty
    case success(Image)
    case failure

    var image: Image? {
        if case .success(let img) = self { return img }
        return nil
    }
}

/// Drop-in replacement for `AsyncImage` that uses `ImageCacheManager` (memory + disk).
struct CachedAsyncImage<Content: View>: View {
    let url: URL?
    @ViewBuilder let content: (CachedImagePhase) -> Content

    @StateObject private var loader = CachedImageLoader()

    var body: some View {
        Group {
            if let uiImage = loader.image {
                content(.success(Image(uiImage: uiImage)))
            } else if loader.failed {
                content(.failure)
            } else {
                content(.empty)
            }
        }
        .onAppear { loader.load(url: url) }
        .onChange(of: url?.absoluteString) { _ in loader.load(url: url) }
    }
}

extension CachedAsyncImage where Content == AnyView {
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> some View, @ViewBuilder placeholder: @escaping () -> some View) {
        self.url = url
        self.content = { phase in
            AnyView(
                Group {
                    switch phase {
                    case .empty:
                        placeholder()
                    case .success(let image):
                        content(image)
                    case .failure:
                        placeholder()
                    }
                }
            )
        }
    }
}

@MainActor
private final class CachedImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var failed = false

    private var loadedURL: URL?

    func load(url: URL?) {
        guard let url else {
            image = nil
            failed = true
            loadedURL = nil
            return
        }
        if loadedURL == url, image != nil { return }

        loadedURL = url
        image = nil
        failed = false

        Task {
            let result = await ImageCacheManager.shared.image(for: url)
            guard !Task.isCancelled else { return }
            if loadedURL == url {
                image = result
                failed = result == nil
            }
        }
    }
}
