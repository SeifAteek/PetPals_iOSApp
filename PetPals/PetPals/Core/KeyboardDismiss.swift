import SwiftUI
import UIKit
import Combine

// MARK: - Keyboard utilities

enum Keyboard {
    static func dismiss() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

/// Tracks keyboard visibility so tab-bar bottom inset can be removed while typing (prevents gap above keyboard).
@MainActor
final class KeyboardObserver: ObservableObject {
    @Published private(set) var isVisible = false
    @Published private(set) var height: CGFloat = 0

    init() {
        let center = NotificationCenter.default
        center.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.apply(note: note, visible: true)
        }
        center.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isVisible = false
            self?.height = 0
        }
    }

    private func apply(note: Notification, visible: Bool) {
        isVisible = visible
        if let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            height = frame.height
        }
    }
}

// MARK: - View modifiers

extension View {
    /// Swipe down on scroll content to dismiss the keyboard (iOS 16+).
    func dismissKeyboardOnSwipe() -> some View {
        scrollDismissesKeyboard(.interactively)
    }

    /// Tap empty space to dismiss (does not steal taps from buttons).
    func dismissKeyboardOnTap() -> some View {
        background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { Keyboard.dismiss() }
        )
    }

    /// Single Done button on the keyboard (use once per screen — not on every field).
    func keyboardDoneToolbar() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(L10n.done) {
                    Keyboard.dismiss()
                }
                .font(Theme.Fonts.headline(Typography.callout, weight: .semibold))
                .foregroundStyle(Theme.primary)
            }
        }
    }

    /// Bottom inset for the floating tab bar — omitted while the keyboard is visible.
    func tabBarScrollInset(keyboard: KeyboardObserver) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            if !keyboard.isVisible {
                Color.clear.frame(height: ScreenLayout.tabBarScrollInset)
            }
        }
    }
}

/// Enables interactive keyboard dismiss on all `UIScrollView`s (forms, lists, chat history).
enum ScrollKeyboardConfig {
    static func applyGlobalInteractiveDismiss() {
        UIScrollView.appearance().keyboardDismissMode = .interactive
    }
}
