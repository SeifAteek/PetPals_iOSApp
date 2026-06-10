import SwiftUI
import Combine

struct OrderHistoryView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = OrderHistoryViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView(L10n.loadingOrders).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.orders.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "shippingbox")
                        .font(.system(size: 70))
                        .foregroundColor(Theme.textSecondary.opacity(0.4))
                    Text(L10n.noOrdersYet)
                        .font(Theme.Fonts.primaryFont(size: 20, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text(L10n.pastOrdersAppearHere)
                        .font(Theme.Fonts.primaryFont(size: 15))
                        .foregroundColor(Theme.textSecondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.orders) { order in
                        NavigationLink {
                            OrderDetailView(order: order)
                        } label: {
                            OrderRowCard(order: order)
                        }
                        .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .clawsyScreenBackground()
            }
        }
        .clawsyScreenBackground()
        .navigationTitle(L10n.myOrders)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.fetchOrders() }
    }
}

// MARK: - Order Row Card
struct OrderRowCard: View {
    let order: ShopOrder

    var statusColor: Color {
        switch order.status {
        case .processing: return .orange
        case .shipped: return .blue
        case .delivered: return .green
        case .cancelled: return .red
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.orderId.uuidString.prefix(8).uppercased())")
                        .font(Theme.Fonts.primaryFont(size: 15, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    if let date = order.orderDate {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    // Status badge
                    Text(order.status?.rawValue ?? "Unknown")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(statusColor.opacity(0.15))
                        .foregroundColor(statusColor)
                        .cornerRadius(10)
                    // Live tracking indicator
                    if order.status == .processing || order.status == .shipped {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                                .modifier(PulsingDot())
                            Text("Live Tracking")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                }
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label(order.paymentMethod ?? "Credit Card", systemImage: "creditcard.fill")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    if let address = order.shippingAddress {
                        Label(address, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                if let total = order.totalAmount {
                    Text(CurrencyFormatting.egp(total))
                        .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                        .foregroundColor(Theme.accent)
                }
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - ViewModel
@MainActor
final class OrderHistoryViewModel: ObservableObject {
    @Published var orders: [ShopOrder] = []
    @Published var isLoading = false

    func fetchOrders() {
        isLoading = true
        Task {
            do {
                let authService = DependencyContainer.shared.authService
                guard let user = try await authService.getCurrentUser() else {
                    self.isLoading = false
                    return
                }
                self.orders = try await DependencyContainer.shared.shopService.fetchUserOrders(userId: user.userId)
            } catch {
                print("[OrderHistory] Failed: \(error)")
            }
            self.isLoading = false
        }
    }
}

struct PulsingDot: ViewModifier {
    @State private var isPulsing = false
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.5 : 1.0)
            .opacity(isPulsing ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}
