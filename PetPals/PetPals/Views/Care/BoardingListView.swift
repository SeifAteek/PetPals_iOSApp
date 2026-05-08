import SwiftUI

struct BoardingListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = CareViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - List
                if viewModel.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }.padding(.top, 50)
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.boardingServices) { service in
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.primary.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                    Image(systemName: "house.fill")
                                        .foregroundColor(Theme.primary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(service.name)
                                        .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                                    Text(L10n.startingFromPerDay)
                                        .font(Theme.Fonts.primaryFont(size: 14))
                                        .foregroundColor(Theme.primary)
                                    Text(service.location ?? "Nearby")
                                        .font(Theme.Fonts.primaryFont(size: 12))
                                        .foregroundColor(Theme.textSecondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    coordinator.push(.boardingDetail(clinicId: service.id))
                                }) {
                                    Text("Book")
                                        .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Theme.primary)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Pet Boarding")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadData() }
    }
}

#Preview {
    NavigationView {
        BoardingListView()
            .environmentObject(AppCoordinator())
    }
}
