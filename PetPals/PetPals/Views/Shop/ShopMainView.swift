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
                    ProgressView().tint(Theme.primary).frame(maxWidth: .infinity).padding(.top, 60)
                } else if viewModel.filteredShops.isEmpty {
                    PremiumEmptyState(
                        icon: "storefront",
                        title: "No shops found",
                        message: "Try a different search or category."
                    )
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
            PPIconButton(icon: "clock.arrow.circlepath") {
                coordinator.push(.orderHistory)
            }
            ZStack(alignment: .topTrailing) {
                PPIconButton(icon: "bag.fill", solid: true) {
                    coordinator.push(.cart)
                }
                if cartViewModel.totalItems > 0 {
                    Text("\(cartViewModel.totalItems)")
                        .font(Theme.Fonts.label(10, weight: .heavy))
                        .foregroundStyle(Theme.onAccent)
                        .padding(5)
                        .background(Circle().fill(Theme.coral))
                        .offset(x: 5, y: -5)
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
                            .font(Theme.Fonts.headline(15, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        if shop.isVerified == true {
                            PPBadge(text: "Verified", tone: .info, icon: "checkmark.seal.fill")
                        }
                    }
                    if let desc = shop.description {
                        Text(desc)
                            .font(Theme.Fonts.body(Typography.caption, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                            .lineLimit(2)
                    }
                    HStack(spacing: 10) {
                        if let category = shop.category {
                            Label(category, systemImage: "tag.fill")
                                .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                                .foregroundColor(Theme.forest)
                        }
                        if let rating = shop.rating {
                            Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                                .foregroundColor(Theme.statusWarn)
                        }
                    }
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textFaint)
            }
            .padding(Spacing.sm)
            .glassCard(cornerRadius: Radius.lg, elevation: .resting)
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
