import Foundation

protocol ShopServiceProtocol {
    func fetchShops() async throws -> [Shop]
    func fetchProducts() async throws -> [PetProduct]
    func fetchProducts(for shopId: UUID) async throws -> [PetProduct]
    func fetchProductImages(for productId: UUID) async throws -> [ProductImage]
    func fetchShop(shopId: UUID) async throws -> Shop
    func createOrder(
        userId: UUID,
        shopId: UUID,
        totalAmount: Decimal,
        shippingAddress: String?,
        paymentMethod: String,
        items: [ShopOrderItem]
    ) async throws -> UUID
    func fetchUserOrders(userId: UUID) async throws -> [ShopOrder]
    func fetchOrderItems(for orderId: UUID) async throws -> [ShopOrderItem]
    func fetchReceiptForOrder(orderId: UUID, clientId: UUID) async throws -> ReceiptRecord?
}
