import SwiftUI
import CoreLocation

struct VetDetailView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let clinicId: UUID
    
    @State private var clinic: Clinic? = nil
    @State private var procedures: [ClinicProcedure] = []
    @State private var isLoading = true
    @State private var showFullMap = false
    @State private var showPetPicker = false
    @State private var ownerPets: [Pet] = []
    @State private var isLoadingPets = false
    @State private var petLoadError: String?
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView().frame(maxWidth: .infinity).padding(.top, 50)
            } else if let clinic = clinic {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Vet Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.primary.opacity(0.1))
                                .frame(width: 120, height: 120)
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .foregroundColor(Theme.primary)
                        }
                        
                        VStack(spacing: 4) {
                            Text(clinic.name)
                                .font(Theme.Fonts.primaryFont(size: 24, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            Text("Specialist Veterinarian")
                                .font(Theme.Fonts.primaryFont(size: 16))
                                .foregroundColor(Theme.textSecondary)
                            if let rating = clinic.rating, rating > 0 {
                                Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                    .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.almondCream)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)

                    // MARK: - Procedures & Pricing
                    VStack(alignment: .leading, spacing: 16) {
                        Text(L10n.servicesPricing)
                            .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        
                        if procedures.isEmpty {
                            Text("No pricing information available.")
                                .font(Theme.Fonts.primaryFont(size: 14))
                                .foregroundColor(Theme.textSecondary)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(procedures) { procedure in
                                    HStack {
                                        Text(procedure.name)
                                            .font(Theme.Fonts.primaryFont(size: 15))
                                            .foregroundColor(Theme.textPrimary)
                                        Spacer()
                                        Text(CurrencyFormatting.egp(procedure.price))
                                            .font(Theme.Fonts.primaryFont(size: 15, weight: .bold))
                                            .foregroundColor(Theme.primary)
                                    }
                                    .padding()
                                    .background(Theme.cardBackground)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Location
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Clinic Location")
                            .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        
                        Button(action: {
                            showFullMap = true
                        }) {
                            ZStack {
                                ClinicMapView(clinic: clinic)
                                    .frame(height: 150)
                                    .cornerRadius(16)
                                    .allowsHitTesting(false) // Let the button handle taps
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text(clinic.location ?? "Address not available")
                                            .font(Theme.Fonts.primaryFont(size: 13, weight: .semibold))
                                            .foregroundColor(Theme.textPrimary)
                                            .padding(8)
                                            .background(Theme.cardBackground.opacity(0.9))
                                            .cornerRadius(8)
                                        Spacer()
                                        Image(systemName: "arrow.up.right.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(Theme.primary)
                                            .background(Circle().fill(.white))
                                    }
                                    .padding(8)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $showFullMap) {
                            FullMapView(clinic: clinic)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Working Hours
                    if let workingHours = clinic.workingHours, !workingHours.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Working Hours")
                                    .font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                openNowBadge(workingHours: workingHours)
                            }
                            
                            VStack(spacing: 6) {
                                ForEach(orderedDays, id: \.self) { day in
                                    let hours = workingHours[day] ?? nil
                                    let isToday = currentDayName().lowercased() == day.lowercased()
                                    
                                    HStack {
                                        Text(day.capitalized)
                                            .font(Theme.Fonts.primaryFont(size: 14, weight: isToday ? .bold : .regular))
                                            .foregroundColor(isToday ? Theme.primary : Theme.textPrimary)
                                            .frame(width: 90, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        if let hours {
                                            Text("\(hours.open) - \(hours.close)")
                                                .font(Theme.Fonts.primaryFont(size: 14, weight: isToday ? .semibold : .regular))
                                                .foregroundColor(isToday ? Theme.primary : Theme.textSecondary)
                                        } else {
                                            Text("Closed")
                                                .font(Theme.Fonts.primaryFont(size: 14, weight: .medium))
                                                .foregroundColor(.red.opacity(0.7))
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(isToday ? Theme.primary.opacity(0.08) : Color.clear)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            coordinator.push(.chatRoom(clinicId: clinicId, shelterId: nil, displayName: clinic.name))
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "message.fill")
                                Text("Message")
                                    .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                            }
                            .frame(width: 80, height: 60)
                            .background(Theme.cardBackground)
                            .foregroundColor(Theme.primary)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        PrimaryButton(title: L10n.bookAppointment, isEnabled: !isLoadingPets, isLoading: isLoadingPets) {
                            Task { await openPetPickerForBooking() }
                        }
                    }
                    .padding(.horizontal)

                    EntityReviewsSection(entityType: .clinic, entityId: clinicId)
                        .padding(.bottom, 40)
                }
            } else {
                Text("Clinic details not found").padding()
            }
        }
        .clawsyScreenBackground()
        .navigationTitle("Vet Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadData() }
        .sheet(isPresented: $showPetPicker) {
            NavigationStack {
                Group {
                    if let clinic {
                        if ownerPets.isEmpty {
                            VStack(spacing: 16) {
                                Text("You need at least one pet in My Pets to book a visit.")
                                    .font(Theme.Fonts.primaryFont(size: 16))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Theme.textSecondary)
                                    .padding()
                                Button("OK") { showPetPicker = false }
                                    .font(Theme.Fonts.primaryFont(size: 16, weight: .semibold))
                            }
                            .padding()
                            .navigationTitle("Which pet?")
                            .navigationBarTitleDisplayMode(.inline)
                        } else {
                            List(ownerPets) { pet in
                                Button {
                                    showPetPicker = false
                                    beginCheckout(vetClinic: clinic, pet: pet)
                                } label: {
                                    HStack {
                                        Text(pet.name)
                                            .font(Theme.Fonts.primaryFont(size: 17, weight: .semibold))
                                        Spacer()
                                        Text(pet.species ?? pet.breed ?? "")
                                            .font(.caption)
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                }
                            }
                            .navigationTitle("Which pet?")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") { showPetPicker = false }
                                }
                            }
                        }
                    }
                }
            }
        }
        .alert("Could not load pets", isPresented: Binding(
            get: { petLoadError != nil },
            set: { if !$0 { petLoadError = nil } }
        )) {
            Button("OK", role: .cancel) { petLoadError = nil }
        } message: {
            Text(petLoadError ?? "")
        }
    }
    
    private func beginCheckout(vetClinic: Clinic, pet: Pet) {
        let amount = procedures.first?.price ?? 100
        let summary = procedures.first.map { "Booking: \($0.name)" } ?? "Veterinary consultation"
        coordinator.beginCheckout(
            CheckoutDraft(
                clinicId: clinicId,
                providerDisplayName: vetClinic.name,
                amountEGP: amount,
                serviceSummary: summary,
                kind: .vetConsultation,
                petId: pet.petId,
                petName: pet.name
            )
        )
    }
    
    private func openPetPickerForBooking() async {
        petLoadError = nil
        isLoadingPets = true
        defer { isLoadingPets = false }
        do {
            guard let profile = try await DependencyContainer.shared.authService.getCurrentUser() else {
                petLoadError = "Please sign in to book."
                return
            }
            let pets = try await DependencyContainer.shared.petService.fetchUserPets(userId: profile.userId)
            ownerPets = pets
            showPetPicker = true
        } catch {
            petLoadError = error.localizedDescription
        }
    }
    
    private func loadData() async {
        do {
            let service = DependencyContainer.shared.clinicService
            var fetchedClinic = try await service.fetchClinicDetails(id: clinicId)
            
            // If coordinates are missing, try geocoding
            if (fetchedClinic.latitude == nil || fetchedClinic.latitude == 0),
               let address = fetchedClinic.location {
                let geocoder = CLGeocoder()
                if let placemarks = try? await geocoder.geocodeAddressString(address),
                   let location = placemarks.first?.location {
                    fetchedClinic.latitude = location.coordinate.latitude
                    fetchedClinic.longitude = location.coordinate.longitude
                }
            }
            
            clinic = fetchedClinic
            procedures = try await service.fetchClinicProcedures(id: clinicId)
        } catch {
            // Error handling
        }
        isLoading = false
    }
    
    private func detailStat(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                .foregroundColor(Theme.textPrimary)
            Text(title)
                .font(Theme.Fonts.primaryFont(size: 12))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(width: 80)
        .padding(.vertical, 10)
        .background(Theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Working Hours Helpers
    
    private var orderedDays: [String] {
        ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    }
    
    private func currentDayName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date()).lowercased()
    }
    
    private func isClinicOpenNow(workingHours: [String: DayHours?]) -> Bool {
        let today = currentDayName()
        guard let dayHoursOpt = workingHours[today], let hours = dayHoursOpt else { return false }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        
        guard let openTime = formatter.date(from: hours.open),
              let closeTime = formatter.date(from: hours.close) else { return false }
        
        let now = Date()
        let cal = Calendar.current
        let nowMinutes = cal.component(.hour, from: now) * 60 + cal.component(.minute, from: now)
        let openMinutes = cal.component(.hour, from: openTime) * 60 + cal.component(.minute, from: openTime)
        let closeMinutes = cal.component(.hour, from: closeTime) * 60 + cal.component(.minute, from: closeTime)
        
        return nowMinutes >= openMinutes && nowMinutes < closeMinutes
    }
    
    @ViewBuilder
    private func openNowBadge(workingHours: [String: DayHours?]) -> some View {
        let isOpen = isClinicOpenNow(workingHours: workingHours)
        HStack(spacing: 4) {
            Circle()
                .fill(isOpen ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(isOpen ? "Open Now" : "Closed")
                .font(Theme.Fonts.primaryFont(size: 12, weight: .bold))
                .foregroundColor(isOpen ? .green : .red)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background((isOpen ? Color.green : Color.red).opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        VetDetailView(clinicId: UUID())
            .environmentObject(AppCoordinator())
    }
}
