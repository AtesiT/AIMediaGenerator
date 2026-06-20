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
                // Верхний бар с крестиком
                HStack {
                    if viewModel.showCloseButton {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.35))
                                .padding(16)
                        }
                        .transition(.opacity)
                    }
                    Spacer()
                }
                .frame(height: 44)
                
                Spacer()
                
                // Заголовок
                Text("Create anything\nyou want")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
                
                // Список преимуществ
                VStack(alignment: .leading, spacing: 20) {
                    GradientFeatureRow(iconName: "Icons/icon/Generate B-1", text: "Get results in seconds", gradient: viewModel.brandGradient)
                    GradientFeatureRow(iconName: "Icons/icon/Magic pencil A", text: "Turn any text into better writing", gradient: viewModel.brandGradient)
                    GradientFeatureRow(iconName: "Icons/icon/prompt A", text: "Simplify complex information", gradient: viewModel.brandGradient)
                    GradientFeatureRow(iconName: "Icons/icon/Image to image", text: "Create content with AI templates", gradient: viewModel.brandGradient)
                }
                .padding(.horizontal, 28)
                
                Spacer()
                
                //  Выбор тарифа
                VStack(spacing: 12) {
                    // Здесь на год
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
                    
                    // Здесь на месяц
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
                
                // Cancel anytime
                HStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise.circle")
                    Text("Cancel Anytime")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                
                Button(action: {
                    viewModel.handleUnlock { dismiss() }
                }) {
                    Text("Unlock now")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.brandGradient)
                        .cornerRadius(27)
                }
                .padding(.horizontal, 16)
                
                // Ссылки внизу
                //  TODO: Посмотреть, должны они вести или обычный текст
                HStack {
                    Text("Privacy Policy")
                    Spacer()
                    Text("Restore Purchases")
                    Spacer()
                    Text("Terms of Use")
                }
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.35))
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)
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
        HStack(spacing: 14) {
            gradient
                .mask(
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                )
                .frame(width: 22, height: 22)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            if let badgeText = badge {
                Text(badgeText)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(gradient)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isSelected ?
                    gradient :
                    LinearGradient(colors: [Color.white.opacity(0.08)], startPoint: .top, endPoint: .bottom),
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
    }
}
