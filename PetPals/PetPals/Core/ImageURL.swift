import Foundation

/// Normalizes storage/public URLs so cached remote images can load (encoding, https, spaces).
enum ImageURL {
    static func from(_ string: String?) -> URL? {
        guard var s = string?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }
        if s.hasPrefix("//") { s = "https:" + s }
        if let u = URL(string: s) { return u }
        var allowed = CharacterSet.urlPathAllowed
        allowed.insert(charactersIn: "?&=%#")
        if let encoded = s.addingPercentEncoding(withAllowedCharacters: allowed) {
            return URL(string: encoded)
        }
        return URL(string: s.replacingOccurrences(of: " ", with: "%20"))
    }
}
