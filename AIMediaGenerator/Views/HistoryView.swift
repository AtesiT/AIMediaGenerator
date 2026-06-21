import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    
    // Градиент для иконки карандаша
    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969), // #98C6F7
            Color(red: 0.922, green: 0.357, blue: 0.573)  // #EB5B92
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // NavBar
                HStack {
                    Button(action: { dismiss() }) {
                        Image("Icons/arrow")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    Text("AI Chat History")
                        .font(.custom("Inter-Bold", size: 17))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Заглушка, чтобы центрировать нормально (вместо spacer)
                    Color.clear
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 16)
                }
                .frame(height: 56)
                
                Spacer()
                
                // Центральный блок "No chats yet"
                VStack(spacing: 0) {
                    // Иконка карандаша
                    brandGradient
                        .mask(
                            Image("Icons/icon/Magic pencil A")
                                .resizable()
                                .scaledToFit()
                        )
                        .frame(width: 56, height: 56)
                        .padding(.bottom, 24)
                    
                    Text("No chats yet")
                        .font(.custom("Inter-Bold", size: 28))
                        .foregroundColor(.white)
                        .padding(.bottom, 12)
                    
                    Text("Start a conversation to see\nyour history here")
                        .font(.custom("Inter-Regular", size: 15))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                Spacer()
            }
        }
    }
}

#Preview {
    HistoryView()
}
