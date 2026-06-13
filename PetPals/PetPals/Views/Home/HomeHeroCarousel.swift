import SwiftUI

/// Auto-rotating hero carousel for the Home screen — 3 cards (promo · donation · vet tip),
/// 4-second auto-advance, swipe-to-navigate override, and dot pagination.
/// The pager sizes itself to the tallest card so no card's content is ever clipped.
struct HomeHeroCarousel: View {
    var donationTitle: String?
    var onFindPet: () -> Void
    var onPetCare: () -> Void
    var onDonate: () -> Void
    var onVetTips: () -> Void

    @State private var selection = 0
    @State private var timer: Timer?
    @State private var pageHeight: CGFloat = 200
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let interval: TimeInterval = 4

    private var cards: [(fill: Color, body: AnyView)] {
        [
            (Theme.surfaceInverse, AnyView(promoBody)),
            (Theme.coral, AnyView(donationBody)),
            (Theme.surface, AnyView(vetTipBody)),
        ]
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                heightSizer          // invisible; drives `pageHeight` from the tallest card
                TabView(selection: $selection) {
                    ForEach(cards.indices, id: \.self) { i in
                        visibleCard(i).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: pageHeight)
            }
            dots
        }
        .onPreferenceChange(CarouselHeightKey.self) { h in
            if h > 0 { pageHeight = h }
        }
        .onAppear { restartTimer() }
        .onDisappear { timer?.invalidate() }
        // A swipe (or auto-advance) resets the 4s window, so manual navigation overrides rotation.
        .onChange(of: selection) { _ in restartTimer() }
    }

    // MARK: - Cards

    private func visibleCard(_ i: Int) -> some View {
        cards[i].body
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous).fill(cards[i].fill))
            .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
            .padding(.horizontal, ScreenLayout.horizontalPadding)
    }

    /// Lays the three card bodies on top of each other at their natural height and reports the
    /// tallest, so the pager can be sized to fit every card without clipping.
    private var heightSizer: some View {
        ZStack {
            ForEach(cards.indices, id: \.self) { i in
                cards[i].body
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, ScreenLayout.horizontalPadding)
        .background(GeometryReader { proxy in
            Color.clear.preference(key: CarouselHeightKey.self, value: proxy.size.height)
        })
        .hidden()
    }

    // MARK: - Auto-advance

    private func restartTimer() {
        timer?.invalidate()
        guard !reduceMotion else { return }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            withAnimation(Motion.spring) {
                selection = (selection + 1) % cards.count
            }
        }
    }

    // MARK: - Pagination dots

    private var dots: some View {
        HStack(spacing: 7) {
            ForEach(cards.indices, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index == selection ? Theme.coral : Theme.borderStrong.opacity(0.5))
                    .frame(width: index == selection ? 22 : 7, height: 7)
                    .animation(Motion.spring, value: selection)
                    .onTapGesture {
                        Haptic.selection()
                        withAnimation(Motion.spring) { selection = index }
                    }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Card \(selection + 1) of \(cards.count)")
    }

    // MARK: - Card 1 · promo

    private var promoBody: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(L10n.homeHeroTitle)
                .font(Theme.Fonts.display(Typography.title2))
                .tracking(-0.4)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text(L10n.homeHeroDesc)
                .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                .foregroundStyle(PetPalsPalette.forest200)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.sm)
            HStack(spacing: Spacing.xs) {
                PrimaryButton(title: L10n.findAPet, style: .accent, action: onFindPet)
                SecondaryButton(title: L10n.petCare, action: onPetCare)
            }
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.white.opacity(0.08))
                .rotationEffect(.degrees(-16))
        }
    }

    // MARK: - Card 2 · donation CTA

    private var donationBody: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            PPBadge(text: "Give back", tone: .neutral, icon: "heart.fill")
                .environment(\.colorScheme, .light)
            Text(donationTitle ?? "Help a shelter pet find a home")
                .font(Theme.Fonts.display(Typography.title2))
                .tracking(-0.4)
                .foregroundStyle(Theme.onAccent)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text("Your gift covers food, vaccines and a warm bed at the local animal shelter.")
                .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                .foregroundStyle(Theme.onAccent.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.sm)
            Button(action: { Haptic.medium(); onDonate() }) {
                HStack(spacing: Spacing.xs) {
                    Text("Donate now")
                    Image(systemName: "arrow.right")
                }
                .font(Theme.Fonts.headline(Typography.callout, weight: .heavy))
                .foregroundStyle(Theme.coralDeep)
                .padding(.horizontal, Spacing.md)
                .frame(height: 46)
                .background(Capsule().fill(.white))
            }
            .buttonStyle(MagneticPressStyle())
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: "heart.fill")
                .font(.system(size: 58))
                .foregroundStyle(Color.white.opacity(0.16))
                .rotationEffect(.degrees(12))
        }
    }

    // MARK: - Card 3 · Vet Tips of the Week

    private var vetTipBody: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                PPIconTile(icon: "stethoscope", tint: Theme.statusInfo, background: Theme.statusInfoSoft, size: 38)
                VStack(alignment: .leading, spacing: 1) {
                    Text("VET TIPS OF THE WEEK")
                        .font(Theme.Fonts.label(Typography.micro, weight: .heavy))
                        .tracking(1.0)
                        .foregroundStyle(Theme.textFaint)
                    Text(Self.vetTip.headline)
                        .font(Theme.Fonts.display(Typography.title3))
                        .tracking(-0.3)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                }
            }
            Text(Self.vetTip.body)
                .font(Theme.Fonts.body(Typography.caption, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.sm)
            Button(action: { Haptic.light(); onVetTips() }) {
                HStack(spacing: 6) {
                    Text("Learn more")
                    Image(systemName: "chevron.right")
                }
                .font(Theme.Fonts.label(Typography.caption, weight: .heavy))
                .foregroundStyle(PetPalsPalette.forest500)
            }
        }
    }

    // MARK: - Tip of the week (rotates by ISO week)

    private struct VetTip { let headline: String; let body: String }

    private static let tips: [VetTip] = [
        VetTip(headline: "Fresh water daily", body: "Refresh your pal's water bowl every day and wash it weekly — clean water keeps kidneys and gums healthy."),
        VetTip(headline: "Dental health", body: "Brush your dog or cat's teeth a few times a week to prevent tartar, bad breath and costly dental disease."),
        VetTip(headline: "Watch the weight", body: "A trim waistline where you can feel the ribs adds years — ask your vet about ideal body condition."),
        VetTip(headline: "Parasite season", body: "Stay on top of flea, tick and heartworm prevention year-round, not just in summer."),
        VetTip(headline: "Paw checks", body: "After walks, check paws for cracks, cuts or foreign objects — and avoid hot pavement in heat."),
    ]

    private static var vetTip: VetTip {
        let week = Calendar.current.component(.weekOfYear, from: Date())
        return tips[week % tips.count]
    }
}

// MARK: - Tallest-card height preference

private struct CarouselHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
