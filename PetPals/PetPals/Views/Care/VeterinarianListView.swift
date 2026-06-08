import SwiftUI

struct VeterinarianListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = CareViewModel()
    @State private var showFilterAlert = false
    var groomingOnly: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Search & Filters
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search clinics...", text: $viewModel.searchText)
                            .onChange(of: viewModel.searchText) { _ in viewModel.filterAndSortClinics() }
                    }
                    .padding(12)
                    .background(Theme.cardBackground)
                    .cornerRadius(12)
                    
                    Button(action: { showFilterAlert = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .padding(12)
                            .background(Theme.primary)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // MARK: - List
                if viewModel.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }.padding(.top, 50)
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.filteredClinics) { clinic in
                            ClinicRowCard(clinic: clinic) {
                                coordinator.push(.vetDetail(clinicId: clinic.id))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .dismissKeyboardOnSwipe()
        .clawsyScreenBackground()
        .navigationTitle(groomingOnly ? "Grooming" : "Veterinarians")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadData(groomingOnly: groomingOnly) }
        .alert("Filter Clinics", isPresented: $showFilterAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Advanced filtering by specialty, distance, and rating is coming soon!")
        }
    }
}

#Preview {
    NavigationView {
        VeterinarianListView()
            .environmentObject(AppCoordinator())
    }
}
