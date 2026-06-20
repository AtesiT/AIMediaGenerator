import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PaywallViewModel()
    
    var body: some View {
        ZStack {
            //  TODO: Не забыть принудительно темную тему для пользователя включить вместо Color.black
            Color.black.ignoresSafeArea()
            
            //  TODO: Позже поставить настоящий градиент
            RadialGradient(
                colors: [Color.purple.opacity(0.23), Color.clear],
                center: .top,
                startRadius: 10,
                endRadius: 420
            )
            .ignoresSafeArea()
            
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    // Верхний бар с крестиком
                    HStack {
                        if viewModel.showCloseButton {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.35))
                                    .padding(.leading, 16)
                            }
                            .transition(.opacity)
                        }
                        Spacer()
                    }
                    .frame(height: 24)
                    .padding(.top, 16)
                    
                    //  Закголовок
                    VStack(spacing: 0) {
                        Text("Create anything\nyou want")
                            .font(.custom("Inter-Bold", size: 34))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        //  Строчки
                        VStack(alignment: .leading, spacing: 21) { // 21px разница между самими строчками
                            GradientFeatureRow(iconName: "Icons/icon/Generate B-1", text: "Get results in seconds", gradient: viewModel.brandGradient)
                            GradientFeatureRow(iconName: "Icons/icon/Magic pencil A", text: "Turn any text into better writing", gradient: viewModel.brandGradient)
                            GradientFeatureRow(iconName: "Icons/icon/prompt A", text: "Simplify complex information", gradient: viewModel.brandGradient)
                            GradientFeatureRow(iconName: "Icons/icon/Image to image", text: "Create content with AI templates", gradient: viewModel.brandGradient)
                        }
                        .padding(.horizontal, 53)
                        .padding(.top, 32)
                        
                        Spacer(minLength: 0)
                        
                        //  Подписки
                        VStack(spacing: 12) {
                            SubscriptionOptionView(
                                title: "Year $1.27 / week",
                                subtitle: "$ 69.99",
                                badge: "SAVE 80%",
                                isSelected: viewModel.isYearlySelected,
                                gradient: viewModel.brandGradient
                            )
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.15)) { viewModel.isYearlySelected = true }
                            }
                            
                            SubscriptionOptionView(
                                title: "Month $1.99 / week",
                                subtitle: "$ 7.99",
                                badge: nil,
                                isSelected: !viewModel.isYearlySelected,
                                gradient: viewModel.brandGradient
                            )
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.15)) { viewModel.isYearlySelected = false }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 107)
                }
                
                //  BottomBar
                Color.clear.frame(height: 16)
                
                VStack(spacing: 0) {
                    //  Cancel Anytime
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.clockwise.circle")
                        Text("Cancel Anytime")
                    }
                    .font(.custom("Inter-Medium", size: 12)) // Cancel - 12px
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 14)
                    
                    //  Unlock now
                    Button(action: {
                        viewModel.handleUnlock { dismiss() }
                    }) {
                        Text("Unlock now")
                            .font(.custom("Inter-SemiBold", size: 16)) // Unlock now - 16px semi bold
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(viewModel.brandGradient)
                            .cornerRadius(27)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                    //  3 текста маленьких
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Text("Restore Purchases")
                        Spacer()
                        Text("Terms of Use")
                    }
                    .font(.custom("Inter-Regular", size: 11)) // Нижние 3 - 11px
                    .foregroundColor(.white.opacity(0.35))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }
                .padding(.bottom, 12)
            }
        }
        .onAppear {
            viewModel.startTimer()
        }
    }
}

#Preview {
    PaywallView()
}

//  MARK: - GradientFeatureRow (строчки, get results и прочее)
struct GradientFeatureRow: View {
    let iconName: String
    let text: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: 21) {
            gradient
                .mask(
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                )
                .frame(width: 22, height: 22)
            
            Text(text)
                .font(.custom("Inter-Medium", size: 16)) // У строчек medium 16
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

struct SubscriptionOptionView: View {
    let title: String
    let subtitle: String
    let badge: String?
    let isSelected: Bool
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Inter-SemiBold", size: 15))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer(minLength: 0)
            
            if let badgeText = badge {
                Text(badgeText)
                    .font(.custom("Inter-Bold", size: 11))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(gradient)
                    .cornerRadius(10)
                    .padding(.leading, 8)
                    .padding(.trailing, 16)
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, badge == nil ? 16 : 0)
        .frame(height: 68)
        .background(Color.white.opacity(0.04))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    isSelected ? gradient : LinearGradient(colors: [Color.white.opacity(0.08)], startPoint: .top, endPoint: .bottom),
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
    }
}
