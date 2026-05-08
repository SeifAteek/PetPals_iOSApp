import SwiftUI
import Combine

// MARK: - Shop List (Entry point — replaces old flat product list)
struct ShopMainView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var cartViewModel: CartViewModel
    @StateObject private var viewModel = ShopListViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header row
                HStack {
                    Text("Pet Shop")
                        .font(Theme.Fonts.primaryFont(size: 28, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    // Orders history
                    Button(action: { coordinator.push(.orderHistory) }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundColor(Theme.primary)
                    }
                    // Cart badge
                    Button(action: { coordinator.push(.cart) }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart.fill")
                                .font(.title2)
                                .foregroundColor(Theme.primary)
                                .padding(8)
                            if cartViewModel.totalItems > 0 {
                                Text("\(cartViewModel.totalItems)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 5, y: -5)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search shops...", text: $viewModel.searchText)
                        .font(Theme.Fonts.primaryFont(size: 15))
                }
                .padding(12)
                .background(Theme.cardBackground)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                .padding(.horizontal)

                // Category filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.categories, id: \.self) { cat in
                            let selected = viewModel.selectedCategory == cat
                            Button(action: { viewModel.selectedCategory = cat }) {
                                Text(cat)
                                    .font(Theme.Fonts.primaryFont(size: 13, weight: selected ? .bold : .regular))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selected ? Theme.primary : Theme.cardBackground)
                                    .foregroundColor(selected ? .black : Theme.textSecondary)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
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
        .background(Theme.background.ignoresSafeArea())
        .onAppear { viewModel.fetchShops() }
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
                        AsyncImage(url: url) { phase in
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
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        }
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
