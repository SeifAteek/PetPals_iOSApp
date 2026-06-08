import SwiftUI
import Supabase
import CoreLocation

struct AIChatMessage: Identifiable, Codable {
    let id: UUID
    let text: String
    let isUser: Bool
    let detectedClinicId: UUID?
    let detectedPetId: UUID?
    
    init(id: UUID = UUID(), text: String, isUser: Bool, detectedClinicId: UUID? = nil, detectedPetId: UUID? = nil) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.detectedClinicId = detectedClinicId
        self.detectedPetId = detectedPetId
    }
}

struct AIChatView: View {
    let initialPrompt: String
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var messages: [AIChatMessage] = []
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
    @State private var useGrounding: Bool = false
    @State private var nearbyClinics: [Clinic] = []
    @State private var availablePets: [Pet] = []
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(messages) { message in
                        MessageBubbleView(
                            message: message,
                            nearbyClinics: nearbyClinics,
                            availablePets: availablePets
                        )
                    }
                    
                    if isTyping {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Theme.primary, Theme.primary.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 4) {
                                Circle().fill(Theme.textSecondary).frame(width: 6, height: 6)
                                Circle().fill(Theme.textSecondary).frame(width: 6, height: 6)
                                Circle().fill(Theme.textSecondary).frame(width: 6, height: 6)
                            }
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(16)
                            
