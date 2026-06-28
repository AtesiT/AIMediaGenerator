import SwiftUI

enum Theme {
    
    // MARK: - Gradients
    
    static let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let brandGradientDiagonal = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let brandGradientVertical = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Colors 
    
    /// #FFFFFF — основной текст
    static let accent = Color.white
    
    /// #0B070E — фон приложения
    static let background = Color(red: 11/255, green: 7/255, blue: 14/255)
    
    /// #1F191F — фон карточек
    static let card = Color(red: 31/255, green: 25/255, blue: 31/255)
    
    // MARK: - Производные цвета
    
    static let navBarBackground = Color(red: 0.07, green: 0.05, blue: 0.08)
    static let cardBackground = accent.opacity(0.04)
    static let inputBackground = Color(red: 0.1, green: 0.08, blue: 0.12).opacity(0.5)
    static let overlayBackground = card.opacity(0.50)
    static let divider = accent.opacity(0.05)
    static let placeholder = accent.opacity(0.2)
    static let secondaryText = accent.opacity(0.4)
    static let tertiaryText = accent.opacity(0.3)
    
    // MARK: - Fonts
    
    // Bold
    static func bold(_ size: CGFloat) -> Font {
        .custom("Inter-Bold", size: size)
    }
    
    // Semi Bold
    static func semiBold(_ size: CGFloat) -> Font {
        .custom("Inter-SemiBold", size: size)
    }
    
    // Medium
    static func medium(_ size: CGFloat) -> Font {
        .custom("Inter-Medium", size: size)
    }
    
    // Regular
    static func regular(_ size: CGFloat) -> Font {
        .custom("Inter-Regular", size: size)
    }
    
    // MARK: - Font Sizes
    
    enum FontSize {
        // Bold
        static let bold28: CGFloat = 28
        static let bold34: CGFloat = 34
        
        // SemiBold
        static let semiBold14: CGFloat = 14
        static let semiBold16: CGFloat = 16
        static let semiBold20: CGFloat = 20
        
        // Medium
        static let medium12: CGFloat = 12
        static let medium16: CGFloat = 16
        static let medium20: CGFloat = 20
        
        // Regular
        static let regular14: CGFloat = 14
        static let regular16: CGFloat = 16
        static let regular20: CGFloat = 20
    }
}
