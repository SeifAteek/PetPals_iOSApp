import SwiftUI
import PhotosUI

struct AddPetView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = PetViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Photo Upload
                PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                    VStack(spacing: 12) {
                        if let data = viewModel.selectedImageData, let uiImage = UIImage(data: data) {
                            Color.clear
                                .frame(width: 100, height: 100)
                                .overlay {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                }
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Theme.primary, lineWidth: 2))
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Theme.primary.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(Theme.primary)
                            }
                            .overlay(Circle().stroke(Theme.primary, lineWidth: 2))
                        }
                        
                        Text(viewModel.selectedImageData == nil ? "Add Photo" : "Change Photo")
                            .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                            .foregroundColor(Theme.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                
                // MARK: - Form Fields
                Group {
                    fieldLabel("Full Name*")
                    CustomTextField(placeholder: "e.g. Max", text: $viewModel.newPetName)
                    
                    fieldLabel("Species*")
                    Picker("Select Species", selection: $viewModel.newPetSpecies) {
                        ForEach(viewModel.speciesOptions, id: \.self) { species in
                            Text(species).tag(species)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.textFaint.opacity(0.3), lineWidth: 1))
                    
                    fieldLabel("Breed")
                    CustomTextField(placeholder: "e.g. Golden Retriever", text: $viewModel.newPetBreed)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            fieldLabel("Age")
                            CustomTextField(placeholder: "e.g. 2", text: $viewModel.newPetAge, keyboardType: .numberPad)
                        }
                        VStack(alignment: .leading) {
                            fieldLabel("Weight (kg)")
                            CustomTextField(placeholder: "e.g. 15", text: $viewModel.newPetWeight, keyboardType: .decimalPad)
                        }
                    }
                    
                    fieldLabel("Chip Number")
                    CustomTextField(placeholder: "e.g. 123456789", text: $viewModel.newPetChipNumber)
                    
                    fieldLabel("Vaccination Status")
                    CustomTextField(placeholder: "e.g. Up to date", text: $viewModel.newPetVaccinationStatus)
                }
                
                fieldLabel("About Your Pet")
                TextEditor(text: $viewModel.newPetMedicalHistory)
                    .frame(height: 100)
                    .padding(8)
                    .background(Theme.cardBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.textFaint.opacity(0.3), lineWidth: 1))
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(Theme.statusCritical)
                        .font(Theme.Fonts.primaryFont(size: 14))
                }
                
                PrimaryButton(
                    title: "Save Pet",
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.addNewPet(coordinator: coordinator)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .dismissKeyboardOnSwipe()
        .keyboardDoneToolbar()
        .clawsyScreenBackground()
        .navigationTitle("Add a Pet")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.Fonts.primaryFont(size: 13, weight: .semibold))
            .foregroundColor(Theme.textSecondary)
    }
}

#Preview {
    NavigationView {
        AddPetView()
            .environmentObject(AppCoordinator())
    }
}
