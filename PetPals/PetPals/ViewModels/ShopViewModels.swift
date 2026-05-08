import Foundation
import Combine
import SwiftUI

@MainActor
final class ShopViewModel: ObservableObject {
    @Published var products: [PetProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let shopService: ShopServiceProtocol
    
    init(shopService: ShopServiceProtocol = DependencyContainer.shared.shopService) {
        self.shopService = shopService
    }
    
    func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                self.products = try await shopService.fetchProducts()
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

@MainActor
final class CartViewModel: ObservableObject {
    @Published var cartItems: [PetProduct: Int] = [:]
    @Published var isCheckingOut = false
    @Published var checkoutError: String?
    @Published var checkoutSuccess = false
    
    private let shopService: ShopServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        shopService: ShopServiceProtocol = DependencyContainer.shared.shopService,
        authService: AuthServiceProtocol = DependencyContainer.shared.authService
    ) {
        self.shopService = shopService
        self.authService = authService
    }
    
    var totalAmount: Decimal {
        cartItems.reduce(Decimal(0)) { $0 + ($1.key.price * Decimal($1.value)) }
    }
    
    var totalItems: Int {
        cartItems.values.reduce(0, +)
    }
    
    func addToCart(_ product: PetProduct) {
        cartItems[product, default: 0] += 1
    }
    
    func removeFromCart(_ product: PetProduct) {
        guard let current = cartItems[product] else { return }
        if current > 1 {
            cartItems[product] = current - 1
        } else {
            cartItems.removeValue(forKey: product)
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    func checkout() {
        guard !cartItems.isEmpty else { return }
        
        isCheckingOut = true
        checkoutError = nil
        
        Task {
            do {
                guard let profile = try await authService.getCurrentUser() else {
                    throw NSError(domain: "Cart", code: 401, userInfo: [NSLocalizedDescriptionKey: L10n.userNotAuthenticated])
                }
                
                let shopIds = Set(cartItems.keys.compactMap(\.shopId))
                guard shopIds.count == 1, let shopId = shopIds.first else {
                    if shopIds.isEmpty {
                        throw NSError(domain: "Cart", code: 400, userInfo: [NSLocalizedDescriptionKey: L10n.cartMissingShopError])
                    }
                    throw NSError(domain: "Cart", code: 400, userInfo: [NSLocalizedDescriptionKey: L10n.cartMixedShopsError])
                }
                
                let orderItems = cartItems.map { (product, quantity) in
                    ShopOrderItem(
                        orderItemId: UUID(),
                        orderId: nil,
                        productId: product.productId,
                        quantity: quantity,
                        subTotal: product.price * Decimal(quantity)
                    )
                }
                
                _ = try await shopService.createOrder(
                    userId: profile.userId,
                    shopId: shopId,
                    totalAmount: totalAmount,
                    shippingAddress: nil,
                    paymentMethod: "Online",
                    items: orderItems
                )
                
                self.checkoutSuccess = true
                self.clearCart()
                self.isCheckingOut = false
            } catch {
                self.checkoutError = error.localizedDescription
                self.isCheckingOut = false
            }
        }
    }
}
