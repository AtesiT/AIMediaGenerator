import SwiftUI

struct BrandButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(Theme.semiBold(16))
                    .foregroundColor(isEnabled ? .white : .white.opacity(0.3))
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                Group {
                    if isEnabled {
                        AnyView(Theme.brandGradient)
                    } else {
                        AnyView(Color.white.opacity(0.07))
                    }
                }
            )
            .cornerRadius(27)
        }
        .disabled(!isEnabled || isLoading)
    }
}
