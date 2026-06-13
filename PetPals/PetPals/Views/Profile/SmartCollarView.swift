import SwiftUI

struct SmartCollarView: View {
    @StateObject var viewModel: PetMedicalViewModel

    private var isConnected: Bool { viewModel.collar != nil }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.md) {
                collarHeroCard

                if let collar = viewModel.collar {
                    connectedDetails(collar)
                } else {
                    emptyState
                }

                if viewModel.simulatedNFCSuccess {
                    statusBanner(
                        icon: "checkmark.circle.fill",
                        text: "Successfully synced",
                        tone: .healthy
                    )
                    .transition(.scale.combined(with: .opacity))
                }

                if let error = viewModel.errorMessage {
                    statusBanner(icon: "exclamationmark.triangle.fill", text: error, tone: .critical)
                }

                PrimaryButton(
                    title: isConnected ? "Sync now" : "Link collar",
                    icon: isConnected ? "arrow.triangle.2.circlepath" : "wave.3.right",
                    isLoading: viewModel.isSyncingCollar
                ) {
                    viewModel.simulateNFCSync()
                }
                .padding(.top, Spacing.xs)
            }
            .padding(ScreenLayout.horizontalPadding)
            .animation(Motion.spring, value: viewModel.simulatedNFCSuccess)
            .animation(Motion.spring, value: isConnected)
        }
        .clawsyScreenBackground()
        .navigationTitle("Smart collar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.collar == nil {
                viewModel.loadData()
            }
        }
    }

    // MARK: - Hero card (inverse forest surface + living heartbeat)

    private var collarHeroCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                PPIconTile(
                    icon: "antenna.radiowaves.left.and.right",
                    tint: .white,
                    background: Color.white.opacity(0.14),
                    size: 46,
                    iconSize: 20
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Smart collar")
                        .font(Theme.Fonts.display(Typography.title3))
                        .tracking(-0.3)
                        .foregroundStyle(.white)
                    Text(statusLine)
                        .font(Theme.Fonts.body(Typography.caption, weight: .bold))
                        .foregroundStyle(isConnected ? PetPalsPalette.forest200 : Color.white.opacity(0.6))
                }
                Spacer()
                connectionDot
            }

            HeartbeatView(
                color: isConnected ? Theme.coral : Color.white.opacity(0.35),
                bpm: 76,
                height: 52,
                active: isConnected
            )
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(Theme.surfaceInverse)
        }
    }

    private var connectionDot: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isConnected ? Theme.statusHealthy : Color.white.opacity(0.4))
                .frame(width: 8, height: 8)
            Text(isConnected ? "Live" : "Offline")
                .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                .foregroundStyle(isConnected ? PetPalsPalette.forest200 : Color.white.opacity(0.6))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.white.opacity(0.12)))
    }

    private var statusLine: String {
        guard let collar = viewModel.collar else { return "Not linked yet" }
        if let lastSync = collar.lastSyncTime {
            return "Connected · synced \(lastSync.formatted(.relative(presentation: .named)))"
        }
        return "Connected"
    }

    // MARK: - Connected details

    @ViewBuilder
    private func connectedDetails(_ collar: SmartCollar) -> some View {
        VStack(spacing: Spacing.xs) {
            detailRow(icon: "number", label: "Serial number", value: collar.serialNumber)
            if let lastSync = collar.lastSyncTime {
                detailRow(
                    icon: "clock.arrow.circlepath",
                    label: "Last sync",
                    value: lastSync.formatted(date: .abbreviated, time: .shortened)
                )
            }
        }
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: Spacing.sm) {
            PPIconTile(icon: icon, tint: Theme.forest, background: Theme.forestSoft, size: 42)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(Theme.Fonts.label(Typography.micro, weight: .bold))
                    .foregroundStyle(Theme.textFaint)
                    .tracking(0.6)
                Text(value)
                    .font(Theme.Fonts.headline(Typography.callout, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: Radius.lg, elevation: .resting)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Text("No collar linked yet")
                .font(Theme.Fonts.headline(Typography.body, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
            Text("Hold an NTAG213 collar near your device to pair it and start tracking.")
                .font(Theme.Fonts.body(Typography.callout))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .glassCard(cornerRadius: Radius.lg, elevation: .resting)
    }

    private func statusBanner(icon: String, text: String, tone: PPBadgeTone) -> some View {
        let colors = tone.soft
        return HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
            Text(text)
                .font(Theme.Fonts.body(Typography.caption, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundStyle(colors.foreground)
        .padding(Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(colors.background)
        }
    }
}
