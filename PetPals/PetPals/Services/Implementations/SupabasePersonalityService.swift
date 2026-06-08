import Foundation
import Supabase

protocol PersonalityServiceProtocol {
    func fetchProfile(userId: UUID) async throws -> UserPersonalityProfile?
    func saveProfile(userId: UUID, answers: [String: String]) async throws -> UserPersonalityProfile
}

final class SupabasePersonalityService: PersonalityServiceProtocol {
    private let client = SupabaseClientManager.shared.client

    private enum Field: String, CaseIterable {
        case livingSituation = "living_situation"
        case activityLevel = "activity_level"
        case hoursHome = "hours_home"
        case experience = "experience"
        case allergies = "allergies"
        case householdType = "household_type"
        case petPriority = "pet_priority"

        var question: String {
            switch self {
            case .livingSituation: return "What's your living situation?"
            case .activityLevel: return "How active is your lifestyle?"
            case .hoursHome: return "How many hours a day are you home?"
            case .experience: return "Do you have experience with pets?"
            case .allergies: return "Any allergies or sensitivities?"
            case .householdType: return "Who will mainly be around the pet?"
            case .petPriority: return "What's most important to you in a pet?"
            }
        }
    }

    static var personalityQuestions: [PersonalityQuestion] {
        Field.allCases.map { field in
            PersonalityQuestion(
                question: field.question,
                options: options(for: field)
            )
        }
    }

    func fetchProfile(userId: UUID) async throws -> UserPersonalityProfile? {
        do {
            let row: UserPersonalityProfile = try await client.database
                .from("user_personality_profiles")
                .select()
                .eq("user_id", value: userId.uuidString.lowercased())
                .single()
                .execute()
                .value
            return row
        } catch {
            return nil
        }
    }

    func saveProfile(userId: UUID, answers: [String: String]) async throws -> UserPersonalityProfile {
        guard let living = answers[Field.livingSituation.question],
              let activity = answers[Field.activityLevel.question],
              let hours = answers[Field.hoursHome.question],
              let experience = answers[Field.experience.question],
              let allergies = answers[Field.allergies.question],
              let household = answers[Field.householdType.question],
              let priority = answers[Field.petPriority.question] else {
            throw NSError(
                domain: "PersonalityService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Please answer every question."]
            )
        }

        let payload = UserPersonalityProfileUpsert(
            userId: userId,
            livingSituation: living,
            activityLevel: activity,
            hoursHome: hours,
            experience: experience,
            allergies: allergies,
            householdType: household,
            petPriority: priority
        )

        try await client.database
            .from("user_personality_profiles")
            .upsert(payload, onConflict: "user_id")
            .execute()

        guard let saved = try await fetchProfile(userId: userId) else {
            throw NSError(domain: "PersonalityService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not load saved profile."])
        }
        return saved
    }

    private static func options(for field: Field) -> [String] {
        switch field {
        case .livingSituation:
            return ["Small apartment", "Large apartment", "House with small yard", "House with large yard"]
        case .activityLevel:
            return ["Very active (daily exercise)", "Moderately active", "Mostly indoors / relaxed", "I prefer couch time 😄"]
        case .hoursHome:
            return ["Less than 4 hours", "4–8 hours", "8–12 hours", "Almost always home"]
        case .experience:
            return ["First time owner", "Had pets as a child", "Currently own pets", "Professional experience"]
        case .allergies:
            return ["No allergies", "Mild pet allergies", "Severe allergies (need hypoallergenic)", "Prefer non-shedding breeds"]
        case .householdType:
            return ["Just me", "Me and a partner", "Family with young children", "Elderly family members"]
        case .petPriority:
            return ["Companionship & cuddles", "Playfulness & energy", "Low maintenance", "Intelligence & trainability"]
        }
    }
}
