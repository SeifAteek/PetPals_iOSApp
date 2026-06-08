import SwiftUI
import Combine

// MARK: - Shop List (Entry point — replaces old flat product list)
struct ShopMainView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var cartViewModel: CartViewModel
    @StateObject private var viewModel = ShopListViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                PremiumScreenHeader(
                    eyebrow: "Curated",
                    title: "Pet shop",
                    subtitle: "Premium essentials from trusted partners",
                    trailing: AnyView(shopToolbar)
                )

                PremiumSearchField(placeholder: "Search shops…", text: $viewModel.searchText)
                    .padding(.horizontal, ScreenLayout.horizontalPadding)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(viewModel.categories, id: \.self) { cat in
                            PremiumChip(
                                title: cat,
                                isSelected: viewModel.selectedCategory == cat
                            ) {
                                viewModel.selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal, ScreenLayout.horizontalPadding)
                }

                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, 60)
                } else if viewModel.filteredShops.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "storefront").font(.system(size: 50)).foregroundColor(.gray.opacity(0.4))
                        Text("No shops found").font(Theme.Fonts.primaryFont(size: 17)).foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 60)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredShops) { shop in
                            ShopRowCard(shop: shop) {
                                coordinator.push(.shopDetail(shop: shop))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .dismissKeyboardOnSwipe()
        .petPalsScreenBackground()
        .onAppear { viewModel.fetchShops() }
    }

    private var shopToolbar: some View {
        HStack(spacing: Spacing.xs) {
            Button(action: { coordinator.push(.orderHistory) }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Theme.primary)
                    .frame(width: 40, height: 40)
                    .glassCard(cornerRadius: Radius.sm, elevation: .resting)
            }
            Button(action: { coordinator.push(.cart) }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.primary)
                        .frame(width: 40, height: 40)
                        .glassCard(cornerRadius: Radius.sm, elevation: .resting)
                    if cartViewModel.totalItems > 0 {
                        Text("\(cartViewModel.totalItems)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(5)
                            .background(Circle().fill(Theme.primary))
                            .offset(x: 6, y: -6)
                    }
                }
            }
        }
    }
}

// MARK: - Shop Row Card
struct ShopRowCard: View {
    let shop: Shop
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Theme.primary.opacity(0.1))
                        .frame(width: 70, height: 70)
                    if let logoUrl = shop.logoUrl, let url = URL(string: logoUrl) {
                        CachedAsyncImage(url: url) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill()
                            } else {
                                Image(systemName: "storefront.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(Theme.primary.opacity(0.5))
                            }
                        }
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    } else {
                        Image(systemName: "storefront.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Theme.primary.opacity(0.5))
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(shop.name)
                            .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        if shop.isVerified == true {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    if let desc = shop.description {
                        Text(desc)
                            .font(Theme.Fonts.primaryFont(size: 13))
                            .foregroundColor(Theme.textSecondary)
                            .lineLimit(2)
                    }
                    HStack(spacing: 10) {
                        if let category = shop.category {
                            Label(category, systemImage: "tag.fill")
                                .font(.caption)
                                .foregroundColor(Theme.primary)
                        }
                        if let rating = shop.rating {
                            Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }

                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
            }
            .padding(Spacing.sm)
            .glassCard(cornerRadius: Radius.lg, elevation: .raised)
        }
        .buttonStyle(MagneticPressStyle())
    }
}

// MARK: - ViewModel
@MainActor
final class ShopListViewModel: ObservableObject {
    @Published var shops: [Shop] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCategory = "All"

    let categories = ["All", "Food", "Accessories", "Medicine", "Grooming", "Toys"]

    var filteredShops: [Shop] {
        shops.filter { shop in
            let matchCategory = selectedCategory == "All" || shop.category == selectedCategory
            let matchSearch = searchText.isEmpty || shop.name.localizedCaseInsensitiveContains(searchText)
            return matchCategory && matchSearch
        }
    }

    func fetchShops() {
        guard shops.isEmpty else { return }
        isLoading = true
        Task {
            do {
                self.shops = try await DependencyContainer.shared.shopService.fetchShops()
            } catch {
                print("[ShopList] Failed to fetch shops: \(error)")
            }
            self.isLoading = false
        }
    }
}
