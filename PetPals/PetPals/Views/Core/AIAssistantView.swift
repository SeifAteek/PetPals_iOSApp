import SwiftUI
import Supabase

// MARK: - Personality Test Model
struct PersonalityQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    var selected: String? = nil
}

// MARK: - AIAssistantView
struct AIAssistantView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showPersonalityTest = false
    @State private var personalityAnswers: [String: String] = [:]
    @State private var testCompleted = false
    @State private var showPetSelection = false
    @StateObject private var petViewModel = PetViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // Header
                ZStack(alignment: .topTrailing) {
                    LinearGradient(
                        gradient: Gradient(colors: [Theme.primary, Theme.primary.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 80, height: 80)
                    .cornerRadius(24)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                    )
                    ZStack {
                        Circle().fill(Color.orange).frame(width: 24, height: 24)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 8, y: -8)
                }
                .padding(.top, 40)

                VStack(spacing: 8) {
                    Text("PetPals AI")
                        .font(Theme.Fonts.primaryFont(size: 28, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text("Your personal pet health & adoption assistant")
                        .font(Theme.Fonts.primaryFont(size: 15))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Personality Test Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: testCompleted ? "checkmark.seal.fill" : "questionmark.circle.fill")
                            .foregroundColor(testCompleted ? .green : Theme.primary)
                        Text(testCompleted ? "Personality Profile Complete ✓" : "Take the Personality Test")
                            .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                    }
                    Text(testCompleted
                         ? "Your profile is ready. The AI will use it to personalise every recommendation."
                         : "Answer a few questions so the AI can give you hyper-personalised pet recommendations.")
                        .font(Theme.Fonts.primaryFont(size: 13))
                        .foregroundColor(Theme.textSecondary)
                    Button(action: { showPersonalityTest = true }) {
                        Text(testCompleted ? "Retake Test" : "Start Test →")
                            .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(testCompleted ? Color.green : Theme.primary)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                .padding(.horizontal, 24)

                // AI Action Rows
                VStack(spacing: 14) {
                    SmartAIActionRow(
                        icon: "pawprint.circle.fill",
                        title: "Match the perfect breed for me",
                        subtitle: "Fetches all available pets & matches to your personality",
                        color: Theme.primary,
                        personalityAnswers: personalityAnswers
                    )
                    SmartAIActionRow(
                        icon: "cross.case.fill",
                        title: "Ask about my pet's symptoms",
                        subtitle: "Describe symptoms and get triage advice",
                        color: .red,
                        personalityAnswers: personalityAnswers,
                        onTap: { showPetSelection = true }
                    )
                    SmartAIActionRow(
                        icon: "fork.knife",
                        title: "Get personalised feeding plans",
                        subtitle: "Nutrition advice based on species and age",
                        color: .orange,
                        personalityAnswers: personalityAnswers
                    )
                    SmartAIActionRow(
                        icon: "doc.text.magnifyingglass",
                        title: "Decode vet medical reports",
                        subtitle: "Paste a report and I'll explain it in plain language",
                        color: .blue,
                        personalityAnswers: personalityAnswers
                    )
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 40)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("AI Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPersonalityTest) {
            PersonalityTestView(answers: $personalityAnswers, completed: $testCompleted)
        }
        .sheet(isPresented: $showPetSelection) {
            PetSelectionSheet(viewModel: petViewModel) { selectedPet in
                showPetSelection = false
                coordinator.push(.aiChat(prompt: "I want to ask about my pet \(selectedPet.name). They are a \(selectedPet.species ?? "pet") (\(selectedPet.breed ?? "unknown breed"))."))
            }
        }
        .onAppear { petViewModel.loadMyPets() }
    }
}

struct PetSelectionSheet: View {
    @ObservedObject var viewModel: PetViewModel
    let onSelect: (Pet) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView().padding()
                } else if viewModel.myPets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "pawprint.circle").font(.system(size: 60)).foregroundColor(.gray.opacity(0.4))
                        Text("No pets found").font(Theme.Fonts.primaryFont(size: 18, weight: .bold))
                        Text("Add a pet in your profile to use the symptom checker.").font(Theme.Fonts.primaryFont(size: 14)).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal)
                        
                        Button("Refresh") { viewModel.loadMyPets() }
                            .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                            .foregroundColor(Theme.primary)
                    }
                    .padding()
                } else {
                    List(viewModel.myPets) { pet in
                        Button(action: { onSelect(pet) }) {
                            HStack(spacing: 16) {
                                if let url = pet.avatarUrl, let imageUrl = URL(string: url) {
                                    AsyncImage(url: imageUrl) { img in img.resizable().scaledToFill() } placeholder: { Color.gray.opacity(0.1) }
                                        .frame(width: 50, height: 50).clipShape(Circle())
                                } else {
                                    Circle().fill(Theme.primary.opacity(0.1)).frame(width: 50, height: 50)
                                        .overlay(Image(systemName: "pawprint.fill").foregroundColor(Theme.primary))
                                }
                                VStack(alignment: .leading) {
                                    Text(pet.name).font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                                    Text(pet.species ?? "Pet").font(Theme.Fonts.primaryFont(size: 13)).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select a Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Cancel") { dismiss() } } }
        }
    }
}

// MARK: - Smart Action Row (fetches DB context before calling AI)
struct SmartAIActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let personalityAnswers: [String: String]
    var onTap: (() -> Void)? = nil
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        Button(action: { 
            if let onTap = onTap {
                onTap()
            } else {
                handleTap() 
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(color.opacity(0.12)).frame(width: 48, height: 48)
                    Image(systemName: icon).foregroundColor(color).font(.system(size: 20))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(Theme.Fonts.primaryFont(size: 15, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text(subtitle)
                        .font(Theme.Fonts.primaryFont(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(Theme.textSecondary).font(.caption)
            }
            .padding()
            .background(Theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
        }
    }

    private func handleTap() {
        if title.contains("breed") {
            coordinator.push(.aiChat(prompt: buildBreedMatchPrompt()))
        } else {
            coordinator.push(.aiChat(prompt: buildGenericPrompt()))
        }
    }

    private func buildBreedMatchPrompt() -> String {
        let personality = personalityAnswers.isEmpty
            ? "No personality test completed yet, make reasonable assumptions."
            : personalityAnswers.map { "- \($0.key): \($0.value)" }.joined(separator: "\n")

        return """
        You are a PetPals AI assistant. A user wants to find their perfect pet.

        **User Personality Profile:**
        \(personality)

        **Your Task:**
        1. Based on the personality profile above, reason about what type of pet and breed would suit this user best.
        2. Consider energy level, living space, experience with pets, time availability, and allergies.
        3. Give a top 3 breed recommendations with a clear explanation for each.
        4. Format your answer in a friendly, conversational way with emojis.

        Start with "Based on your personality profile, here are my top recommendations for you! 🐾"
        """
    }

    private func buildGenericPrompt() -> String {
        return "You are a helpful PetPals AI assistant. The user clicked: \"\(title)\". Start the conversation helpfully and ask for any information you need."
    }
}

// MARK: - Personality Test View
struct PersonalityTestView: View {
    @Binding var answers: [String: String]
    @Binding var completed: Bool
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex = 0
    @State private var tempAnswers: [String: String] = [:]

    let questions: [PersonalityQuestion] = [
        PersonalityQuestion(
            question: "What's your living situation?",
            options: ["Small apartment", "Large apartment", "House with small yard", "House with large yard"]
        ),
        PersonalityQuestion(
            question: "How active is your lifestyle?",
            options: ["Very active (daily exercise)", "Moderately active", "Mostly indoors / relaxed", "I prefer couch time 😄"]
        ),
        PersonalityQuestion(
            question: "How many hours a day are you home?",
            options: ["Less than 4 hours", "4–8 hours", "8–12 hours", "Almost always home"]
        ),
        PersonalityQuestion(
            question: "Do you have experience with pets?",
            options: ["First time owner", "Had pets as a child", "Currently own pets", "Professional experience"]
        ),
        PersonalityQuestion(
            question: "Any allergies or sensitivities?",
            options: ["No allergies", "Mild pet allergies", "Severe allergies (need hypoallergenic)", "Prefer non-shedding breeds"]
        ),
        PersonalityQuestion(
            question: "Who will mainly be around the pet?",
            options: ["Just me", "Me and a partner", "Family with young children", "Elderly family members"]
        ),
        PersonalityQuestion(
            question: "What's most important to you in a pet?",
            options: ["Companionship & cuddles", "Playfulness & energy", "Low maintenance", "Intelligence & trainability"]
        ),
    ]

    var currentQuestion: PersonalityQuestion { questions[currentIndex] }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.gray.opacity(0.15)).frame(height: 6).cornerRadius(3)
                        Rectangle()
                            .fill(Theme.primary)
                            .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(questions.count), height: 6)
                            .cornerRadius(3)
                            .animation(.spring(), value: currentIndex)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .font(Theme.Fonts.primaryFont(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 12)

                Spacer()

                VStack(alignment: .leading, spacing: 24) {
                    Text(currentQuestion.question)
                        .font(Theme.Fonts.primaryFont(size: 22, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        ForEach(currentQuestion.options, id: \.self) { option in
                            let isSelected = tempAnswers[currentQuestion.question] == option
                            Button(action: { tempAnswers[currentQuestion.question] = option }) {
                                HStack {
                                    Text(option)
                                        .font(Theme.Fonts.primaryFont(size: 16))
                                        .foregroundColor(isSelected ? .white : Theme.textPrimary)
                                    Spacer()
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(isSelected ? Theme.primary : Theme.cardBackground)
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
                                .animation(.spring(response: 0.3), value: isSelected)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Navigation buttons
                HStack(spacing: 16) {
                    if currentIndex > 0 {
                        Button(action: { currentIndex -= 1 }) {
                            Text("Back")
                                .font(Theme.Fonts.primaryFont(size: 16, weight: .semibold))
                                .foregroundColor(Theme.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Theme.cardBackground)
                                .cornerRadius(16)
                        }
                    }

                    Button(action: advance) {
                        Text(currentIndex == questions.count - 1 ? "Finish ✓" : "Next →")
                            .font(Theme.Fonts.primaryFont(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(tempAnswers[currentQuestion.question] != nil ? Theme.primary : Color.gray.opacity(0.4))
                            .cornerRadius(16)
                    }
                    .disabled(tempAnswers[currentQuestion.question] == nil)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Personality Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func advance() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            answers = tempAnswers
            completed = true
            dismiss()
        }
    }
}

#Preview {
    NavigationView { AIAssistantView() }
        .environmentObject(AppCoordinator())
}
