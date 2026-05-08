import Foundation
import Supabase

private struct OrderRowInsert: Encodable {
    let order_id: UUID
    let user_id: UUID
    let shop_id: UUID
    let total_amount: Decimal
    let status: String
    let shipping_address: String?
    let payment_method: String?
}

private struct OrderItemRowInsert: Encodable {
    let order_item_id: UUID
    let order_id: UUID
    let product_id: UUID
    let quantity: Int
    let sub_total: Decimal
}

final class SupabaseShopService: ShopServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    // MARK: - Shops
    func fetchShops() async throws -> [Shop] {
        let shops: [Shop] = try await client.database
            .from("shops")
            .select()
            .execute()
            .value
        return shops
    }
    
    func fetchShop(shopId: UUID) async throws -> Shop {
        let shops: [Shop] = try await client.database
            .from("shops")
            .select()
            .eq("shop_id", value: shopId.uuidString.lowercased())
            .limit(1)
            .execute()
            .value
        guard let shop = shops.first else {
            throw NSError(domain: "SupabaseShopService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Shop not found"])
        }
        return shop
    }
    
    // MARK: - Products (in-stock only, optionally filtered by shop)
    func fetchProducts() async throws -> [PetProduct] {
        let products: [PetProduct] = try await client.database
            .from("products")
            .select()
            .gt("stock_level", value: 0)
            .execute()
            .value
        return products
    }
    
    func fetchProducts(for shopId: UUID) async throws -> [PetProduct] {
        let products: [PetProduct] = try await client.database
            .from("products")
            .select()
            .eq("shop_id", value: shopId.uuidString.lowercased())
            .gt("stock_level", value: 0)
            .execute()
            .value
        return products
    }
    
    func fetchProductImages(for productId: UUID) async throws -> [ProductImage] {
        let images: [ProductImage] = try await client.database
            .from("product_images")
            .select()
            .eq("product_id", value: productId.uuidString.lowercased())
            .order("sort_order", ascending: true)
            .execute()
            .value
        return images
    }
    
    // MARK: - Orders
    func createOrder(
        userId: UUID,
        shopId: UUID,
        totalAmount: Decimal,
        shippingAddress: String?,
        paymentMethod: String,
        items: [ShopOrderItem]
    ) async throws -> UUID {
        let orderId = UUID()
        let row = OrderRowInsert(
            order_id: orderId,
            user_id: userId,
            shop_id: shopId,
            total_amount: totalAmount,
            status: OrderStatus.processing.rawValue,
            shipping_address: shippingAddress,
            payment_method: paymentMethod
        )
        
        try await client.database
            .from("orders")
            .insert(row)
            .execute()
        
        for item in items {
            guard let pid = item.productId else {
                throw NSError(domain: "SupabaseShopService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Order item missing product_id"])
            }
            let ins = OrderItemRowInsert(
                order_item_id: UUID(),
                order_id: orderId,
                product_id: pid,
                quantity: item.quantity,
                sub_total: item.subTotal
            )
            try await client.database
                .from("order_items")
                .insert(ins)
                .execute()
        }
        return orderId
    }
    
    func fetchUserOrders(userId: UUID) async throws -> [ShopOrder] {
        let orders: [ShopOrder] = try await client.database
            .from("orders")
            .select()
            .eq("user_id", value: userId.uuidString.lowercased())
            .order("order_date", ascending: false)
            .execute()
            .value
        return orders
    }
    
    func fetchOrderItems(for orderId: UUID) async throws -> [ShopOrderItem] {
        let items: [ShopOrderItem] = try await client.database
            .from("order_items")
            .select()
            .eq("order_id", value: orderId.uuidString.lowercased())
            .execute()
            .value
        return items
    }
    
    // MARK: - Receipts (owner: rows where `client_id` matches after shop marks delivered / paid flows)
    func fetchReceiptForOrder(orderId: UUID, clientId: UUID) async throws -> ReceiptRecord? {
        let rows: [ReceiptRecord] = try await client.database
            .from("receipts")
            .select()
            .eq("order_id", value: orderId.uuidString.lowercased())
            .eq("client_id", value: clientId.uuidString.lowercased())
            .limit(1)
            .execute()
            .value
        return rows.first
    }
}
