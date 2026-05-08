import SwiftUI

struct CareView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = CareViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                
                // MARK: - Category Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.categories) { category in
                        Button(action: {
                            switch category.title {
                            case "Veterinary":
                                coordinator.push(.vets)
                            case "Pet Shop":
                                coordinator.push(.shop)
                            case "Boarding":
                                coordinator.push(.vets) // Filtered logic can be added later
                            case "Grooming":
                                coordinator.push(.groomingVets)
                            default:
                                break
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(category.color.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: category.icon)
                                        .foregroundColor(category.color)
                                }
                                Text(category.title)
                                    .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Veterinary Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Top Veterinarians")
                            .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Button("See All") {
                            coordinator.push(.vets)
                        }
                        .font(Theme.Fonts.primaryFont(size: 14))
                        .foregroundColor(Theme.primary)
                    }
                    .padding(.horizontal, 24)
                    
                    if viewModel.isLoading {
                        ProgressView().frame(maxWidth: .infinity).padding()
                    } else {
                        VStack(spacing: 16) {
                            ForEach(Array(viewModel.filteredClinics.prefix(8))) { clinic in
                                ClinicRowCard(clinic: clinic) {
                                    coordinator.push(.vetDetail(clinicId: clinic.id))
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                // MARK: - Tips Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Pet Tips")
                        .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 16) {
                        TipCard(title: "Hydration is Key", desc: "Ensure your pet always has access to fresh water, especially during summer.", icon: "drop.fill", color: .blue)
                        TipCard(title: "Regular Exercise", desc: "A 30-minute walk can significantly improve your dog's mental health.", icon: "figure.walk", color: .green)
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.vertical, 20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Pet Care")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.loadData() }
    }
}

struct TipCard: View {
    let title: String
    let desc: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Fonts.primaryFont(size: 15, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                Text(desc)
                    .font(Theme.Fonts.primaryFont(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationView {
        CareView()
            .environmentObject(AppCoordinator())
    }
}
