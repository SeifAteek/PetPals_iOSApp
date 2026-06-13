import SwiftUI

struct PetProductDetailView: View {
    let product: PetProduct
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var coordinator: AppCoordinator

    @State private var images: [ProductImage] = []
    @State private var selectedImageIndex = 0
    @State private var quantity = 1
    @State private var addedToCart = false
    @State private var isLoadingImages = true

    var maxQty: Int { min(product.stockLevel ?? 99, 99) }

    // All displayable URLs: gallery first, fallback to product.imageUrl
    var allImageUrls: [String] {
        if !images.isEmpty { return images.map(\.url) }
        if let url = product.imageUrl { return [url] }
        return []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Photo Carousel
                ZStack(alignment: .bottom) {
                    if isLoadingImages {
                        ZStack {
                            Rectangle()
                                .fill(Theme.sandSoft)
                                .frame(height: 300)
                            ProgressView().tint(Theme.primary)
                        }
                    } else if allImageUrls.isEmpty {
                        ZStack {
                            Rectangle()
                                .fill(Theme.sandSoft)
                                .frame(height: 300)
                            Image(systemName: "bag.fill")
                                .font(.system(size: 80))
                                .foregroundColor(PetPalsPalette.sand600)
                        }
                    } else {
                        // Swipeable TabView carousel
                        TabView(selection: $selectedImageIndex) {
                            ForEach(allImageUrls.indices, id: \.self) { i in
                                CachedAsyncImage(url: URL(string: allImageUrls[i])) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().scaledToFit()
                                    case .failure:
                                        Image(systemName: "photo").foregroundColor(Theme.textSecondary)
                                    default:
                                        ProgressView()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .background(Theme.sandSoft)
                                .tag(i)
                            }
                        }
                        .frame(height: 300)
                        .tabViewStyle(.page(indexDisplayMode: .never))

                        // Dot indicators
                        if allImageUrls.count > 1 {
                            HStack(spacing: 6) {
                                ForEach(allImageUrls.indices, id: \.self) { i in
                                    Circle()
                                        .fill(i == selectedImageIndex ? Theme.primary : Color.white.opacity(0.5))
                                        .frame(width: i == selectedImageIndex ? 10 : 6,
                                               height: i == selectedImageIndex ? 10 : 6)
                                        .animation(.spring(response: 0.3), value: selectedImageIndex)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    }
                }
                // Thumbnail strip
                if allImageUrls.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(allImageUrls.indices, id: \.self) { i in
                                CachedAsyncImage(url: URL(string: allImageUrls[i])) { phase in
                                    if let img = phase.image {
                                        img.resizable().scaledToFill()
                                    } else {
                                        Theme.textFaint.opacity(0.15)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(i == selectedImageIndex ? Theme.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture { withAnimation { selectedImageIndex = i } }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .background(Theme.cardBackground)
                }

                // MARK: - Product Info
                VStack(alignment: .leading, spacing: 20) {

                    // Name + price
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(product.name)
                                .font(Theme.Fonts.display(Typography.title2))
                                .tracking(-0.4)
                                .foregroundColor(Theme.textPrimary)
                            if let cat = product.category {
                                PPTag(text: cat, icon: "tag.fill")
                            }
                        }
                        Spacer()
                        Text(CurrencyFormatting.egp(product.price))
                            .font(Theme.Fonts.display(Typography.title2))
                            .tracking(-0.4)
                            .foregroundColor(Theme.textPrimary)
                    }

                    // Stock badge
                    if let stock = product.stockLevel {
                        PPBadge(
                            text: stock > 5
                                ? "In stock (\(stock) available)"
                                : "Only \(stock) left — order soon",
                            tone: stock > 5 ? .healthy : .warn,
                            dot: true
                        )
                    }

                    Divider()

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(Theme.Fonts.display(Typography.title3))
                            .tracking(-0.3)
                            .foregroundColor(Theme.textPrimary)
                        Text(product.description ??
                             "High-quality product for your pet. Ensure your companion gets the best care and supplies available.")
                            .font(Theme.Fonts.body(Typography.callout))
                            .foregroundColor(Theme.textBody)
                            .lineSpacing(5)
                    }

                    Divider()

                    // Quantity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quantity")
                            .font(Theme.Fonts.display(Typography.title3))
                            .tracking(-0.3)
                            .foregroundColor(Theme.textPrimary)

                        HStack(spacing: 20) {
                            Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(quantity > 1 ? Theme.primary : .gray.opacity(0.3))
                            }
                            .disabled(quantity <= 1)

                            Text("\(quantity)")
                                .font(Theme.Fonts.mono(20))
                                .foregroundColor(Theme.textPrimary)
                                .frame(minWidth: 30, alignment: .center)
                                .contentTransition(.numericText())
                                .animation(.snappy, value: quantity)

                            Button(action: { if quantity < maxQty { quantity += 1 } }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(quantity < maxQty ? Theme.primary : .gray.opacity(0.3))
                            }
                            .disabled(quantity >= maxQty)

                            Spacer()

                            Text("\(L10n.total): \(CurrencyFormatting.egp(product.price * Decimal(quantity)))")
                                .font(Theme.Fonts.headline(Typography.body, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                                .contentTransition(.numericText())
                                .animation(.snappy, value: quantity)
                        }
                    }

                    // Add to cart
                    Button(action: addToCart) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: addedToCart ? "checkmark.circle.fill" : "cart.badge.plus")
                                .font(.system(size: 18, weight: .semibold))
                            Text(addedToCart ? "Added to cart" : "Add to cart")
                                .font(Theme.Fonts.headline(Typography.body, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background {
                            Capsule(style: .continuous)
                                .fill(addedToCart ? Theme.statusHealthy : Theme.forest)
                        }
                        .animation(Motion.spring, value: addedToCart)
                    }
                    .buttonStyle(MagneticPressStyle())
                    .padding(.top, 4)

                    // View cart link
                    Button(action: { coordinator.push(.cart) }) {
                        Text("View cart (\(cartViewModel.totalItems) items)")
                            .font(Theme.Fonts.label(Typography.caption, weight: .heavy))
                            .foregroundColor(PetPalsPalette.forest500)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.bottom, 40)
                }
                .padding(24)
            }
        }
        .clawsyScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadImages() }
    }

    // MARK: - Helpers
    private func addToCart() {
        for _ in 0..<quantity { cartViewModel.addToCart(product) }
        withAnimation { addedToCart = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { addedToCart = false }
        }
    }

    private func loadImages() {
        Task {
            do {
                let fetched = try await DependencyContainer.shared.shopService
                    .fetchProductImages(for: product.productId)
                await MainActor.run {
                    self.images = fetched
                    // Jump to primary image if available
                    if let primaryIdx = fetched.firstIndex(where: { $0.isPrimary }) {
                        self.selectedImageIndex = primaryIdx
                    }
                    self.isLoadingImages = false
                }
            } catch {
                await MainActor.run { self.isLoadingImages = false }
            }
        }
    }
}
