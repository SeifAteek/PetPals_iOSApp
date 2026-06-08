import Foundation

enum PetPersonalityMatcher {
  /// Scores how well a pet fits the adopter's personality profile (0–100).
  static func matchScore(pet: Pet, profile: UserPersonalityProfile) -> Int {
    var score = 50

    let species = pet.species?.lowercased() ?? ""
    let breed = pet.breed?.lowercased() ?? ""
    let age = pet.age ?? 3
    let isYoung = age <= 3
    let isSenior = age >= 8

    if let living = profile.livingSituation?.lowercased() {
      if living.contains("small apartment") {
        score += species.contains("cat") ? 18 : (species.contains("bird") ? 15 : -8)
        if breed.contains("retriever") || breed.contains("shepherd") { score -= 12 }
      } else if living.contains("large yard") || living.contains("house with large") {
        score += species.contains("dog") ? 15 : 5
      } else if living.contains("house with small") {
        score += species.contains("dog") ? 8 : 4
      }
    }

    if let activity = profile.activityLevel?.lowercased() {
      if activity.contains("very active") {
        score += isYoung && species.contains("dog") ? 20 : (isSenior ? -15 : 5)
      } else if activity.contains("couch") || activity.contains("relaxed") {
        score += isSenior || species.contains("cat") ? 15 : (isYoung && species.contains("dog") ? -10 : 5)
      } else if activity.contains("moderately") {
        score += 8
      }
    }

    if let hours = profile.hoursHome?.lowercased() {
      if hours.contains("less than 4") {
        score += species.contains("cat") ? 12 : -5
      } else if hours.contains("almost always") {
        score += species.contains("dog") ? 10 : 6
      }
    }

    if let allergies = profile.allergies?.lowercased() {
      if allergies.contains("severe") || allergies.contains("hypoallergenic") {
        score += species.contains("cat") ? -10 : 0
        if breed.contains("poodle") || breed.contains("bichon") || breed.contains("hairless") {
          score += 18
        } else if species.contains("dog") && !breed.contains("poodle") {
          score -= 12
        }
      } else if allergies.contains("non-shedding") {
        score += breed.contains("poodle") || species.contains("bird") ? 12 : -5
      }
    }

    if let household = profile.householdType?.lowercased() {
      if household.contains("young children") {
        score += species.contains("dog") && age >= 2 && age <= 8 ? 15 : 0
        if breed.contains("retriever") || breed.contains("labrador") { score += 10 }
      } else if household.contains("elderly") {
        score += isSenior || species.contains("cat") ? 12 : 0
        score += isYoung && species.contains("dog") ? -8 : 0
      }
    }

    if let priority = profile.petPriority?.lowercased() {
      if priority.contains("cuddles") || priority.contains("companionship") {
        score += species.contains("cat") ? 12 : 8
      } else if priority.contains("playfulness") || priority.contains("energy") {
        score += isYoung ? 15 : -5
      } else if priority.contains("low maintenance") {
        score += species.contains("cat") || species.contains("bird") ? 14 : (isSenior ? 10 : -5)
      } else if priority.contains("trainability") || priority.contains("intelligence") {
        score += species.contains("dog") ? 14 : (species.contains("bird") ? 8 : 0)
        if breed.contains("poodle") || breed.contains("shepherd") { score += 8 }
      }
    }

  if let experience = profile.experience?.lowercased() {
      if experience.contains("first time") {
        score += age >= 2 && age <= 6 ? 10 : (age < 2 ? -8 : 0)
      } else if experience.contains("professional") {
        score += 5
      }
    }

    return min(100, max(0, score))
  }

  static func rank(pets: [Pet], profile: UserPersonalityProfile?) -> [RecommendedPet] {
    guard let profile, profile.isComplete else {
      return pets.map { RecommendedPet(pet: $0, matchScore: 0) }
    }
    return pets
      .map { RecommendedPet(pet: $0, matchScore: matchScore(pet: $0, profile: profile)) }
      .sorted { $0.matchScore > $1.matchScore }
  }
}
