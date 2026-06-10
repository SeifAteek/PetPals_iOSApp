import Foundation

struct MatchFactor: Identifiable {
    let id = UUID()
    let category: String
    let icon: String
    let points: Int
    let explanation: String
}

struct MatchResult {
    let score: Int
    let factors: [MatchFactor]
}

enum PetPersonalityMatcher {
  /// Scores how well a pet fits the adopter's personality profile (0–100).
  static func matchScore(pet: Pet, profile: UserPersonalityProfile) -> Int {
    detailedMatchScore(pet: pet, profile: profile).score
  }

  /// Returns a detailed breakdown of the match score with individual factors.
  static func detailedMatchScore(pet: Pet, profile: UserPersonalityProfile) -> MatchResult {
    var score = 50
    var factors: [MatchFactor] = []

    let species = pet.species?.lowercased() ?? ""
    let breed = pet.breed?.lowercased() ?? ""
    let age = pet.age ?? 3
    let isYoung = age <= 3
    let isSenior = age >= 8

    // MARK: - Living Situation
    if let living = profile.livingSituation?.lowercased() {
      if living.contains("small apartment") {
        let pts = species.contains("cat") ? 18 : (species.contains("bird") ? 15 : -8)
        score += pts
        if species.contains("cat") {
          factors.append(MatchFactor(category: "Living Situation", icon: "house.fill", points: pts, explanation: "Cats adapt very well to apartment living"))
        } else if species.contains("bird") {
          factors.append(MatchFactor(category: "Living Situation", icon: "house.fill", points: pts, explanation: "Birds are well-suited for apartment spaces"))
        } else {
          factors.append(MatchFactor(category: "Living Situation", icon: "house.fill", points: pts, explanation: "This pet may need more space than a small apartment"))
        }
        if breed.contains("retriever") || breed.contains("shepherd") {
          score -= 12
          factors.append(MatchFactor(category: "Living Situation", icon: "house.fill", points: -12, explanation: "Large breeds struggle in small apartments"))
        }
      } else if living.contains("large yard") || living.contains("house with large") {
        let pts = species.contains("dog") ? 15 : 5
        score += pts
        factors.append(MatchFactor(category: "Living Situation", icon: "house.fill", points: pts, explanation: species.contains("dog") ? "Dogs thrive with a large yard to run in" : "Your spacious home is welcoming for any pet"))
      } else if living.contains("house with small") {
        let pts = species.contains("dog") ? 8 : 4
        score += pts
        factors.append(MatchFactor(category: "Living Situation", icon: "house.fill", points: pts, explanation: species.contains("dog") ? "A house with a small yard works for most dogs" : "Your home is a comfortable fit"))
      }
    }

    // MARK: - Activity Level
    if let activity = profile.activityLevel?.lowercased() {
      if activity.contains("very active") {
        let pts = isYoung && species.contains("dog") ? 20 : (isSenior ? -15 : 5)
        score += pts
        if isYoung && species.contains("dog") {
          factors.append(MatchFactor(category: "Activity Level", icon: "figure.run", points: pts, explanation: "Young dogs are perfect for very active owners"))
        } else if isSenior {
          factors.append(MatchFactor(category: "Activity Level", icon: "figure.run", points: pts, explanation: "Senior pets may not keep up with a very active lifestyle"))
        } else {
          factors.append(MatchFactor(category: "Activity Level", icon: "figure.run", points: pts, explanation: "This pet can enjoy an active lifestyle with you"))
        }
      } else if activity.contains("couch") || activity.contains("relaxed") {
        let pts = isSenior || species.contains("cat") ? 15 : (isYoung && species.contains("dog") ? -10 : 5)
        score += pts
        if isSenior || species.contains("cat") {
          factors.append(MatchFactor(category: "Activity Level", icon: "figure.run", points: pts, explanation: species.contains("cat") ? "Cats are great relaxed companions" : "Senior pets enjoy a calm, relaxed home"))
        } else if isYoung && species.contains("dog") {
          factors.append(MatchFactor(category: "Activity Level", icon: "figure.run", points: pts, explanation: "Young dogs need more activity than a relaxed lifestyle offers"))
        } else {
          factors.append(MatchFactor(category: "Activity Level", icon: "figure.run", points: pts, explanation: "This pet can adapt to your relaxed pace"))
        }
      } else if activity.contains("moderately") {
        score += 8
        factors.append(MatchFactor(category: "Activity Level", icon: "figure.run", points: 8, explanation: "Moderate activity suits most pets well"))
      }
    }

    // MARK: - Hours Home
    if let hours = profile.hoursHome?.lowercased() {
      if hours.contains("less than 4") {
        let pts = species.contains("cat") ? 12 : -5
        score += pts
        factors.append(MatchFactor(category: "Hours Home", icon: "clock.fill", points: pts, explanation: species.contains("cat") ? "Cats are independent and handle alone time well" : "This pet may need more companionship during the day"))
      } else if hours.contains("almost always") {
        let pts = species.contains("dog") ? 10 : 6
        score += pts
        factors.append(MatchFactor(category: "Hours Home", icon: "clock.fill", points: pts, explanation: species.contains("dog") ? "Dogs love having their owner home all day" : "Being home often is great for bonding with your pet"))
      }
    }

    // MARK: - Allergies
    if let allergies = profile.allergies?.lowercased() {
      if allergies.contains("severe") || allergies.contains("hypoallergenic") {
        let catPts = species.contains("cat") ? -10 : 0
        score += catPts
        if species.contains("cat") {
          factors.append(MatchFactor(category: "Allergies", icon: "allergens", points: catPts, explanation: "Cats can trigger severe allergies"))
        }
        if breed.contains("poodle") || breed.contains("bichon") || breed.contains("hairless") {
          score += 18
          factors.append(MatchFactor(category: "Allergies", icon: "allergens", points: 18, explanation: "This hypoallergenic breed is great for allergy sufferers"))
        } else if species.contains("dog") && !breed.contains("poodle") {
          score -= 12
          factors.append(MatchFactor(category: "Allergies", icon: "allergens", points: -12, explanation: "This dog breed may not be suitable for allergy sufferers"))
        }
      } else if allergies.contains("non-shedding") {
        let pts = breed.contains("poodle") || species.contains("bird") ? 12 : -5
        score += pts
        factors.append(MatchFactor(category: "Allergies", icon: "allergens", points: pts, explanation: pts > 0 ? "This pet is a low-shedding choice" : "This pet may shed more than you'd prefer"))
      }
    }

    // MARK: - Household
    if let household = profile.householdType?.lowercased() {
      if household.contains("young children") {
        let pts = species.contains("dog") && age >= 2 && age <= 8 ? 15 : 0
        score += pts
        if pts > 0 {
          factors.append(MatchFactor(category: "Household", icon: "person.2.fill", points: pts, explanation: "Adult dogs are typically great with young children"))
        }
        if breed.contains("retriever") || breed.contains("labrador") {
          score += 10
          factors.append(MatchFactor(category: "Household", icon: "person.2.fill", points: 10, explanation: "Retrievers and Labradors are famously kid-friendly"))
        }
      } else if household.contains("elderly") {
        let pts1 = isSenior || species.contains("cat") ? 12 : 0
        score += pts1
        if pts1 > 0 {
          factors.append(MatchFactor(category: "Household", icon: "person.2.fill", points: pts1, explanation: species.contains("cat") ? "Cats are calm companions for elderly households" : "Senior pets match well with a quieter home"))
        }
        let pts2 = isYoung && species.contains("dog") ? -8 : 0
        score += pts2
        if pts2 != 0 {
          factors.append(MatchFactor(category: "Household", icon: "person.2.fill", points: pts2, explanation: "Young dogs may be too energetic for an elderly household"))
        }
      }
    }

    // MARK: - Pet Priority
    if let priority = profile.petPriority?.lowercased() {
      if priority.contains("cuddles") || priority.contains("companionship") {
        let pts = species.contains("cat") ? 12 : 8
        score += pts
        factors.append(MatchFactor(category: "Pet Priority", icon: "heart.fill", points: pts, explanation: species.contains("cat") ? "Cats are wonderful cuddly companions" : "This pet will be a loving companion"))
      } else if priority.contains("playfulness") || priority.contains("energy") {
        let pts = isYoung ? 15 : -5
        score += pts
        factors.append(MatchFactor(category: "Pet Priority", icon: "heart.fill", points: pts, explanation: isYoung ? "Young pets are full of playful energy" : "Older pets tend to be less playful"))
      } else if priority.contains("low maintenance") {
        let pts = species.contains("cat") || species.contains("bird") ? 14 : (isSenior ? 10 : -5)
        score += pts
        if species.contains("cat") || species.contains("bird") {
          factors.append(MatchFactor(category: "Pet Priority", icon: "heart.fill", points: pts, explanation: "This pet is relatively low maintenance"))
        } else if isSenior {
          factors.append(MatchFactor(category: "Pet Priority", icon: "heart.fill", points: pts, explanation: "Senior pets tend to require less active care"))
        } else {
          factors.append(MatchFactor(category: "Pet Priority", icon: "heart.fill", points: pts, explanation: "This pet may need more attention than you prefer"))
        }
      } else if priority.contains("trainability") || priority.contains("intelligence") {
        let pts = species.contains("dog") ? 14 : (species.contains("bird") ? 8 : 0)
        score += pts
        if pts > 0 {
          factors.append(MatchFactor(category: "Pet Priority", icon: "heart.fill", points: pts, explanation: species.contains("dog") ? "Dogs are highly trainable pets" : "Birds can learn impressive tricks"))
        }
        if breed.contains("poodle") || breed.contains("shepherd") {
          score += 8
          factors.append(MatchFactor(category: "Pet Priority", icon: "heart.fill", points: 8, explanation: "This breed is known for exceptional intelligence"))
        }
      }
    }

    // MARK: - Experience
    if let experience = profile.experience?.lowercased() {
      if experience.contains("first time") {
        let pts = age >= 2 && age <= 6 ? 10 : (age < 2 ? -8 : 0)
        score += pts
        if age >= 2 && age <= 6 {
          factors.append(MatchFactor(category: "Experience", icon: "star.fill", points: pts, explanation: "Adult pets are ideal for first-time owners"))
        } else if age < 2 {
          factors.append(MatchFactor(category: "Experience", icon: "star.fill", points: pts, explanation: "Very young pets can be challenging for first-time owners"))
        }
      } else if experience.contains("professional") {
        score += 5
        factors.append(MatchFactor(category: "Experience", icon: "star.fill", points: 5, explanation: "Your professional experience prepares you for any pet"))
      }
    }

    let finalScore = min(100, max(0, score))
    return MatchResult(score: finalScore, factors: factors)
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
