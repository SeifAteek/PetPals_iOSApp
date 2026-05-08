import Foundation

/// Formats amounts as **EGP** (no $ or £), consistent with ClinicApp / ECommerce.
enum CurrencyFormatting {
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    static func egp(_ amount: Decimal) -> String {
        formatter.locale = Locale.current
        let n = NSDecimalNumber(decimal: amount)
        let num = formatter.string(from: n) ?? String(format: "%.2f", n.doubleValue)
        return "EGP \(num)"
    }

    static func egp(_ amount: Double) -> String {
        egp(Decimal(amount))
    }
}
