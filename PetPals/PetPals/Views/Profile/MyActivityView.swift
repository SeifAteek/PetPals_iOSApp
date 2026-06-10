import SwiftUI

struct MyActivityView: View {
    @StateObject private var viewModel = UserActivityViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                } else {
                    // Applications Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Adoption Applications")
                            .font(Theme.Fonts.primaryFont(size: 20, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                            .padding(.horizontal)
                        
                        if viewModel.applications.isEmpty {
                            Text("No applications found.")
                                .foregroundColor(Theme.textSecondary)
                                .padding(.horizontal)
                        } else {
                            ForEach(viewModel.applications) { app in
                                ApplicationRow(application: app)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Appointments Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Upcoming Appointments")
                            .font(Theme.Fonts.primaryFont(size: 20, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                            .padding(.horizontal)
                        
                        if viewModel.appointments.isEmpty {
                            Text("No appointments found.")
                                .foregroundColor(Theme.textSecondary)
                                .padding(.horizontal)
                        } else {
                            ForEach(viewModel.appointments) { apt in
                                AppointmentRow(
                                    appointment: apt,
                                    petName: viewModel.petName(for: apt)
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .clawsyScreenBackground()
        .navigationTitle("My Activity")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadActivity()
        }
    }
}

struct ApplicationRow: View {
    let application: PetApplication
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Application for Pet")
                    .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                
                Text(application.submissionDate, style: .date)
                    .font(Theme.Fonts.primaryFont(size: 14))
                    .foregroundColor(Theme.textSecondary)
                
                if let score = application.matchScore {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("AI Match: \(score)%")
                    }
                    .font(Theme.Fonts.primaryFont(size: 12, weight: .bold))
                    .foregroundColor(Theme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.primary.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Text(application.status.rawValue)
                .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                .foregroundColor(statusColor(application.status))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor(application.status).opacity(0.1))
                .cornerRadius(12)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    func statusColor(_ status: ApplicationStatus) -> Color {
        switch status {
        case .approved: return .green
        case .rejected: return .red
        case .underReview: return .orange
        }
    }
}

struct AppointmentRow: View {
    let appointment: Appointment
    var petName: String? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.reason ?? "Appointment")
                    .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                
                if let petName {
                    HStack(spacing: 4) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 11))
                        Text(petName)
                    }
                    .font(Theme.Fonts.primaryFont(size: 13, weight: .medium))
                    .foregroundColor(Theme.primary)
                }
                
                Text(appointment.appointmentDate, style: .date)
                    .font(Theme.Fonts.primaryFont(size: 14))
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            if let status = appointment.status {
                Text(status.rawValue)
                    .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                    .foregroundColor(statusColor(status))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(status).opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    func statusColor(_ status: AppointmentStatus) -> Color {
        switch status {
        case .confirmed: return .green
        case .completed: return .blue
        case .cancelled: return .red
        case .pending: return .orange
        case .missed: return .gray
        }
    }
}
