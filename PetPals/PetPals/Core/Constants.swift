import Foundation

/// Reads Supabase URL and anon key from Info.plist first, then process environment (CI), so keys are not hard-coded in Swift.
private enum SupabaseSecrets {
    static func string(forPlistKey key: String, envKey: String) -> String {
        if let v = Bundle.main.object(forInfoDictionaryKey: key) as? String {
            let t = v.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty { return t }
        }
        if let e = ProcessInfo.processInfo.environment[envKey] {
            let t = e.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty { return t }
        }
        return ""
    }
}

struct Constants {
    struct API {
        static var supabaseURL: String {
            SupabaseSecrets.string(forPlistKey: "SUPABASE_URL", envKey: "SUPABASE_URL")
        }
        static var supabasePublicKey: String {
            SupabaseSecrets.string(forPlistKey: "SUPABASE_ANON_KEY", envKey: "SUPABASE_ANON_KEY")
        }
        /// Service role keys must never ship in a client app. Kept empty intentionally.
        static let supabasePrivateKey: String = ""
    }
}
