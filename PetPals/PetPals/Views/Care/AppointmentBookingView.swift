import SwiftUI
import Supabase

/// Books a clinic appointment without payment: notes + calendar + visible slot occupancy.
struct AppointmentBookingView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    private let clinicService: ClinicServiceProtocol = DependencyContainer.shared.clinicService
    private let client = SupabaseClientManager.shared.client
    
    private let maxSlotsPerDay = 8
    private let openingHour = 9
    private let closingHour = 17
    
    @State private var clinic: Clinic?
    @State private var appointmentDates: [Date] = []
    @State private var isLoading = true
    @State private var loadError: String?
    
    @State private var notes = ""
    @State private var visibleMonth: Date = Date()
    @State private var selectedDay: Date?
    @State private var selectedHour: Int?
    
    @State private var isSubmitting = false
    @State private var submitError: String?
    @State private var didBook = false
    
    private var draft: CheckoutDraft? { coordinator.checkoutDraft }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let draft {
                    header(draft: draft)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Visit notes")
                            .font(Theme.Fonts.primaryFont(size: 14, weight: .semibold))
                            .foregroundColor(Theme.textSecondary)
                        TextField("Describe symptoms, concerns, or boarding details…", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                    }
                    
                    if let clinic {
                        monthNavigator
                        weekdayCalendar(clinic: clinic)
                        
                        if let day = selectedDay {
                            clinicScheduleSection(for: day)
                            timeSlots(for: day)
                        }
                    }
                    
                    PrimaryButton(title: "Request appointment", isEnabled: canSubmit, isLoading: isSubmitting) {
                        Task { await submitBooking() }
                    }
                    
                    if let submitError {
                        Text(submitError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                } else {
                    Text("Missing booking context.")
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Book visit")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadClinicAndSchedule() }
        .alert("Booking requested", isPresented: $didBook) {
            Button("OK") {
                coordinator.clearCheckoutDraft()
                coordinator.pop()
            }
        } message: {
            Text("The clinic will confirm your appointment.")
        }
    }
    
    private func header(draft: CheckoutDraft) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(draft.providerDisplayName)
                .font(Theme.Fonts.primaryFont(size: 22, weight: .bold))
            if draft.kind == .vetConsultation, let petName = draft.petName {
                Text("Pet: \(petName)")
                    .font(Theme.Fonts.primaryFont(size: 15))
                    .foregroundColor(Theme.textSecondary)
            }
            Text(draft.serviceSummary)
                .font(Theme.Fonts.primaryFont(size: 14))
                .foregroundColor(Theme.textSecondary)
        }
    }
    
    private var monthNavigator: some View {
        HStack {
            Button {
                visibleMonth = Calendar.current.date(byAdding: .month, value: -1, to: visibleMonth) ?? visibleMonth
                Task { await reloadAppointmentsOnly() }
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthYearString(visibleMonth))
                .font(Theme.Fonts.primaryFont(size: 17, weight: .semibold))
            Spacer()
            Button {
                visibleMonth = Calendar.current.date(byAdding: .month, value: 1, to: visibleMonth) ?? visibleMonth
                Task { await reloadAppointmentsOnly() }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private func weekdayCalendar(clinic: Clinic) -> some View {
        let days = daysInMonthGrid(around: visibleMonth)
        return VStack(alignment: .leading, spacing: 12) {
            Text("Select a day")
                .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 8) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { w in
                    Text(w)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
                ForEach(days, id: \.self) { day in
                    dayCell(day: day, clinic: clinic)
                }
            }
        }
    }
    
    @ViewBuilder
    private func dayCell(day: MonthDayCell, clinic: Clinic) -> some View {
        if let date = day.date {
            let disabled = isDayUnavailable(date, clinic: clinic)
            let selected = selectedDay.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
            Button {
                guard !disabled else { return }
                selectedDay = date
                selectedHour = nil
            } label: {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(Theme.Fonts.primaryFont(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor(disabled: disabled, selected: selected))
                    )
                    .foregroundColor(foregroundColor(disabled: disabled, selected: selected))
            }
            .buttonStyle(.plain)
            .disabled(disabled)
        } else {
            Color.clear.frame(height: 36)
        }
    }
    
    private func backgroundColor(disabled: Bool, selected: Bool) -> Color {
        if selected { return Theme.primary.opacity(0.25) }
        if disabled { return Color.gray.opacity(0.15) }
        return Theme.cardBackground
    }
    
    private func foregroundColor(disabled: Bool, selected: Bool) -> Color {
        if disabled { return Theme.textSecondary.opacity(0.45) }
        return Theme.textPrimary
    }
    
    private func clinicScheduleSection(for day: Date) -> some View {
        let cal = Calendar.current
        let bookedHours = Set(
            appointmentDates.filter { cal.isDate($0, inSameDayAs: day) }.map { cal.component(.hour, from: $0) }
        )
        return VStack(alignment: .leading, spacing: 10) {
            Text("Clinic schedule (times only)")
                .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
            if bookedHours.isEmpty {
                Text("No bookings shown for this day.")
                    .font(Theme.Fonts.primaryFont(size: 13))
                    .foregroundColor(Theme.textSecondary)
            } else {
                ForEach(bookedHours.sorted(), id: \.self) { h in
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(Theme.textSecondary)
                        Text(String(format: "%02d:00 — Booked", h))
                            .font(Theme.Fonts.primaryFont(size: 14))
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
    
    private func timeSlots(for day: Date) -> some View {
        let cal = Calendar.current
        let taken = Set(
            appointmentDates.filter { cal.isDate($0, inSameDayAs: day) }.map { cal.component(.hour, from: $0) }
        )
        return VStack(alignment: .leading, spacing: 12) {
            Text("Choose a time")
                .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], spacing: 8) {
                ForEach(Array(openingHour..<closingHour), id: \.self) { hour in
                    let busy = taken.contains(hour)
                    let sel = selectedHour == hour
                    Button {
                        guard !busy else { return }
                        selectedHour = hour
                    } label: {
                        Text(String(format: "%02d:00", hour))
                            .font(Theme.Fonts.primaryFont(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(sel ? Theme.primary.opacity(0.3) : (busy ? Color.gray.opacity(0.2) : Theme.cardBackground)))
                            .foregroundColor(busy ? Theme.textSecondary.opacity(0.5) : Theme.textPrimary)
                    }
                    .buttonStyle(.plain)
                    .disabled(busy)
                }
            }
        }
    }
    
    private var canSubmit: Bool {
        guard draft != nil, selectedDay != nil, selectedHour != nil else { return false }
        return true
    }
    
    // MARK: - Data
    
    private func loadClinicAndSchedule() async {
        guard let cid = draft?.clinicId else {
            isLoading = false
            return
        }
        isLoading = true
        loadError = nil
        do {
            let c = try await clinicService.fetchClinicDetails(id: cid)
            clinic = c
            let range = monthRange(for: visibleMonth)
            appointmentDates = try await clinicService.fetchAppointmentDates(clinicId: cid, from: range.start, to: range.end)
            isLoading = false
        } catch {
            loadError = error.localizedDescription
            isLoading = false
        }
    }
    
    private func reloadAppointmentsOnly() async {
        guard let cid = draft?.clinicId else { return }
        do {
            let range = monthRange(for: visibleMonth)
            appointmentDates = try await clinicService.fetchAppointmentDates(clinicId: cid, from: range.start, to: range.end)
        } catch {
            loadError = error.localizedDescription
        }
    }
    
    private func submitBooking() async {
        guard let draft, let day = selectedDay, let hour = selectedHour else { return }
        isSubmitting = true
        submitError = nil
        do {
            let session = try await client.auth.session
            var cal = Calendar.current
            cal.timeZone = .current
            var comps = cal.dateComponents([.year, .month, .day], from: day)
            comps.hour = hour
            comps.minute = 0
            comps.second = 0
            guard let when = cal.date(from: comps) else { throw NSError(domain: "Booking", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid date"]) }
            
            var reasonParts: [String] = []
            if let petName = draft.petName, !petName.isEmpty { reasonParts.append("Pet: \(petName)") }
            reasonParts.append(draft.serviceSummary)
            if !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                reasonParts.append("Notes: \(notes.trimmingCharacters(in: .whitespacesAndNewlines))")
            }
            reasonParts.append("Booked via PetPals app")
            let appointment = Appointment(
                appointmentId: UUID(),
                userId: session.user.id,
                clinicId: draft.clinicId,
                appointmentDate: when,
                reason: reasonParts.joined(separator: " · "),
                status: .pending
            )
            try await client.database.from("appointments").insert(appointment).execute()
            isSubmitting = false
            didBook = true
        } catch {
            isSubmitting = false
            submitError = error.localizedDescription
        }
    }
    
    private func monthRange(for month: Date) -> (start: Date, end: Date) {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: month)) ?? month
        let next = cal.date(byAdding: .month, value: 1, to: start) ?? month
        let end = cal.date(byAdding: .second, value: -1, to: next) ?? month
        return (start, end)
    }
    
    private func isDayUnavailable(_ date: Date, clinic: Clinic) -> Bool {
        let cal = Calendar.current
        let wd = cal.component(.weekday, from: date)
        if wd == 1 || wd == 7 { return true }
        
        let dayStr = localDayString(date)
        if let vac = clinic.vacationDates, vac.contains(dayStr) { return true }
        
        let count = appointmentDates.filter { cal.isDate($0, inSameDayAs: date) }.count
        if count >= maxSlotsPerDay { return true }
        
        if cal.startOfDay(for: date) < cal.startOfDay(for: Date()) { return true }
        
        return false
    }
    
    private func localDayString(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
    
    private func monthYearString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }
    
    private func daysInMonthGrid(around date: Date) -> [MonthDayCell] {
        let cal = Calendar.current
        guard let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: date)),
              let range = cal.range(of: .day, in: .month, for: monthStart) else { return [] }
        let firstWeekday = cal.component(.weekday, from: monthStart)
        let pad = (firstWeekday + 6) % 7
        var cells: [MonthDayCell] = []
        for _ in 0..<pad { cells.append(MonthDayCell(date: nil)) }
        for d in range {
            if let dayDate = cal.date(byAdding: .day, value: d - 1, to: monthStart) {
                cells.append(MonthDayCell(date: dayDate))
            }
        }
        while cells.count % 7 != 0 { cells.append(MonthDayCell(date: nil)) }
        return cells
    }
}

private struct MonthDayCell: Hashable {
    let date: Date?
}
