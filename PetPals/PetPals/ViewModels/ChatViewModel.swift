import Foundation
import Combine
import SwiftUI

extension Notification.Name {
    static let petPalsChatDidClose = Notification.Name("petPalsChatDidClose")
}

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var chatThreads: [ChatThreadSummary] = []
    @Published var inputText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let chatService: ChatServiceProtocol
    private let authService: AuthServiceProtocol
    private var currentClientId: UUID?
    private var currentClinicId: UUID?
    private var currentShelterId: UUID?
    
    private var realtimeBag = Set<AnyCancellable>()
    private var pollCancellable: AnyCancellable?
    
    init(
        chatService: ChatServiceProtocol = DependencyContainer.shared.chatService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.chatService = chatService
        self.authService = authService
    }
    
    func loadThreads() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let profile = try await authService.getCurrentUser() else {
                    throw NSError(domain: "Chat", code: 401, userInfo: [NSLocalizedDescriptionKey: "Must be logged in to see messages."])
                }
                self.chatThreads = try await chatService.fetchChatThreads(clientId: profile.userId)
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func loadMessages(clinicId: UUID?, shelterId: UUID?) {
        stopLiveUpdates()
        isLoading = true
        errorMessage = nil
        self.currentClinicId = clinicId
        self.currentShelterId = shelterId
        
        Task {
            do {
                guard let profile = try await authService.getCurrentUser() else {
                    throw NSError(domain: "Chat", code: 401, userInfo: [NSLocalizedDescriptionKey: "Must be logged in to chat."])
                }
                
                self.currentClientId = profile.userId
                self.messages = try await chatService.fetchMessages(clientId: profile.userId, clinicId: clinicId, shelterId: shelterId)
                
                self.isLoading = false
                
                chatService.subscribeToMessages(clientId: profile.userId, clinicId: clinicId, shelterId: shelterId)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] newMessage in
                        guard let self else { return }
                        if let expected = clinicId, newMessage.clinicId != expected { return }
                        if let expected = shelterId, newMessage.shelterId != expected { return }
                        if !self.messages.contains(where: { $0.messageId == newMessage.messageId }) {
                            self.messages.append(newMessage)
                        }
                    }
                    .store(in: &self.realtimeBag)
                
                self.pollCancellable = Timer.publish(every: 3, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] _ in
                        Task { await self?.reloadMessagesQuietly() }
                    }
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Stops realtime + polling (call when leaving the chat screen).
    func stopLiveUpdates() {
        realtimeBag.removeAll()
        pollCancellable?.cancel()
        pollCancellable = nil
        chatService.unsubscribeFromMessages()
        NotificationCenter.default.post(name: .petPalsChatDidClose, object: nil)
    }
    
    private func reloadMessagesQuietly() async {
        guard let clientId = currentClientId else { return }
        do {
            let fresh = try await chatService.fetchMessages(clientId: clientId, clinicId: currentClinicId, shelterId: currentShelterId)
            self.messages = fresh
        } catch {
            // Keep existing messages on transient failures
        }
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let clientId = currentClientId else { return }
        
        let textToSend = inputText
        inputText = ""
        
        Task {
            do {
                try await chatService.sendMessage(clientId: clientId, clinicId: currentClinicId, shelterId: currentShelterId, text: textToSend, sender: .client)
                await reloadMessagesQuietly()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
