import Foundation

// MARK: - Snapshot JSON (matches web `itemsSnapshot` from ShopOnlineOrders / ShopNewSale)

struct ReceiptItemsSnapshot: Codable, Equatable {
    struct Line: Codable, Equatable {
        let name: String?
        let quantity: Int?
        let unit_price: Double?
        let sub_total: Double?
    }

    let items: [Line]?
    let channel: String?
    let currency: String?
    let total: Double?
}

// MARK: - Receipt row (public.receipts)

struct ReceiptRecord: Codable, Identifiable, Equatable {
    var id: UUID { receipt_id }

    let receipt_id: UUID
    let receipt_number: String?
    let source: String
    let shop_id: UUID?
    let order_id: UUID?
    let client_id: UUID?
    let guest_client_name: String?
    let payment_method: String?
    let payment_status: String?
    let subtotal: Double?
    let discount: Double?
    let total_amount: Double
    let items_snapshot: ReceiptItemsSnapshot?
    let issued_at: Date?
    let notes: String?

    /// Display lines for the receipt sheet (matches PrintBillModal item rows).
    var displayLines: [(name: String, qty: Int, unit: Decimal, line: Decimal)] {
        guard let items = items_snapshot?.items else { return [] }
        return items.compactMap { row in
            let name = row.name?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "—"
            let qty = max(1, row.quantity ?? 1)
            let line = Decimal(row.sub_total ?? 0)
            let unit: Decimal
            if qty > 0, row.sub_total != nil {
                unit = (line / Decimal(qty)).rounded(scale: 2)
            } else {
                unit = Decimal(row.unit_price ?? 0)
            }
            return (name, qty, unit, line)
        }
    }

    var channelLabel: String {
        if let c = items_snapshot?.channel?.trimmingCharacters(in: .whitespacesAndNewlines), !c.isEmpty {
            switch c.lowercased() {
            case "online": return L10n.onlineChannel
            case "in-store", "in store", "instore": return L10n.inStoreChannel
            default: return c
            }
        }
        if source == "shop_pos" { return L10n.inStoreChannel }
        if source == "shop_online_order" { return L10n.onlineChannel }
        return L10n.onlineChannel
    }

    var subtotalValue: Decimal {
        if let s = subtotal { return Decimal(s) }
        return displayLines.reduce(Decimal(0)) { $0 + $1.line }
    }

    var discountValue: Decimal {
        Decimal(discount ?? 0)
    }

    var totalValue: Decimal {
        Decimal(total_amount)
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

private extension Decimal {
    func rounded(scale: Int) -> Decimal {
        var value = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, scale, .plain)
        return rounded
    }
}
