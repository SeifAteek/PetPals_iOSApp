import Foundation

protocol ClinicServiceProtocol {
    func fetchClinics() async throws -> [Clinic]
    func fetchClinicDetails(id: UUID) async throws -> Clinic
    func fetchClinicProcedures(id: UUID) async throws -> [ClinicProcedure]
    /// All rows from `clinic_procedures` (for grooming filter, etc.).
    func fetchAllClinicProcedures() async throws -> [ClinicProcedure]
    func fetchAppointmentDates(clinicId: UUID, from: Date, to: Date) async throws -> [Date]
}

protocol CharityServiceProtocol {
    func fetchCampaigns() async throws -> [Campaign]
    func fetchCampaignDetails(id: UUID) async throws -> Campaign
    func createDonation(_ donation: Donation) async throws
    func fetchUserDonations(userId: UUID) async throws -> [Donation]
}
