import Foundation
import CoreGraphics

enum Constants {
    
    // MARK: - Animation Durations
    
    enum Animation {
        static let fast: Double = 0.15
        static let normal: Double = 0.2
        static let slow: Double = 0.3
        static let spring: Double = 0.4
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let standard: CGFloat = 16
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
    }
    
    // MARK: - UI Sizes
    
    enum UI {
        static let navBarHeight: CGFloat = 56
        static let buttonHeight: CGFloat = 54
        static let cornerRadius: CGFloat = 27
        static let cardCornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 14
        
        // Photo picker
        static let photoGridColumns: Int = 3
        static let photoGridSpacing: CGFloat = 2
        
        // Video generating
        static let orbImageWidth: CGFloat = 316
        static let orbImageHeight: CGFloat = 444
        static let orbFrameSize: CGFloat = 300
        
        // Icons
        static let smallIconSize: CGFloat = 20
        static let mediumIconSize: CGFloat = 36
    }
    
    // MARK: - Delays
    
    enum Delay {
        static let autofocus: Double = 0.5
        static let paywallCloseButton: Double = 2.0
        static let navigationReset: Double = 0.3
        static let toastDuration: Double = 2.5
    }
}
