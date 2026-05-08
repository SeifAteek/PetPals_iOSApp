import Foundation

class GeminiService {
    static let shared = GeminiService()
    private let apiKey: String
    
    private init() {
        // Read from Info.plist or fallback to Constants
        let plistKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String
        self.apiKey = (plistKey?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? ""
    }
    
    func generateResponse(prompt: String, useGrounding: Bool = false) async throws -> String {
        guard !apiKey.isEmpty else {
            return "API Key not found. Add GEMINI_API_KEY to Info.plist (do not commit production keys to public repos)."
        }
        
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 1024
            ]
        ]
        
        var finalBody = body
        if useGrounding {
            finalBody["tools"] = [
                ["google_search_retrieval": [:]]
            ]
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: finalBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "GeminiService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Gemini API Error (\(httpResponse.statusCode)): \(errorBody)"])
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let candidates = json["candidates"] as? [[String: Any]],
           let firstCandidate = candidates.first,
           let content = firstCandidate["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let firstPart = parts.first,
           let text = firstPart["text"] as? String {
            return text
        }
        
        throw NSError(domain: "GeminiService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse Gemini response"])
    }
}
