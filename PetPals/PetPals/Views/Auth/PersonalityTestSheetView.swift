import SwiftUI

struct PersonalityTestSheetView: View {
    @Binding var answers: [String: String]
    @Binding var completed: Bool
    var onFinished: (([String: String]) async throws -> Void)?
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0
    @State private var tempAnswers: [String: String] = [:]
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let questions = SupabasePersonalityService.personalityQuestions

    private var currentQuestion: PersonalityQuestion { questions[currentIndex] }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar
                Text(L10n.personalityQuestionProgress(currentIndex + 1, questions.count))
                    .font(Theme.Fonts.label(Typography.caption))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, 12)

                if let errorMessage {
                    Text(errorMessage)
                        .font(Theme.Fonts.body(Typography.caption))
                        .foregroundStyle(.red.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.xs)
                }

                Spacer()

                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text(currentQuestion.question)
                        .font(Theme.Fonts.display(Typography.title3))
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, Spacing.md)

                    VStack(spacing: Spacing.xs) {
                        ForEach(currentQuestion.options, id: \.self) { option in
                            optionButton(option)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }

                Spacer()

                navigationButtons
            }
            .petPalsScreenBackground()
            .navigationTitle(L10n.personalityTestTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.cancel) { dismiss() }
                }
            }
            .onAppear {
                if !answers.isEmpty { tempAnswers = answers }
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.textSecondary.opacity(0.2))
                Capsule()
                    .fill(Theme.brandGradient)
                    .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(questions.count))
                    .animation(Motion.spring, value: currentIndex)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
    }

    private func optionButton(_ option: String) -> some View {
        let isSelected = tempAnswers[currentQuestion.question] == option
        return Button {
            tempAnswers[currentQuestion.question] = option
        } label: {
            HStack {
                Text(option)
                    .font(Theme.Fonts.body(Typography.callout))
                    .foregroundStyle(isSelected ? Theme.textOnBrand : Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.textOnBrand)
                }
            }
            .padding(Spacing.sm)
            .background {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(Theme.brandGradient) : AnyShapeStyle(Theme.cardBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                            .stroke(Theme.glassStroke, lineWidth: isSelected ? 0 : 1)
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private var navigationButtons: some View {
        HStack(spacing: Spacing.sm) {
            if currentIndex > 0 {
                Button(L10n.back) { currentIndex -= 1 }
                    .font(Theme.Fonts.headline(Typography.body, weight: .semibold))
                    .foregroundStyle(Theme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            }

            PrimaryButton(
                title: currentIndex == questions.count - 1 ? L10n.personalityFinish : L10n.onboardingContinue,
                isLoading: isSaving
            ) {
                advance()
            }
            .disabled(tempAnswers[currentQuestion.question] == nil || isSaving)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.xl)
    }

    private func advance() {
        guard tempAnswers[currentQuestion.question] != nil else { return }
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            return
        }

        isSaving = true
        errorMessage = nil
        Task {
            do {
                if let onFinished {
                    try await onFinished(tempAnswers)
                }
                answers = tempAnswers
                completed = true
                isSaving = false
                dismiss()
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
