import SwiftUI
import AudioToolbox

struct RadarView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    let assignedUUID: String?
    
    init(bluetoothManager: BluetoothManager, assignedUUID: String? = nil) {
        self.bluetoothManager = bluetoothManager
        self.assignedUUID = assignedUUID
    }
    @State private var isAnimating = false
    @State private var lastHapticTime = Date()
    @State private var hasTriggeredSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.85).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Text("Pet Radar")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Radar Animation Container
                ZStack {
                    // Rings
                    ZStack {
                        ForEach(0..<4) { index in
                            Circle()
                                .stroke(ringColor.opacity(0.8), lineWidth: 2)
                                .frame(width: 100, height: 100)
                                .scaleEffect(isAnimating ? 3.5 : 1.0)
                                .opacity(isAnimating ? 0.0 : 1.0)
                                .animation(
                                    .easeOut(duration: animationDuration)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(index) * (animationDuration / 4.0)),
                                    value: isAnimating
                                )
                        }
                    }
                    .id(speedCategory) // Recreate rings when speed category changes significantly
                    .onChange(of: speedCategory) { _ in
                        // Reset and restart animation to ensure the new views animate properly
                        isAnimating = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isAnimating = true
                        }
                    }
                    
                    // Center Pet Icon
                    ZStack {
                        Circle()
                            .fill(ringColor.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .background(
                                .regularMaterial,
                                in: Circle()
                            )
                            .shadow(color: ringColor.opacity(0.5), radius: 10, x: 0, y: 0)
                            
                        Image(systemName: "pawprint.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 350, height: 350)
                
                Spacer()
                
                // Status Text
                VStack(spacing: 12) {
                    Text(bluetoothManager.distanceText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            .regularMaterial,
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                        .environment(\.colorScheme, .dark) // Force dark mode for glass effect
                    
                    if bluetoothManager.connectionState == .disconnected {
                        Text("Please enable Bluetooth or wait for connection...")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
            }
            .padding()
            
            // Proximity Alert Overlay
            if bluetoothManager.isVeryClose {
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Pet is within 1 meter!")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.red.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 5)
                    .padding(.top, 50)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
                .zIndex(1)
            }
        }
        .animation(.spring(), value: bluetoothManager.isVeryClose)
        .onAppear {
            // No need to start radar, BluetoothManager is already running from ProfileView
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
        .onChange(of: bluetoothManager.signalStrength) { newStrength in
            // Handle vibrations
            let now = Date()
            let hapticInterval = 1.5 - (newStrength * 1.4) // From 1.5s down to 0.1s
            
            if now.timeIntervalSince(lastHapticTime) > hapticInterval && newStrength > 0 {
                lastHapticTime = now
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                AudioServicesPlaySystemSound(1103) // System sound "Glass" (sharp ping)
            }
            
            // Handle success alert haptic
            if bluetoothManager.isVeryClose && !hasTriggeredSuccess {
                hasTriggeredSuccess = true
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else if !bluetoothManager.isVeryClose {
                hasTriggeredSuccess = false
            }
        }
    }
    
    // MARK: - Dynamic Properties based on signal strength
    
    private var ringColor: Color {
        let strength = bluetoothManager.signalStrength
        if strength == 0.0 {
            return .gray // Searching
        }
        // Hue 0.65 is blue, 0.0 is red.
        // As strength goes from 0 to 1, hue goes from 0.65 to 0.0
        let hue = 0.65 * (1.0 - strength)
        return Color(hue: hue, saturation: 0.9, brightness: 0.9)
    }
    
    private var animationDuration: Double {
        let strength = bluetoothManager.signalStrength
        // Fast pulse (1.0s) when strong, slow pulse (3.0s) when weak
        if strength > 0.0 {
            return 3.0 - (strength * 2.0)
        } else {
            return 3.0 // Default searching speed
        }
    }
    
    private var speedCategory: Int {
        let strength = bluetoothManager.signalStrength
        if strength >= 0.6 { return 1 } // Fast
        else if strength >= 0.3 { return 2 } // Medium
        else if strength > 0.0 { return 3 } // Slow
        else { return 4 } // Searching
    }
}

struct RadarView_Previews: PreviewProvider {
    static var previews: some View {
        RadarView(bluetoothManager: BluetoothManager())
    }
}
