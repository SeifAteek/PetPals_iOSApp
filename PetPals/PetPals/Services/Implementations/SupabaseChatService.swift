import Foundation
import Supabase
import Combine

final class SupabaseChatService: ChatServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    private var channel: RealtimeChannel?
    
    private struct ClinicPreviewForChat: Decodable {
        let clinic_id: UUID
        let name: String
        let logo_url: String?
    }
    
    private struct ShelterPreviewForChat: Decodable {
        let shelter_id: UUID
        let org_name: String
        let logo_url: String?
    }
    
    func fetchMessages(clientId: UUID, clinicId: UUID?, shelterId: UUID?) async throws -> [ChatMessage] {
        var query = client.database
            .from("messages")
            .select()
            .eq("client_id", value: clientId.uuidString.lowercased())
            
        if let clinicId = clinicId {
            query = query.eq("clinic_id", value: clinicId.uuidString.lowercased())
        }
        if let shelterId = shelterId {
            query = query.eq("shelter_id", value: shelterId.uuidString.lowercased())
        }
        
        let messages: [ChatMessage] = try await query
            .order("created_at", ascending: true)
            .execute()
            .value
            
        return messages
    }
    
    func sendMessage(clientId: UUID, clinicId: UUID?, shelterId: UUID?, text: String, sender: MessageSender) async throws {
        let message = ChatMessage(
            messageId: UUID(),
            clinicId: clinicId,
            shelterId: shelterId,
            clientId: clientId,
            sender: sender,
            text: text,
            createdAt: Date()
        )
        
        try await client.database
            .from("messages")
            .insert(message)
            .execute()
    }
    
    func subscribeToMessages(clientId: UUID, clinicId: UUID?, shelterId: UUID?) -> AnyPublisher<ChatMessage, Never> {
        let subject = PassthroughSubject<ChatMessage, Never>()
        
        Task {
            let channelName = "messages_client_\(clientId.uuidString.lowercased())"
            
            if let existing = channel {
                try? await existing.unsubscribe()
            }
            
            let filter = "client_id=eq.\(clientId.uuidString.lowercased())"
            
            let realtimeChannel = await client.realtime.channel(channelName)
            self.channel = realtimeChannel
            
            let _ = await realtimeChannel.on("postgres_changes", filter: .init(event: "INSERT", schema: "public", table: "messages", filter: filter)) { message in
                guard let record = message.payload["new"] as? [String: Any],
                      let data = try? JSONSerialization.data(withJSONObject: record) else { return }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                decoder.dateDecodingStrategy = .custom { dec in
                    let c = try dec.singleValueContainer()
                    let s = try c.decode(String.self)
                    let f = ISO8601DateFormatter()
                    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    if let d = f.date(from: s) { return d }
                    f.formatOptions = [.withInternetDateTime]
                    if let d = f.date(from: s) { return d }
                    throw DecodingError.dataCorruptedError(in: c, debugDescription: "Invalid date: \(s)")
                }
                if let decodedMessage = try? decoder.decode(ChatMessage.self, from: data) {
                    if let cid = clinicId, decodedMessage.clinicId != cid { return }
                    if let sid = shelterId, decodedMessage.shelterId != sid { return }
                    subject.send(decodedMessage)
                }
            }
            
            try? await realtimeChannel.subscribe()
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func unsubscribeFromMessages() {
        Task {
            if let ch = channel {
                try? await ch.unsubscribe()
            }
            channel = nil
        }
    }
    
    func fetchChatThreads(clientId: UUID) async throws -> [ChatThreadSummary] {
        let allMessages: [ChatMessage] = try await client.database
            .from("messages")
            .select()
            .eq("client_id", value: clientId.uuidString.lowercased())
            .order("created_at", ascending: false)
            .execute()
            .value
        
        var clinicLatest: [UUID: ChatMessage] = [:]
        var shelterLatest: [UUID: ChatMessage] = [:]
        
        for msg in allMessages {
            if let cid = msg.clinicId {
                if clinicLatest[cid] == nil { clinicLatest[cid] = msg }
            } else if let sid = msg.shelterId {
                if shelterLatest[sid] == nil { shelterLatest[sid] = msg }
            }
        }
        
        let clinicIds = Array(clinicLatest.keys)
        let shelterIds = Array(shelterLatest.keys)
        
        var clinicMeta: [UUID: (String, String?)] = [:]
        if !clinicIds.isEmpty {
            let idStrings = clinicIds.map { $0.uuidString.lowercased() }
            let rows: [ClinicPreviewForChat] = try await client.database
                .from("clinics")
                .select("clinic_id,name,logo_url")
                .in("clinic_id", values: idStrings)
                .execute()
                .value
            for r in rows {
                clinicMeta[r.clinic_id] = (r.name, r.logo_url)
            }
        }
        
        var shelterMeta: [UUID: (String, String?)] = [:]
        if !shelterIds.isEmpty {
            let idStrings = shelterIds.map { $0.uuidString.lowercased() }
            let rows: [ShelterPreviewForChat] = try await client.database
                .from("shelter_profiles")
                .select("shelter_id,org_name,logo_url")
                .in("shelter_id", values: idStrings)
                .execute()
                .value
            for r in rows {
                shelterMeta[r.shelter_id] = (r.org_name, r.logo_url)
            }
        }
        
        var summaries: [ChatThreadSummary] = []
        
        for (clinicId, msg) in clinicLatest {
            let meta = clinicMeta[clinicId]
            summaries.append(ChatThreadSummary(
                id: clinicId,
                clinicId: clinicId,
                shelterId: nil,
                partnerName: meta?.0 ?? "Clinic",
                partnerLogoURL: meta?.1,
                previewText: msg.text,
                createdAt: msg.createdAt
            ))
        }
        
        for (shelterId, msg) in shelterLatest {
            let meta = shelterMeta[shelterId]
            summaries.append(ChatThreadSummary(
                id: shelterId,
                clinicId: nil,
                shelterId: shelterId,
                partnerName: meta?.0 ?? "Shelter",
                partnerLogoURL: meta?.1,
                previewText: msg.text,
                createdAt: msg.createdAt
            ))
        }
        
        return summaries.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
    }
}
