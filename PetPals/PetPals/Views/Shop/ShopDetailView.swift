import SwiftUI
import Combine

// MARK: - Shop Detail (products for one shop)
struct ShopDetailView: View {
    let shop: Shop
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var cartViewModel: CartViewModel
    @StateObject private var viewModel: ShopDetailViewModel

    init(shop: Shop) {
        self.shop = shop
        _viewModel = StateObject(wrappedValue: ShopDetailViewModel(shopId: shop.shopId))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Shop hero banner
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [Theme.primary.opacity(0.8), Theme.primary.opacity(0.3)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .frame(height: 160)
                    .cornerRadius(20)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text(shop.name)
                                .font(Theme.Fonts.primaryFont(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            if shop.isVerified == true {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        if let desc = shop.description {
                            Text(desc)
                                .font(Theme.Fonts.primaryFont(size: 13))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        if let rating = shop.rating {
                            Label(String(format: "%.1f ★", rating), systemImage: "")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(16)
                }
                .padding(.horizontal)

                // Category pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.categories, id: \.self) { cat in
                            let selected = viewModel.selectedCategory == cat
                            Button(action: { viewModel.selectedCategory = cat }) {
                                Text(cat)
                                    .font(Theme.Fonts.primaryFont(size: 13, weight: selected ? .bold : .regular))
                                    .padding(.horizontal, 14).padding(.vertical, 7)
                                    .background(selected ? Theme.primary : Theme.cardBackground)
                                    .foregroundColor(selected ? .black : Theme.textSecondary)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Product count
                if !viewModel.isLoading {
                    Text("\(viewModel.filteredProducts.count) products available")
                        .font(Theme.Fonts.primaryFont(size: 13))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal)
                }

                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, 40)
                } else if viewModel.filteredProducts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bag.badge.questionmark").font(.system(size: 50)).foregroundColor(.gray.opacity(0.4))
                        Text("No products in this category").font(Theme.Fonts.primaryFont(size: 16)).foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 40)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.filteredProducts) { product in
                            ShopProductCard(product: product) {
                                coordinator.push(.productDetail(product: product))
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                EntityReviewsSection(entityType: .shop, entityId: shop.shopId)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .clawsyScreenBackground()
        .navigationTitle(shop.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { coordinator.push(.cart) }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart.fill").foregroundColor(Theme.primary)
                        if cartViewModel.totalItems > 0 {
                            Text("\(cartViewModel.totalItems)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
        }
        .onAppear { viewModel.fetchProducts() }
    }
}

// MARK: - Product Card (in-shop grid)
struct ShopProductCard: View {
    let product: PetProduct
    let onTap: () -> Void
    @EnvironmentObject var cartViewModel: CartViewModel

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                // Image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.primary.opacity(0.08))
                        .frame(height: 110)
                    if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                        CachedAsyncImage(url: url) { phase in
                            if let img = phase.image { img.resizable().scaledToFit().padding(8) }
                            else { Image(systemName: "bag.fill").font(.largeTitle).foregroundColor(Theme.primary.opacity(0.3)) }
                        }
                        .frame(height: 110)
                    } else {
                        Image(systemName: "bag.fill").font(.largeTitle).foregroundColor(Theme.primary.opacity(0.3))
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(product.name)
                        .font(Theme.Fonts.primaryFont(size: 13, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(2)
                    if let cat = product.category {
                        Text(cat).font(.caption).foregroundColor(Theme.textSecondary)
                    }
                    // Stock badge
                    if let stock = product.stockLevel, stock <= 5 {
                        Text("Only \(stock) left!").font(.caption).foregroundColor(.orange).bold()
                    }
                }

                HStack {
                    Text(CurrencyFormatting.egp(product.price))
                        .font(Theme.Fonts.primaryFont(size: 15, weight: .bold))
                        .foregroundColor(Theme.accent)
                    Spacer()
                    Button(action: { cartViewModel.addToCart(product) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .padding(12)
            .background(Theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
    }
}

// MARK: - ViewModel
@MainActor
final class ShopDetailViewModel: ObservableObject {
    let shopId: UUID
    @Published var products: [PetProduct] = []
    @Published var isLoading = false
    @Published var selectedCategory = "All"

    var categories: [String] {
        let cats = Set(products.compactMap { $0.category })
        return ["All"] + cats.sorted()
    }

    var filteredProducts: [PetProduct] {
        products.filter { p in
            selectedCategory == "All" || p.category == selectedCategory
        }
    }

    init(shopId: UUID) { self.shopId = shopId }

    func fetchProducts() {
        guard products.isEmpty else { return }
        isLoading = true
        Task {
            do {
                self.products = try await DependencyContainer.shared.shopService.fetchProducts(for: shopId)
            } catch {
                print("[ShopDetail] Failed to fetch products: \(error)")
            }
            self.isLoading = false
        }
    }
}
