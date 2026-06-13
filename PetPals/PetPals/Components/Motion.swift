import SwiftUI

// MARK: - Heartbeat (the design-system "living" ECG motif)
// Faithful port of components/pet/Heartbeat.jsx — a continuously scrolling ECG
// line with an edge-fade mask and a coral dot that pulses at the beat rate.
// Honors Reduce Motion (renders a static line + steady dot).

struct HeartbeatView: View {
    var color: Color = Theme.coral
    var bpm: Int = 76
    var height: CGFloat = 52
    var segmentWidth: CGFloat = 92
    var lineWidth: CGFloat = 2.5
    var showDot: Bool = true
    var active: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var secondsPerBeat: Double { 60.0 / Double(max(bpm, 1)) }
    private var animating: Bool { active && !reduceMotion }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: !animating)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            // One ECG segment scrolls past per heartbeat — spike and dot stay in sync.
            let speed = Double(segmentWidth) / secondsPerBeat
            let phase = animating
                ? CGFloat((t * speed).truncatingRemainder(dividingBy: Double(segmentWidth)))
                : 0
            // Pulse bump centred ~45% through the beat (matches pp-hb-pulse keyframes).
            let beatProgress = animating
                ? (t.truncatingRemainder(dividingBy: secondsPerBeat)) / secondsPerBeat
                : 0
            let bump = animating ? exp(-pow((beatProgress - 0.45) / 0.16, 2)) : 0

            ZStack(alignment: .trailing) {
                Canvas { ctx, size in
                    ctx.stroke(
                        ecgPath(width: size.width, height: size.height, phase: phase),
                        with: .color(color),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                    )
                }
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.12),
                            .init(color: .black, location: 0.88),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                if showDot {
                    Circle()
                        .fill(color)
                        .frame(width: 7, height: 7)
                        .scaleEffect(1 + 0.35 * bump)
                        .opacity(0.55 + 0.45 * bump)
                        .padding(.trailing, 6)
                }
            }
        }
        .frame(height: height)
        .accessibilityHidden(true)
    }

    /// Builds the repeating ECG polyline, offset left by `phase` for the scroll.
    private func ecgPath(width: CGFloat, height: CGFloat, phase: CGFloat) -> Path {
        let mid = height / 2
        let amp = height * 0.34
        var path = Path()
        let count = Int(ceil(width / segmentWidth)) + 2
        let startX = -segmentWidth - phase
        path.move(to: CGPoint(x: startX, y: mid))
        for i in 0...count {
            let x0 = startX + CGFloat(i) * segmentWidth
            // Fractions/values mirror Heartbeat.jsx `segment()`. v>0 = up (smaller y).
            path.addLine(to: CGPoint(x: x0 + 0.30 * segmentWidth, y: mid))
            path.addLine(to: CGPoint(x: x0 + 0.36 * segmentWidth, y: mid - 0.12 * amp))
            path.addLine(to: CGPoint(x: x0 + 0.42 * segmentWidth, y: mid + 0.18 * amp))
            path.addLine(to: CGPoint(x: x0 + 0.50 * segmentWidth, y: mid - 1.00 * amp))
            path.addLine(to: CGPoint(x: x0 + 0.57 * segmentWidth, y: mid + 0.55 * amp))
            path.addLine(to: CGPoint(x: x0 + 0.63 * segmentWidth, y: mid - 0.10 * amp))
            path.addLine(to: CGPoint(x: x0 + 0.72 * segmentWidth, y: mid))
        }
        return path
    }
}

// MARK: - Skeleton loaders (premium progressive loading)

/// A shimmering placeholder block — use to build skeleton cards.
struct SkeletonBlock: View {
    var cornerRadius: CGFloat = Radius.md

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Theme.surfaceWarm)
            .modifier(ShimmerModifier())
    }
}

/// Skeleton matching `FeaturedPetCard` for the Home recommendations rail.
struct FeaturedPetCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SkeletonBlock(cornerRadius: 0)
                .frame(height: PetImageMetrics.featuredSize.height * 0.72)
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBlock(cornerRadius: Radius.xs).frame(width: 110, height: 14)
                SkeletonBlock(cornerRadius: Radius.xs).frame(width: 70, height: 11)
            }
            .padding(14)
        }
        .frame(width: PetImageMetrics.featuredSize.width)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .glassCard(cornerRadius: Radius.xl, elevation: .resting)
    }
}

/// Skeleton matching the 2-column `PetCard` adoption grid.
struct PetGridCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SkeletonBlock(cornerRadius: 0)
                .frame(height: PetImageMetrics.gridHeight * 0.78)
            VStack(alignment: .leading, spacing: 7) {
                SkeletonBlock(cornerRadius: Radius.xs).frame(width: 90, height: 13)
                SkeletonBlock(cornerRadius: Radius.xs).frame(width: 60, height: 11)
                SkeletonBlock(cornerRadius: Radius.pill).frame(width: 44, height: 18)
            }
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .glassCard(cornerRadius: Radius.lg, elevation: .resting)
    }
}
