//
//  PetPalsWidgetsLiveActivity.swift
//  PetPalsWidgets
//
//  Created by Seif Ateek on 09/06/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Brand Colors (mirroring PetPalsPalette for the widget target)
private enum WidgetColors {
    static let powderBlush = Color(red: 0xF2/255, green: 0xA4/255, blue: 0xA5/255)
    static let navy = Color(red: 0x09/255, green: 0x00/255, blue: 0x87/255)
    static let richCerulean = Color(red: 0x30/255, green: 0x78/255, blue: 0xA4/255)
    static let honeydew = Color(red: 0xF2/255, green: 0xFF/255, blue: 0xE9/255)
    static let navyDark = Color(red: 0x01/255, green: 0x0A/255, blue: 0x2E/255)
}

// MARK: - Live Activity Widget

struct PetPalsWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderStatusAttributes.self) { context in
            // MARK: Lock Screen / Banner UI
            LockScreenView(context: context)
                .activityBackgroundTint(WidgetColors.navyDark)
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: statusIcon(for: context.state.status))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(statusColor(for: context.state.status))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.status)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Order #\(context.attributes.orderNumber)")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.attributes.totalAmount)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(WidgetColors.powderBlush)
                        Text(context.attributes.shopName)
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    // Progress steps
                    ExpandedProgressView(status: context.state.status)
                        .padding(.top, 4)
                }
            } compactLeading: {
                // Compact Leading — icon
                HStack(spacing: 4) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(WidgetColors.powderBlush)
                    Text(context.state.status)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
            } compactTrailing: {
                // Compact Trailing — order number
                Text("#\(context.attributes.orderNumber)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(WidgetColors.powderBlush)
            } minimal: {
                // Minimal — just the icon
                Image(systemName: statusIcon(for: context.state.status))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WidgetColors.powderBlush)
            }
            .widgetURL(URL(string: "petpals://orders"))
            .keylineTint(WidgetColors.powderBlush)
        }
    }
}

// MARK: - Lock Screen Banner View

private struct LockScreenView: View {
    let context: ActivityViewContext<OrderStatusAttributes>

    var body: some View {
        VStack(spacing: 0) {
            // Top row: order info
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(WidgetColors.powderBlush.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(WidgetColors.powderBlush)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Order #\(context.attributes.orderNumber)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Text(context.attributes.shopName)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(context.attributes.totalAmount)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WidgetColors.powderBlush)
                    Text(context.state.updatedAt, style: .relative)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // Progress bar
            LockScreenProgressView(status: context.state.status)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 14)
        }
        .activitySystemActionForegroundColor(.white)
    }
}

// MARK: - Lock Screen Progress

private struct LockScreenProgressView: View {
    let status: String

    private var currentStep: Int {
        switch status {
        case "Processing": return 0
        case "Confirmed": return 1
        case "Shipped": return 2
        case "Out for Delivery": return 3
        case "Delivered": return 4
        default: return 0
        }
    }

    private let steps = [
        ("cart.fill", "Placed"),
        ("checkmark.circle.fill", "Confirmed"),
        ("shippingbox.fill", "Shipped"),
        ("bicycle", "On the Way"),
        ("house.fill", "Delivered")
    ]

    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let progress = CGFloat(currentStep) / CGFloat(steps.count - 1)

                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(.white.opacity(0.15))
                        .frame(height: 4)

                    // Active track
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [WidgetColors.powderBlush, WidgetColors.richCerulean],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: totalWidth * progress, height: 4)
                }
            }
            .frame(height: 4)

            // Step labels
            HStack {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack(spacing: 3) {
                        Image(systemName: steps[index].0)
                            .font(.system(size: index <= currentStep ? 13 : 11, weight: index <= currentStep ? .bold : .regular))
                            .foregroundStyle(index <= currentStep ? WidgetColors.powderBlush : .white.opacity(0.35))
                        Text(steps[index].1)
                            .font(.system(size: 8, weight: index == currentStep ? .bold : .regular))
                            .foregroundStyle(index <= currentStep ? .white : .white.opacity(0.35))
                    }
                    if index < steps.count - 1 { Spacer() }
                }
            }
        }
    }
}

// MARK: - Expanded Dynamic Island Progress

private struct ExpandedProgressView: View {
    let status: String

    private var currentStep: Int {
        switch status {
        case "Processing": return 0
        case "Confirmed": return 1
        case "Shipped": return 2
        case "Out for Delivery": return 3
        case "Delivered": return 4
        default: return 0
        }
    }

    private let stepLabels = ["Placed", "Confirmed", "Shipped", "On the Way", "Delivered"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<stepLabels.count, id: \.self) { index in
                VStack(spacing: 3) {
                    ZStack {
                        Circle()
                            .fill(index <= currentStep ? WidgetColors.powderBlush : .white.opacity(0.2))
                            .frame(width: 10, height: 10)
                        if index < currentStep {
                            Image(systemName: "checkmark")
                                .font(.system(size: 6, weight: .bold))
                                .foregroundStyle(WidgetColors.navyDark)
                        }
                    }
                    Text(stepLabels[index])
                        .font(.system(size: 8, weight: index == currentStep ? .bold : .regular))
                        .foregroundStyle(index <= currentStep ? .white : .white.opacity(0.4))
                }
                if index < stepLabels.count - 1 {
                    Rectangle()
                        .fill(index < currentStep ? WidgetColors.powderBlush : .white.opacity(0.15))
                        .frame(height: 2)
                        .padding(.bottom, 14)
                }
            }
        }
    }
}

// MARK: - Helpers

private func statusIcon(for status: String) -> String {
    switch status {
    case "Processing": return "cart.fill"
    case "Confirmed": return "checkmark.circle.fill"
    case "Shipped": return "shippingbox.fill"
    case "Out for Delivery": return "bicycle"
    case "Delivered": return "house.fill"
    case "Cancelled": return "xmark.circle.fill"
    default: return "shippingbox.fill"
    }
}

private func statusColor(for status: String) -> Color {
    switch status {
    case "Processing": return WidgetColors.powderBlush
    case "Confirmed": return .green
    case "Shipped": return WidgetColors.richCerulean
    case "Out for Delivery": return .orange
    case "Delivered": return .green
    case "Cancelled": return .red
    default: return WidgetColors.powderBlush
    }
}

// MARK: - Previews

#Preview("Notification", as: .content, using: OrderStatusAttributes(
    orderNumber: "A1B2C3D4",
    shopName: "PetPals Shop",
    totalAmount: "450 EGP"
)) {
    PetPalsWidgetsLiveActivity()
} contentStates: {
    OrderStatusAttributes.ContentState(status: "Processing", updatedAt: .now)
    OrderStatusAttributes.ContentState(status: "Shipped", updatedAt: .now)
    OrderStatusAttributes.ContentState(status: "Out for Delivery", updatedAt: .now)
    OrderStatusAttributes.ContentState(status: "Delivered", updatedAt: .now)
}
