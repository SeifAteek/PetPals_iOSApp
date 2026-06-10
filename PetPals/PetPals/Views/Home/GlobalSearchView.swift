import SwiftUI

struct GlobalSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = GlobalSearchViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: Spacing.sm) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
                
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.textSecondary)
                    TextField(L10n.searchPlaceholderHome, text: $viewModel.searchText)
                        .focused($isFocused)
                        .font(Theme.Fonts.body(Typography.callout))
                        .foregroundStyle(Theme.textPrimary)
                        .submitLabel(.search)
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .fill(Theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                .stroke(Theme.glassStroke, lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, ScreenLayout.horizontalPadding)
            .padding(.vertical, Spacing.sm)
            .background(Theme.background)
            
            // Results
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Theme.primary)
                } else if viewModel.searchText.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.textSecondary.opacity(0.5))
                        Text("Search for anything...")
                            .font(Theme.Fonts.body(Typography.callout))
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else if viewModel.results.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.textSecondary.opacity(0.5))
                        Text("No results found")
                            .font(Theme.Fonts.body(Typography.callout))
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: Spacing.md) {
                            
                            // Group results by type
                            let products = viewModel.results.compactMap { result -> PetProduct? in
                                if case let .product(p) = result { return p } else { return nil }
                            }
                            let clinics = viewModel.results.compactMap { result -> Clinic? in
                                if case let .clinic(c) = result { return c } else { return nil }
                            }
                            let pets = viewModel.results.compactMap { result -> Pet? in
                                if case let .pet(p) = result { return p } else { return nil }
                            }
                            let posts = viewModel.results.compactMap { result -> CommunityPost? in
                                if case let .post(p) = result { return p } else { return nil }
                            }
                            
                            if !products.isEmpty {
                                Section(header: Text("Products").font(Theme.Fonts.headline(Typography.title3)).padding(.horizontal)) {
                                    ForEach(products) { product in
                                        PremiumHubRow(icon: "bag.fill", title: product.name, subtitle: product.category, badge: "$\(product.price)") {
                                            dismiss()
                                            coordinator.push(.productDetail(product: product))
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            if !clinics.isEmpty {
                                Section(header: Text("Clinics").font(Theme.Fonts.headline(Typography.title3)).padding(.horizontal)) {
                                    ForEach(clinics) { clinic in
                                        PremiumHubRow(icon: "cross.case.fill", title: clinic.name, subtitle: clinic.location ?? "Clinic") {
                                            dismiss()
                                            coordinator.push(.vetDetail(clinicId: clinic.clinicId))
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            if !pets.isEmpty {
                                Section(header: Text("Pets").font(Theme.Fonts.headline(Typography.title3)).padding(.horizontal)) {
                                    ForEach(pets) { pet in
                                        PremiumHubRow(icon: "pawprint.fill", title: pet.name, subtitle: pet.breed) {
                                            dismiss()
                                            coordinator.push(.petDetail(petId: pet.petId))
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            if !posts.isEmpty {
                                Section(header: Text("Community Posts").font(Theme.Fonts.headline(Typography.title3)).padding(.horizontal)) {
                                    ForEach(posts) { post in
                                        PremiumHubRow(icon: "text.bubble.fill", title: post.title, subtitle: post.authorName) {
                                            dismiss()
                                            coordinator.push(.communityPostDetail(postId: post.postId))
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
}
