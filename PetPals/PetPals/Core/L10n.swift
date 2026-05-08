import Foundation

/// Centralized user-facing copy. Keys live in `en.lproj` / `ar.lproj` `Localizable.strings`.
enum L10n {
    private static func tr(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: .main, value: key, comment: "")
    }

    static var myOrders: String { tr("my_orders") }
    static var noOrdersYet: String { tr("no_orders_yet") }
    static var pastOrdersAppearHere: String { tr("past_orders_appear_here") }
    static var loadingOrders: String { tr("loading_orders") }
    static var shoppingCart: String { tr("shopping_cart") }
    static var cartEmpty: String { tr("cart_empty") }
    static var total: String { tr("total") }
    static var checkout: String { tr("checkout") }
    static var cartMixedShopsError: String { tr("cart_mixed_shops_error") }
    static var cartMissingShopError: String { tr("cart_missing_shop_error") }

    static var checkoutNavTitle: String { tr("checkout_nav_title") }
    static var selectPaymentMethod: String { tr("select_payment_method") }
    static var bookingSummary: String { tr("booking_summary") }
    static var payPrefix: String { tr("pay_prefix") }
    static var paymentSuccessful: String { tr("payment_successful") }
    static var paymentSuccessMessage: String { tr("payment_success_message") }
    static var done: String { tr("done") }
    static var cardHolder: String { tr("card_holder") }
    static var expires: String { tr("expires") }

    static var receiptGenerated: String { tr("receipt_generated") }
    static var billReceipt: String { tr("bill_receipt") }
    static var savedToDatabase: String { tr("saved_to_database") }
    static var officialReceipt: String { tr("official_receipt") }
    static var salesBill: String { tr("sales_bill") }
    static var receiptNo: String { tr("receipt_no") }
    static var channel: String { tr("channel") }
    static var billedTo: String { tr("billed_to") }
    static var payment: String { tr("payment") }
    static var item: String { tr("item") }
    static var qty: String { tr("qty") }
    static var unit: String { tr("unit") }
    static var amount: String { tr("amount") }
    static var subtotal: String { tr("subtotal") }
    static var discount: String { tr("discount") }
    static var totalPaid: String { tr("total_paid") }
    static var generatedPetpals: String { tr("generated_petpals") }
    static var close: String { tr("close") }
    static var shareReceipt: String { tr("share_receipt") }
    static var viewReceipt: String { tr("view_receipt") }
    static var orderDetails: String { tr("order_details") }
    static var noReceiptYet: String { tr("no_receipt_yet") }
    static var onlineChannel: String { tr("channel_online") }
    static var inStoreChannel: String { tr("channel_in_store") }

    static var settings: String { tr("settings") }
    static var language: String { tr("language") }
    static var languageSystem: String { tr("language_system") }
    static var languageEnglish: String { tr("language_english") }
    static var languageArabic: String { tr("language_arabic") }

    static var bookAppointment: String { tr("book_appointment") }
    static var bookNow: String { tr("book_now") }
    static var servicesPricing: String { tr("services_pricing") }
    static var perDay: String { tr("per_day") }
    static var startingFromPerDay: String { tr("starting_from_per_day") }
    static var boardingSamplePrice: String { tr("boarding_sample_price") }
    static var checkoutMissingContext: String { tr("checkout_missing_context") }
    static var userNotAuthenticated: String { tr("user_not_authenticated") }
    static var boardingBookingSummary: String { tr("boarding_booking_summary") }

    static func thankYouShoppingFormatted(shopName: String) -> String {
        let fmt = tr("thank_you_shopping_fmt")
        return String(format: fmt, locale: Locale.current, shopName)
    }
}
