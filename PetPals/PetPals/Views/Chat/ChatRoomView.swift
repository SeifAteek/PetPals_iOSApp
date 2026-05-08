import SwiftUI

struct ChatRoomView: View {
    let clinicId: UUID?
    let shelterId: UUID?
    let displayName: String
    
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                        
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.messageId)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.messageId, anchor: .bottom)
                        }
                    }
                }
            }
            
            VStack {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
                
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $viewModel.inputText)
                        .padding(12)
                        .background(Theme.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        ZStack {
                            Circle()
                                .fill(viewModel.inputText.isEmpty ? Theme.textSecondary.opacity(0.3) : Theme.primary)
                                .frame(width: 44, height: 44)
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(viewModel.inputText.isEmpty)
                }
                .padding()
            }
            .background(Theme.background)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadMessages(clinicId: clinicId, shelterId: shelterId)
        }
        .onDisappear {
            viewModel.stopLiveUpdates()
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.sender == .client {
                Spacer()
                Text(message.text)
                    .padding(12)
                    .background(Theme.primary.opacity(0.15))
                    .foregroundColor(Theme.textPrimary)
                    .cornerRadius(16)
                    .frame(maxWidth: 260, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding(12)
                    .background(Theme.cardBackground)
                    .foregroundColor(Theme.textPrimary)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .frame(maxWidth: 260, alignment: .leading)
                Spacer()
            }
        }
    }
}
