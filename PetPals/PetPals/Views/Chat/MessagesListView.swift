import SwiftUI

struct MessagesListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView().padding(.top, 50)
                } else if viewModel.chatThreads.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "message.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No messages yet")
                            .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 100)
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.chatThreads) { thread in
                            Button(action: {
                                coordinator.push(.chatRoom(clinicId: thread.clinicId, shelterId: thread.shelterId, displayName: thread.partnerName))
                            }) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        if let url = ImageURL.from(thread.partnerLogoURL) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .success(let img):
                                                    img.resizable().scaledToFill()
                                                default:
                                                    Image(systemName: "building.2.fill")
                                                        .foregroundColor(Theme.primary)
                                                }
                                            }
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                        } else {
                                            ZStack {
                                                Circle()
                                                    .fill(Theme.primary.opacity(0.15))
                                                Image(systemName: thread.clinicId != nil ? "cross.case.fill" : "house.fill")
                                                    .foregroundColor(Theme.primary)
                                            }
                                            .frame(width: 50, height: 50)
                                        }
                                    }
                                    .frame(width: 50, height: 50)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(thread.partnerName)
                                            .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                                            .foregroundColor(Theme.textPrimary)
                                        Text(thread.previewText)
                                            .font(Theme.Fonts.primaryFont(size: 14))
                                            .foregroundColor(Theme.textSecondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    if let date = thread.createdAt {
                                        Text(date, style: .time)
                                            .font(Theme.Fonts.primaryFont(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Theme.cardBackground)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Messages")
            .onAppear {
                viewModel.loadThreads()
            }
            .onReceive(NotificationCenter.default.publisher(for: .petPalsChatDidClose)) { _ in
                viewModel.loadThreads()
            }
        }
    }
}

#Preview {
    MessagesListView()
        .environmentObject(AppCoordinator())
}
