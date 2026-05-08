import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack {
            if cartViewModel.cartItems.isEmpty {
                Spacer()
                Image(systemName: "cart.badge.minus")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.textSecondary.opacity(0.5))
                Text(L10n.cartEmpty)
                    .font(Theme.Fonts.primaryFont(size: 20, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.top, 16)
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
                            .font(Theme.Fonts.primaryFont(size: 20, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Text(CurrencyFormatting.egp(cartViewModel.totalAmount))
                            .font(Theme.Fonts.primaryFont(size: 24, weight: .bold))
                            .foregroundColor(Theme.accent)
                    }
                    
                    if let error = cartViewModel.checkoutError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(Theme.Fonts.primaryFont(size: 14))
                    }
                    
                    PrimaryButton(title: L10n.checkout, isLoading: cartViewModel.isCheckingOut) {
                        cartViewModel.checkout()
                    }
                }
                .padding(24)
                .background(Theme.cardBackground)
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
            }
        }
        .background(Theme.background.ignoresSafeArea())
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
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "bag.fill")
                    .font(.title)
                    .foregroundColor(Theme.primary.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                
                Text(CurrencyFormatting.egp(product.price))
                    .font(Theme.Fonts.primaryFont(size: 14))
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    cartViewModel.removeFromCart(product)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(Theme.textSecondary)
                }
                
                Text("\(quantity)")
                    .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .frame(width: 20)
                
                Button(action: {
                    cartViewModel.addToCart(product)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Theme.primary)
                }
            }
        }
        .padding(12)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
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
