import SwiftUI

/// Reddit-style up / score / down control.
struct CommunityVoteControl: View {
    let score: Int
    let userVote: Int
    var axis: Axis = .vertical
    var onUp: () -> Void
    var onDown: () -> Void

    var body: some View {
        Group {
            if axis == .vertical {
                VStack(spacing: 2) { voteButtons }
            } else {
                HStack(spacing: 8) { voteButtons }
            }
        }
        .padding(axis == .vertical ? 6 : 8)
        .background {
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .fill(Theme.cardBackground.opacity(0.6))
        }
    }

    @ViewBuilder
    private var voteButtons: some View {
        voteButton(systemName: "arrow.up", filled: userVote == 1, color: Theme.primary, action: onUp)
        Text(scoreFormatted)
            .font(Theme.Fonts.label(Typography.caption, weight: .bold))
            .foregroundStyle(score > 0 ? Theme.primary : (score < 0 ? Theme.primarySoft : Theme.textSecondary))
            .frame(minWidth: 28)
        voteButton(systemName: "arrow.down", filled: userVote == -1, color: Theme.primarySoft, action: onDown)
    }

    private var scoreFormatted: String {
        if score >= 1000 { return String(format: "%.1fk", Double(score) / 1000) }
        return "\(score)"
    }

    private func voteButton(systemName: String, filled: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            Haptic.selection()
            action()
        } label: {
            Image(systemName: filled ? "\(systemName).circle.fill" : systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(filled ? color : Theme.textSecondary)
        }
        .buttonStyle(.plain)
    }
}
