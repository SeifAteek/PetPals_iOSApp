import SwiftUI
import PhotosUI

struct EditPetView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: PetViewModel
    let pet: Pet
    
    init(pet: Pet) {
        self.pet = pet
        _viewModel = StateObject(wrappedValue: PetViewModel())
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Edit Pet Details")
                    .font(Theme.Fonts.primaryFont(size: 28, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                
                // MARK: - Photo Update
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
                        } else if pet.avatarUrl != nil {
                            StandardPetPhoto(avatarUrl: pet.avatarUrl, style: .smallCircle)
                                .frame(width: 100, height: 100)
                                .id(pet.avatarUrl ?? "")
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
                        
                        Text("Change Photo")
                            .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                            .foregroundColor(Theme.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 16) {
                    fieldLabel("Pet Name")
                    CustomTextField(placeholder: "Name", text: $viewModel.newPetName)
                    
                    fieldLabel("Species")
                    Picker("Species", selection: $viewModel.newPetSpecies) {
                        ForEach(viewModel.speciesOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    fieldLabel("Breed")
                    CustomTextField(placeholder: "Breed", text: $viewModel.newPetBreed)
                    
                    fieldLabel("Age (Years)")
                    CustomTextField(placeholder: "Age", text: $viewModel.newPetAge, keyboardType: .numberPad)
                    
                    fieldLabel("Medical History / Notes")
                    CustomTextField(placeholder: "Medical History", text: $viewModel.newPetMedicalHistory)
                }
                
                PrimaryButton(title: "Save Changes", isLoading: viewModel.isLoading) {
                    saveChanges()
                }
                .padding(.top, 16)
            }
            .padding(24)
        }
        .dismissKeyboardOnSwipe()
        .keyboardDoneToolbar()
        .clawsyScreenBackground()
        .onAppear {
            setupFields()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func setupFields() {
        viewModel.newPetName = pet.name
        viewModel.newPetSpecies = pet.species ?? "Dog"
        viewModel.newPetBreed = pet.breed ?? ""
        viewModel.newPetAge = pet.age != nil ? "\(pet.age!)" : ""
        viewModel.newPetMedicalHistory = pet.medicalHistory ?? ""
    }
    
    private func saveChanges() {
        Task {
            do {
                var avatarUrl = pet.avatarUrl
                
                if let imageData = viewModel.selectedImageData {
                    let fileName = "\(pet.petId.uuidString.lowercased()).jpg"
                    avatarUrl = try await DependencyContainer.shared.petService.uploadPetImage(data: imageData, fileName: fileName)
                }
                
                let updatedPet = Pet(
                    petId: pet.petId,
                    shelterId: pet.shelterId,
                    name: viewModel.newPetName,
                    breed: viewModel.newPetBreed.isEmpty ? nil : viewModel.newPetBreed,
                    age: Int(viewModel.newPetAge),
                    status: pet.status,
                    medicalHistory: viewModel.newPetMedicalHistory.isEmpty ? nil : viewModel.newPetMedicalHistory,
                    clinicId: pet.clinicId,
                    guestOwnerName: pet.guestOwnerName,
                    avatarUrl: avatarUrl,
                    guestPhone: pet.guestPhone,
                    species: viewModel.newPetSpecies,
                    ownerId: pet.ownerId,
                    createdAt: pet.createdAt
                )
                
                try await DependencyContainer.shared.petService.updatePet(updatedPet)
                coordinator.pop()
            } catch {
                // Handle error
            }
        }
    }
    
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
            .foregroundColor(Theme.textPrimary)
    }
}
