import Foundation
import Combine

protocol ChatServiceProtocol {
    func fetchMessages(clientId: UUID, clinicId: UUID?, shelterId: UUID?) async throws -> [ChatMessage]
    func sendMessage(clientId: UUID, clinicId: UUID?, shelterId: UUID?, text: String, sender: MessageSender) async throws
    func subscribeToMessages(clientId: UUID, clinicId: UUID?, shelterId: UUID?) -> AnyPublisher<ChatMessage, Never>
    func unsubscribeFromMessages()
    func fetchChatThreads(clientId: UUID) async throws -> [ChatThreadSummary]
}
