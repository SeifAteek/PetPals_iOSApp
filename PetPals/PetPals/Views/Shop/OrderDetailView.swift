import SwiftUI

struct OrderDetailView: View {
    let order: ShopOrder

    @State private var receipt: ReceiptRecord?
    @State private var shop: Shop?
    @State private var profile: Profile?
    @State private var isLoadingReceipt = false
    @State private var loadError: String?
    @State private var showReceipt = false

    private let shopService: ShopServiceProtocol
    private let authService: AuthServiceProtocol

    init(
        order: ShopOrder,
        shopService: ShopServiceProtocol = DependencyContainer.shared.shopService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.order = order
        self.shopService = shopService
        self.authService = authService
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard

                if let loadError {
                    Text(loadError)
                        .font(Theme.Fonts.primaryFont(size: 14))
                        .foregroundStyle(.red)
                }

                if receipt != nil {
                    PrimaryButton(title: L10n.viewReceipt, isLoading: false) {
                        showReceipt = true
                    }
                } else if isLoadingReceipt {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(L10n.noReceiptYet)
                        .font(Theme.Fonts.primaryFont(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(20)
        }
        .clawsyScreenBackground()
        .navigationTitle(L10n.orderDetails)
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .sheet(isPresented: $showReceipt) {
            if let receipt {
                ReceiptSheetView(
                    shopName: shop?.name ?? "PetPals Shop",
                    shopLogoURL: shop?.logoUrl,
                    receipt: receipt,
                    customerName: profile?.userName ?? "—",
                    customerEmail: profile?.email
                )
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order #\(order.orderId.uuidString.prefix(8).uppercased())")
                .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
            if let d = order.orderDate {
                Text(d.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Divider()
            HStack {
                Text(L10n.total)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                if let t = order.totalAmount {
                    Text(CurrencyFormatting.egp(t))
                        .font(Theme.Fonts.primaryFont(size: 20, weight: .bold))
                        .foregroundStyle(Theme.accent)
                }
            }
            if let shop {
                Label(shop.name, systemImage: "storefront.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Label(order.paymentMethod ?? "—", systemImage: "creditcard.fill")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            if let addr = order.shippingAddress, !addr.isEmpty {
                Label(addr, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    @MainActor
    private func load() async {
        isLoadingReceipt = true
        loadError = nil
        defer { isLoadingReceipt = false }
        do {
            profile = try await authService.getCurrentUser()
            guard let uid = profile?.userId else { return }
            receipt = try await shopService.fetchReceiptForOrder(orderId: order.orderId, clientId: uid)
            let shopId = order.shopId ?? receipt?.shop_id
            if let shopId {
                shop = try await shopService.fetchShop(shopId: shopId)
            }
        } catch {
            loadError = error.localizedDescription
        }
    }
}
