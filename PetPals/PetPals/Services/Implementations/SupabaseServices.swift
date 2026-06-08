import Foundation
import Supabase

final class SupabaseClinicService: ClinicServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    private struct AppointmentDateRow: Decodable {
        let appointment_date: Date
    }
    
    func fetchClinics() async throws -> [Clinic] {
        let clinics: [Clinic] = try await client.database
            .from("clinics")
            .select()
            .execute()
            .value
        return clinics
    }
    
    func fetchClinicDetails(id: UUID) async throws -> Clinic {
        let clinic: Clinic = try await client.database
            .from("clinics")
            .select()
            .eq("clinic_id", value: id.uuidString.lowercased())
            .single()
            .execute()
            .value
        return clinic
    }
    
    func fetchClinicProcedures(id: UUID) async throws -> [ClinicProcedure] {
        let procedures: [ClinicProcedure] = try await client.database
            .from("clinic_procedures")
            .select()
            .eq("clinic_id", value: id.uuidString.lowercased())
            .execute()
            .value
        return procedures
    }
    
    func fetchAllClinicProcedures() async throws -> [ClinicProcedure] {
        let procedures: [ClinicProcedure] = try await client.database
            .from("clinic_procedures")
            .select()
            .execute()
            .value
        return procedures
    }
    
    func fetchAppointmentDates(clinicId: UUID, from: Date, to: Date) async throws -> [Date] {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fromStr = fmt.string(from: from)
        let toStr = fmt.string(from: to)
        
        let rows: [AppointmentDateRow] = try await client.database
            .from("appointments")
            .select("appointment_date")
            .eq("clinic_id", value: clinicId.uuidString.lowercased())
            .in("status", values: ["Pending", "Confirmed"])
            .gte("appointment_date", value: fromStr)
            .lte("appointment_date", value: toStr)
            .execute()
            .value
        return rows.map(\.appointment_date)
    }
}

final class SupabaseCharityService: CharityServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func fetchCampaigns() async throws -> [Campaign] {
        let campaigns: [Campaign] = try await client.database
            .from("campaigns")
            .select()
            .eq("is_deleted", value: false)
            .execute()
            .value
        return campaigns
    }
    
    func fetchCampaignDetails(id: UUID) async throws -> Campaign {
        let campaign: Campaign = try await client.database
            .from("campaigns")
            .select()
            .eq("campaign_id", value: id.uuidString.lowercased())
            .eq("is_deleted", value: false)
            .single()
            .execute()
            .value
        return campaign
    }
    
    func createDonation(_ donation: Donation) async throws {
        // 1. Insert the donation
        try await client.database
            .from("donations")
            .insert(donation)
            .execute()
            
        // 2. Update the campaign's current amount
        if let campaignId = donation.campaignId {
            let campaign = try await fetchCampaignDetails(id: campaignId)
            let newAmount = (campaign.currentAmount ?? 0) + donation.amount
            
            try await client.database
                .from("campaigns")
                .update(["current_amount": newAmount])
                .eq("campaign_id", value: campaignId.uuidString.lowercased())
                .execute()
        }
    }
    
    func fetchUserDonations(userId: UUID) async throws -> [Donation] {
        let donations: [Donation] = try await client.database
            .from("donations")
            .select()
            .eq("user_id", value: userId.uuidString.lowercased())
            .order("donation_date", ascending: false)
            .execute()
            .value
        return donations
    }
}

// MARK: - Reviews

final class SupabaseReviewService: ReviewServiceProtocol {
    private let client = SupabaseClientManager.shared.client

    private struct ReviewRow: Decodable {
        let reviewId: UUID
        let userId: UUID?
        let entityType: ReviewEntityType
        let entityId: UUID
        let rating: Int
        let comment: String?
        let createdAt: Date?
        let profiles: ReviewerProfile?

        enum CodingKeys: String, CodingKey {
            case reviewId = "review_id"
            case userId = "user_id"
            case entityType = "entity_type"
            case entityId = "entity_id"
            case rating
            case comment
            case createdAt = "created_at"
            case profiles
        }
    }

    private struct ReviewerProfile: Decodable {
        let userName: String?

        enum CodingKeys: String, CodingKey {
            case userName = "user_name"
        }
    }

    func fetchReviews(entityType: ReviewEntityType, entityId: UUID) async throws -> [EntityReview] {
        let rows: [ReviewRow] = try await client.database
            .from("entity_reviews")
            .select("review_id, user_id, entity_type, entity_id, rating, comment, created_at, profiles(user_name)")
            .eq("entity_type", value: entityType.rawValue)
            .eq("entity_id", value: entityId.uuidString.lowercased())
            .order("created_at", ascending: false)
            .execute()
            .value

        return rows.map { row in
            EntityReview(
                reviewId: row.reviewId,
                userId: row.userId,
                entityType: row.entityType,
                entityId: row.entityId,
                rating: row.rating,
                comment: row.comment,
                createdAt: row.createdAt,
                reviewerName: row.profiles?.userName
            )
        }
    }

    func submitReview(
        userId: UUID,
        entityType: ReviewEntityType,
        entityId: UUID,
        rating: Int,
        comment: String
    ) async throws {
        let payload = EntityReviewInsert(
            userId: userId,
            entityType: entityType.rawValue,
            entityId: entityId,
            rating: rating,
            comment: comment.isEmpty ? nil : comment
        )
        try await client.database
            .from("entity_reviews")
            .upsert(payload, onConflict: "user_id,entity_type,entity_id")
            .execute()
    }
}
