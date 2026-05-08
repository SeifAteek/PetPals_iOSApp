import Foundation
// To use this file, please install the Supabase Swift package in Xcode:
// 1. File -> Add Packages...
// 2. Paste URL: https://github.com/supabase-community/supabase-swift
// 3. Add to target 'PetPals'
import Supabase

/// A singleton manager to hold the Supabase client instance.
/// Uses the keys defined in Core/Constants.swift
final class SupabaseClientManager {
    static let shared = SupabaseClientManager()
    
    let client: SupabaseClient
    
    private init() {
        let urlString = Constants.API.supabaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            fatalError("Missing Supabase URL. Set SUPABASE_URL (and SUPABASE_ANON_KEY) in Info.plist or environment.")
        }
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Constants.API.supabasePublicKey,
            options: SupabaseClientOptions(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
