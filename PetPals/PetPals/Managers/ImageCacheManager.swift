import UIKit

/// In-memory + disk image cache so remote photos are not re-downloaded on every screen visit.
final class ImageCacheManager {
    static let shared = ImageCacheManager()

    static let urlCache = URLCache(
        memoryCapacity: 50 * 1024 * 1024,
        diskCapacity: 200 * 1024 * 1024,
        diskPath: "PetPalsImageCache"
    )

    private let memoryCache = NSCache<NSString, UIImage>()
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.urlCache = Self.urlCache
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)
        memoryCache.countLimit = 200
        memoryCache.totalCostLimit = 50 * 1024 * 1024
    }

    static func configure() {
        URLCache.shared = urlCache
    }

    func image(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString
        if let cached = memoryCache.object(forKey: key) {
            return cached
        }

        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        if let cachedResponse = Self.urlCache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            memoryCache.setObject(image, forKey: key, cost: cachedResponse.data.count)
            return image
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let image = UIImage(data: data) else { return nil }
            memoryCache.setObject(image, forKey: key, cost: data.count)
            if let httpResponse = response as? HTTPURLResponse {
                let cached = CachedURLResponse(response: httpResponse, data: data)
                Self.urlCache.storeCachedResponse(cached, for: request)
            }
            return image
        } catch {
            return nil
        }
    }

    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
}
