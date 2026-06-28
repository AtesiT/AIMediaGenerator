import SwiftUI

struct NavBar: View {
    let title: String
    let leadingIcon: String?
    let trailingIcon: String?
    let onLeadingTap: (() -> Void)?
    let onTrailingTap: (() -> Void)?
    
    init(
        title: String,
        leadingIcon: String? = "Icons/arrow",
        trailingIcon: String? = nil,
        onLeadingTap: (() -> Void)? = nil,
        onTrailingTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.onLeadingTap = onLeadingTap
        self.onTrailingTap = onTrailingTap
    }
    
    var body: some View {
        HStack {
            // Leading button
            if let icon = leadingIcon, let action = onLeadingTap {
                Button(action: action) {
                    Image(icon)
                        .foregroundColor(.white)
                }
                .padding(.leading, 16)
            } else if leadingIcon != nil {
                Color.clear
                    .frame(width: 20, height: 20)
                    .padding(.leading, 16)
            }
            
            Spacer()
            
            // Title
            Text(title)
                .font(Theme.semiBold(20))
                .foregroundColor(.white)
            
            Spacer()
            
            // Trailing button
            if let icon = trailingIcon, let action = onTrailingTap {
                Button(action: action) {
                    Image(icon)
                        .foregroundColor(.white)
                }
                .padding(.trailing, 16)
            } else {
                Color.clear
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 56)
    }
}
