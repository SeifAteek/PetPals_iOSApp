import SwiftUI

enum Theme {
    static let primary = Color(red: 79/255, green: 70/255, blue: 229/255) // #4F46E5
    static let accent = Color(red: 78/255, green: 205/255, blue: 196/255) // #4ECDC4
    
    static let secondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? 
        UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1) : 
        UIColor(red: 255/255, green: 245/255, blue: 235/255, alpha: 1)
    })
    
    static let background = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? 
        UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1) : 
        UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
    })
    
    static let cardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? 
        UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1) : 
        UIColor.white
    })
    
    static let textPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? 
        UIColor.white : 
        UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
    })
    
    static let textSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? 
        UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1) : 
        UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1)
    })
    
    struct Fonts {
        static func primaryFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            // Using system font for now, can be swapped to custom like Inter or Roboto later
            return Font.system(size: size, weight: weight, design: .default)
        }
    }
}

// Optional: Extension for easier use in views
extension ShapeStyle where Self == Color {
    static var themePrimary: Color { Theme.primary }
    static var themeSecondary: Color { Theme.secondary }
    static var themeBackground: Color { Theme.background }
    static var themeAccent: Color { Theme.accent }
}
