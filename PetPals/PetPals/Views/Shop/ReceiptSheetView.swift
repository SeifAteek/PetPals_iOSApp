import SwiftUI
import UIKit

/// Owner-facing receipt sheet styled like web `PrintBillModal` (emerald header, EGP totals).
struct ReceiptSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var shareText = ""

    let shopName: String
    let shopLogoURL: String?
    let receipt: ReceiptRecord
    let customerName: String
    let customerEmail: String?

    private let headerGradient = LinearGradient(
        colors: [
            Color(red: 16/255, green: 185/255, blue: 129/255),
            Color(red: 5/255, green: 150/255, blue: 105/255),
            Color(red: 13/255, green: 148/255, blue: 136/255)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private var isOfficialReceipt: Bool { receipt.receipt_number != nil }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            ScrollView {
                VStack(spacing: 0) {
                    brandedCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(red: 248/255, green: 250/255, blue: 252/255))
            actionBar
        }
        .background(Color.white)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText]) {
                showShareSheet = false
            }
        }
    }

    private var headerBar: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 236/255, green: 253/255, blue: 245/255))
                    .frame(width: 40, height: 40)
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color(red: 5/255, green: 150/255, blue: 105/255))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(isOfficialReceipt ? L10n.receiptGenerated : L10n.billReceipt)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 15/255, green: 23/255, blue: 42/255))
                if isOfficialReceipt, let num = receipt.receipt_number {
                    Text("\(L10n.savedToDatabase) · \(num)")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                }
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                    .padding(10)
                    .background(Color(red: 241/255, green: 245/255, blue: 249/255))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var brandedCard: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 14) {
                        shopLogo
                        VStack(alignment: .leading, spacing: 4) {
                            Text(isOfficialReceipt ? L10n.officialReceipt : L10n.salesBill)
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2)
                                .foregroundStyle(Color.white.opacity(0.92))
                            Text(shopName)
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(Color.white)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                            if let d = receipt.issued_at {
                                Text(d.formatted(date: .abbreviated, time: .shortened))
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.white.opacity(0.88))
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 26)
                    .padding(.bottom, 44)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(headerGradient)

                receiptRibbon
                    .padding(.horizontal, 18)
                    .offset(y: 28)
            }
            .padding(.bottom, 36)

            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.billedTo)
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                        Text(customerName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color(red: 30/255, green: 41/255, blue: 59/255))
                            .lineLimit(2)
                        if let email = customerEmail, !email.isEmpty {
                            Text(email)
                                .font(.system(size: 11))
                                .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(L10n.payment)
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                        Text(receipt.payment_method ?? "—")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color(red: 30/255, green: 41/255, blue: 59/255))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(L10n.item).frame(maxWidth: .infinity, alignment: .leading)
                        Text(L10n.qty).frame(width: 36)
                        Text(L10n.unit).frame(width: 72, alignment: .trailing)
                        Text(L10n.amount).frame(width: 72, alignment: .trailing)
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                    .textCase(.uppercase)

                    Divider().opacity(0.35)

                    ForEach(Array(receipt.displayLines.enumerated()), id: \.offset) { _, row in
                        HStack(alignment: .firstTextBaseline) {
                            Text(row.name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(red: 30/255, green: 41/255, blue: 59/255))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2)
                            Text("\(row.qty)")
                                .font(.system(size: 13))
                                .foregroundStyle(Color(red: 71/255, green: 85/255, blue: 105/255))
                                .frame(width: 36)
                            Text(CurrencyFormatting.egp(row.unit))
                                .font(.system(size: 11))
                                .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                                .frame(width: 72, alignment: .trailing)
                            Text(CurrencyFormatting.egp(row.line))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color(red: 15/255, green: 23/255, blue: 42/255))
                                .frame(width: 72, alignment: .trailing)
                        }
                        .padding(.vertical, 6)
                        Divider().opacity(0.2)
                    }
                }

                VStack(spacing: 8) {
                    HStack {
                        Text(L10n.subtotal)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                        Spacer()
                        Text(CurrencyFormatting.egp(receipt.subtotalValue))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 51/255, green: 65/255, blue: 85/255))
                    }
                    if receipt.discountValue > 0 {
                        HStack {
                            Text(L10n.discount)
                                .font(.system(size: 14))
                                .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                            Spacer()
                            Text("-\(CurrencyFormatting.egp(receipt.discountValue))")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(red: 225/255, green: 29/255, blue: 72/255))
                        }
                    }
                    HStack(alignment: .firstTextBaseline) {
                        Text(L10n.totalPaid)
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                        Spacer()
                        Text(CurrencyFormatting.egp(receipt.totalValue))
                            .font(.system(size: 26, weight: .black))
                            .foregroundStyle(Color(red: 5/255, green: 150/255, blue: 105/255))
                    }
                    .padding(.top, 6)
                }
                .padding(.top, 4)
                .overlay(alignment: .top) {
                    Divider().background(Color(red: 203/255, green: 213/255, blue: 225/255))
                }

                VStack(spacing: 4) {
                    Text(L10n.thankYouShoppingFormatted(shopName: shopName))
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                        .multilineTextAlignment(.center)
                    Text(L10n.generatedPetpals)
                        .font(.system(size: 9))
                        .foregroundStyle(Color(red: 203/255, green: 213/255, blue: 225/255))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .overlay(alignment: .top) {
                    Divider().opacity(0.35).padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(red: 241/255, green: 245/255, blue: 249/255), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    private var shopLogo: some View {
        Group {
            if let s = shopLogoURL, let url = URL(string: s) {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        storePlaceholder
                    }
                }
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 2)
                )
            } else {
                storePlaceholder
            }
        }
    }

    private var storePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.95))
                .frame(width: 54, height: 54)
            Image(systemName: "storefront.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color(red: 5/255, green: 150/255, blue: 105/255))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 2)
        )
    }

    private var receiptRibbon: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.receiptNo)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                Text(receipt.receipt_number ?? "BILL-\(receipt.receipt_id.uuidString.prefix(8).uppercased())")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color(red: 15/255, green: 23/255, blue: 42/255))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(L10n.channel)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                Text(receipt.channelLabel)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(red: 51/255, green: 65/255, blue: 85/255))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(red: 226/255, green: 232/255, blue: 240/255), lineWidth: 1)
        )
    }

    private var actionBar: some View {
        HStack(spacing: 10) {
            Button {
                shareText = buildPlainTextSummary()
                showShareSheet = true
            } label: {
                Label(L10n.shareReceipt, systemImage: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 15/255, green: 23/255, blue: 42/255))
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(L10n.close) {
                dismiss()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
            .padding(.horizontal, 12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(alignment: .top) { Divider() }
    }

    private func buildPlainTextSummary() -> String {
        var lines: [String] = []
        if let num = receipt.receipt_number {
            lines.append("Receipt \(num)")
        }
        lines.append(shopName)
        if let d = receipt.issued_at {
            lines.append(d.formatted(date: .abbreviated, time: .shortened))
        }
        lines.append("\(L10n.billedTo): \(customerName)")
        for row in receipt.displayLines {
            lines.append("\(row.name)  x\(row.qty)  \(CurrencyFormatting.egp(row.unit))  \(CurrencyFormatting.egp(row.line))")
        }
        lines.append("\(L10n.subtotal): \(CurrencyFormatting.egp(receipt.subtotalValue))")
        if receipt.discountValue > 0 {
            lines.append("\(L10n.discount): -\(CurrencyFormatting.egp(receipt.discountValue))")
        }
        lines.append("\(L10n.totalPaid): \(CurrencyFormatting.egp(receipt.totalValue))")
        lines.append("\(L10n.payment): \(receipt.payment_method ?? "—")")
        return lines.joined(separator: "\n")
    }
}