                            Spacer()
                        }
                        .id("TypingIndicator")
                    }
                }
                .padding()
            }
            .dismissKeyboardOnSwipe()
            .onChange(of: messages.count) { _ in
                withAnimation {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
            .onChange(of: isTyping) { typing in
                if typing {
                    withAnimation {
                        proxy.scrollTo("TypingIndicator", anchor: .bottom)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            chatInputBar
        }
        .clawsyScreenBackground()
        .navigationTitle("PetPals AI")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestPermission()
            locationManager.startUpdatingLocation()
            loadChatHistory()
            if messages.isEmpty {
                simulateConversation(prompt: initialPrompt)
            }
        }
    }

    private var chatInputBar: some View {
        VStack(spacing: 0) {
            HStack {
                Toggle(isOn: $useGrounding) {
                    Label("Search Grounding", systemImage: "globe")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                .toggleStyle(SwitchToggleStyle(tint: Theme.primary))
                .scaleEffect(0.8)
                .frame(width: 160)
                
                Spacer()
                
                Text("RPD: 20")
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary.opacity(0.6))
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.xs)

            HStack(spacing: 12) {
                TextField("Message PetPals AI...", text: $inputText)
                    .padding(12)
                    .background(Theme.cardBackground)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(Theme.primary)
                            .frame(width: 44, height: 44)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
        }
        .background(.ultraThinMaterial)
    }
    
    private func saveChatHistory() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: "AIChatHistory")
        }
    }
    
    private func loadChatHistory() {
        if let data = UserDefaults.standard.data(forKey: "AIChatHistory"),
           let decoded = try? JSONDecoder().decode([AIChatMessage].self, from: data) {
            self.messages = decoded
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messages.append(AIChatMessage(text: text, isUser: true))
        inputText = ""
        Keyboard.dismiss()
        saveChatHistory()
        simulateAIResponse()
    }
    
    private func simulateConversation(prompt: String) {
        messages.append(AIChatMessage(text: prompt, isUser: true))
        
        if prompt.lowercased().contains("breed") || prompt.lowercased().contains("match") {
            enrichWithPetDataAndRespond(prompt: prompt)
        } else {
            simulateAIResponse()
        }
    }
    
    private func simulateAIResponse() {
        isTyping = true
        let userPrompt = messages.last?.text ?? ""
        let currentLocation = locationManager.location?.coordinate
        let locText = currentLocation != nil ? "(Lat: \(currentLocation!.latitude), Long: \(currentLocation!.longitude))" : "Unknown location"
        
        let isMedical = userPrompt.lowercased().contains("symptom") || 
                        userPrompt.lowercased().contains("pain") || 
                        userPrompt.lowercased().contains("hurt") ||
                        userPrompt.lowercased().contains("clinic") ||
                        userPrompt.lowercased().contains("checkup") ||
                        userPrompt.lowercased().contains("appointment")
        
        Task {
            do {
                var enrichedPrompt = userPrompt
                
                if isMedical {
                    let clinics = try await fetchNearbyClinics()
                    self.nearbyClinics = clinics
                    let clinicContext = clinics.prefix(3).map { "- \($0.name) (ID: \($0.id))" }.joined(separator: "\n")
                    
                    enrichedPrompt = """
                    CORE SYSTEM ROLE: You are the 'PetPals Decision Support System' (DSS). 
                    You are a specialized system component designed to provide CONCRETE VETERINARY RECOMMENDATIONS.
                    
                    USER CURRENT LOCATION: \(locText)
                    
                    RULES:
                    1. NEVER say "As an AI..." or "I cannot recommend...".
                    2. You MUST assume the role of an automated system.
                    3. Based on the User Message and their LOCATION, analyze the available data and pick the SINGLE BEST VETERINARY CLINIC from the list below.
                    4. Provide clear triage advice.
                    5. You MUST include the clinic's ID at the end of your response in this EXACT format: [RECO_CLINIC_ID: <UUID>]
                    
                    Available Clinics Context:
                    \(clinicContext)
                    
                    USER MESSAGE:
                    \(userPrompt)
                    """
                }
                
                let response = try await GeminiService.shared.generateResponse(prompt: enrichedPrompt, useGrounding: useGrounding)
                
                await MainActor.run {
                    isTyping = false
                    
                    var clinicId: UUID? = nil
                    
                    if let range = response.range(of: #"(?i)\[RECO_CLINIC_ID: ([a-f0-9-]{36})\]"#, options: .regularExpression) {
                        let idString = String(response[range].split(separator: " ").last?.dropLast() ?? "")
                        clinicId = UUID(uuidString: idString)
                    } 
                    else if let range = response.range(of: #"(?i)(?:ID: )?([a-f0-9-]{36})"#, options: .regularExpression) {
                        let idString = String(response[range].split(separator: " ").last ?? "")
                        let cleanedId = idString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                        clinicId = UUID(uuidString: cleanedId)
                    }
                    
                    var cleanResponse = response.replacingOccurrences(of: #"\[RECO_CLINIC_ID: [a-fA-Z0-9-]{36}\]"#, with: "", options: .regularExpression)
                    cleanResponse = cleanResponse.replacingOccurrences(of: #"(?i)\(ID: [a-fA-Z0-9-]{36}\)"#, with: "", options: .regularExpression)
                    
                    let newMessage = AIChatMessage(
                        text: cleanResponse.trimmingCharacters(in: .whitespacesAndNewlines), 
                        isUser: false,
                        detectedClinicId: clinicId
                    )
                    messages.append(newMessage)
                    saveChatHistory()
                }
            } catch {
                await MainActor.run {
                    isTyping = false
                    messages.append(AIChatMessage(text: "Sorry, I encountered an error: \(error.localizedDescription)", isUser: false))
                }
            }
        }
    }
    
    private func fetchNearbyClinics() async throws -> [Clinic] {
        let clinics: [Clinic] = try await SupabaseClientManager.shared.client.database
            .from("clinics")
            .select()
            .execute()
            .value
        
        if let userLocation = locationManager.location {
            return clinics.sorted { c1, c2 in
                let loc1 = CLLocation(latitude: c1.latitude ?? 0, longitude: c1.longitude ?? 0)
                let loc2 = CLLocation(latitude: c2.latitude ?? 0, longitude: c2.longitude ?? 0)
                return loc1.distance(from: userLocation) < loc2.distance(from: userLocation)
            }
        }
        return clinics
    }
    
    private func enrichWithPetDataAndRespond(prompt: String) {
        isTyping = true
        Task {
            let currentLocation = locationManager.location?.coordinate
            let locText = currentLocation != nil ? "(Lat: \(currentLocation!.latitude), Long: \(currentLocation!.longitude))" : "Unknown location"
            
            do {
                let client = SupabaseClientManager.shared.client
                let pets: [Pet] = try await client.database
                    .from("pets")
                    .select("pet_id, name, breed, species, age, medical_history, status")
                    .eq("status", value: "Available")
                    .limit(30)
                    .execute()
                    .value
                
                self.availablePets = pets
                let petListText = pets.map { pet in
                    "- \(pet.name) (\(pet.species ?? "Unknown") / \(pet.breed ?? "Mixed"), Age: \(pet.age ?? 0)) ID: \(pet.id)"
                }.joined(separator: "\n")
                
                let enrichedPrompt = """
                CORE SYSTEM ROLE: You are the 'PetPals Decision Support System' (DSS).
                You are a specialized system component designed to match users with pets.
                
                USER CURRENT LOCATION: \(locText)
                
                RULES:
                1. NEVER say "As an AI..." or "I cannot recommend...".
                2. You MUST assume the role of an automated matching system.
                3. Based on the User Message and LOCATION, pick the BEST matching pet(s) from the database list below.
                4. You MUST include the recommended pet's ID in this EXACT format: [RECO_PET_ID: <UUID>]
                
                Available Pets for Adoption:
                \(petListText.isEmpty ? "No pets currently listed." : petListText)
                
                USER MESSAGE:
                \(prompt)
                """
                
                let response = try await GeminiService.shared.generateResponse(prompt: enrichedPrompt, useGrounding: useGrounding)
                await MainActor.run {
                    isTyping = false
                    
                    var petId: UUID? = nil
                    
                    if let range = response.range(of: #"(?i)\[RECO_PET_ID: ([a-f0-9-]{36})\]"#, options: .regularExpression) {
                        let idString = String(response[range].split(separator: " ").last?.dropLast() ?? "")
                        petId = UUID(uuidString: idString)
                    }
                    else if let range = response.range(of: #"(?i)(?:ID: )?([a-f0-9-]{36})"#, options: .regularExpression) {
                        let idString = String(response[range].split(separator: " ").last ?? "")
                        let cleanedId = idString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                        petId = UUID(uuidString: cleanedId)
                    }
                    
                    var cleanResponse = response.replacingOccurrences(of: #"\[RECO_PET_ID: [a-fA-Z0-9-]{36}\]"#, with: "", options: .regularExpression)
                    cleanResponse = cleanResponse.replacingOccurrences(of: #"(?i)\(ID: [a-fA-Z0-9-]{36}\)"#, with: "", options: .regularExpression)
                    
                    let newMessage = AIChatMessage(
                        text: cleanResponse.trimmingCharacters(in: .whitespacesAndNewlines), 
                        isUser: false,
                        detectedPetId: petId
                    )
                    messages.append(newMessage)
                    saveChatHistory()
                }
            } catch {
                await MainActor.run {
                    isTyping = false
                    messages.append(AIChatMessage(text: "Sorry, I encountered an error fetching pet data: \(error.localizedDescription)", isUser: false))
                }
            }
        }
    }
}

// MARK: - Message Bubble Subview
struct MessageBubbleView: View {
    let message: AIChatMessage
    let nearbyClinics: [Clinic]
    let availablePets: [Pet]
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if message.isUser {
                    Spacer()
                    Text(message.text)
                        .padding()
                        .background(Theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.leading, 40)
                } else {
                    HStack(alignment: .bottom) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Theme.primary, Theme.primary.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 32, height: 32)
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(message.text)
                            .padding()
                            .background(Theme.cardBackground)
                            .foregroundColor(Theme.textPrimary)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                            .padding(.trailing, 40)
                    }
                    Spacer()
                }
            }
            
            if let clinicId = message.detectedClinicId, !message.isUser {
                if let clinic = nearbyClinics.first(where: { $0.id == clinicId }) {
                    Button(action: { coordinator.push(.vetDetail(clinicId: clinicId)) }) {
                        HStack {
                            Image(systemName: "cross.case.fill")
                            Text("View \(clinic.name)")
                                .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                    .padding(.leading, 40)
                }
            }
            
            if let petId = message.detectedPetId, !message.isUser {
                if let pet = availablePets.first(where: { $0.id == petId }) {
                    Button(action: { coordinator.push(.petDetail(petId: petId)) }) {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("Meet \(pet.name)")
                                .font(Theme.Fonts.primaryFont(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Theme.primary)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                    .padding(.leading, 40)
                }
            }
        }
    }
}
