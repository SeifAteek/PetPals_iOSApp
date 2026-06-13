import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack {
            if cartViewModel.cartItems.isEmpty {
                Spacer()
                PremiumEmptyState(
                    icon: "cart",
                    title: L10n.cartEmpty,
                    message: "Treats, food and gear for your pals will show up here."
                )
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(cartViewModel.cartItems.keys), id: \.id) { product in
                            CartItemRow(product: product, quantity: cartViewModel.cartItems[product] ?? 0)
                        }
                    }
                    .padding()
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text(L10n.total)
                            .font(Theme.Fonts.headline(Typography.title3, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Text(CurrencyFormatting.egp(cartViewModel.totalAmount))
                            .font(Theme.Fonts.display(Typography.title2))
                            .tracking(-0.4)
                            .foregroundColor(Theme.textPrimary)
                            .contentTransition(.numericText())
                            .animation(.snappy, value: cartViewModel.totalAmount)
                    }

                    if let error = cartViewModel.checkoutError {
                        Text(error)
                            .foregroundColor(Theme.statusCritical)
                            .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                    }

                    PrimaryButton(title: L10n.checkout, isLoading: cartViewModel.isCheckingOut) {
                        cartViewModel.checkout()
                    }
                }
                .padding(24)
                .background {
                    RoundedCorner(radius: Radius.xl, corners: [.topLeft, .topRight])
                        .fill(Theme.surface)
                        .overlay(
                            RoundedCorner(radius: Radius.xl, corners: [.topLeft, .topRight])
                                .stroke(Theme.borderSubtle, lineWidth: 1)
                        )
                        .shadow(color: Theme.shadowInk.opacity(0.08), radius: 14, y: -4)
                        .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .petPalsScreenBackground()
        .navigationTitle(L10n.shoppingCart)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: cartViewModel.checkoutSuccess) { _, success in
            if success {
                cartViewModel.checkoutSuccess = false
                coordinator.popToRoot()
            }
        }
    }
}

struct CartItemRow: View {
    let product: PetProduct
    let quantity: Int
    @EnvironmentObject var cartViewModel: CartViewModel

    private var maxQty: Int { min(product.stockLevel ?? 99, 99) }
    private var subtotal: Decimal { product.price * Decimal(quantity) }

    var body: some View {
        HStack(spacing: 16) {
            // Product image
            ZStack {
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(Theme.sandSoft)
                    .frame(width: 80, height: 80)
                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                    CachedAsyncImage(url: url) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill()
                        } else {
                            Image(systemName: "bag.fill")
                                .font(.title)
                                .foregroundColor(PetPalsPalette.sand600)
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                } else {
                    Image(systemName: "bag.fill")
                        .font(.title)
                        .foregroundColor(PetPalsPalette.sand600)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(Theme.Fonts.headline(15, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(2)

                Text(CurrencyFormatting.egp(product.price))
                    .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)

                Text(CurrencyFormatting.egp(subtotal))
                    .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                    .foregroundColor(Theme.forest)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: quantity)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        cartViewModel.removeFromCart(product)
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Text("\(quantity)")
                    .font(Theme.Fonts.mono(16))
                    .foregroundColor(Theme.textPrimary)
                    .frame(width: 24)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: quantity)
                
                Button(action: {
                    if quantity < maxQty {
                        withAnimation(.spring(response: 0.3)) {
                            cartViewModel.addToCart(product)
                        }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(quantity < maxQty ? Theme.primary : .gray.opacity(0.3))
                }
                .disabled(quantity >= maxQty)
            }
        }
        .padding(12)
        .glassCard(cornerRadius: Radius.lg, elevation: .resting)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
