import SwiftUI

struct MedicalRecordsListView: View {
    @StateObject var viewModel: PetMedicalViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                } else if viewModel.records.isEmpty {
                    PremiumEmptyState(
                        icon: "heart.text.square",
                        title: "No records yet",
                        message: "Vet visits, vaccines and notes will appear here once they're added."
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    ForEach(viewModel.records) { record in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(record.diagnosis)
                                    .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                if let date = record.visitDate {
                                    Text(date, style: .date)
                                        .font(Theme.Fonts.primaryFont(size: 14))
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                            
                            Text("Treatment: \(record.treatment)")
                                .font(Theme.Fonts.primaryFont(size: 16))
                                .foregroundColor(Theme.textPrimary)
                            
                            if let vet = record.vetName {
                                Text("Veterinarian: \(vet)")
                                    .font(Theme.Fonts.primaryFont(size: 14))
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .padding()
        }
        .petPalsScreenBackground()
        .navigationTitle("Medical Records")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.records.isEmpty {
                viewModel.loadData()
            }
        }
    }
}
