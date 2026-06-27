import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PaywallViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GradientBackgroundView()
            
            VStack(spacing: 0) {
                // Крестик
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

                // Заголовок
                Text("Create anything\nyou want")
                    .font(.custom("Inter-Bold", size: 34))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 107)

                // Фичи
                VStack(alignment: .leading, spacing: 21) {
                    PaywallFeatureRow(
                        iconName: "Icons/icon/Generate B-1",
                        text: "Get results in seconds",
                        gradient: viewModel.brandGradient
                    )
                    PaywallFeatureRow(
                        iconName: "Icons/icon/Magic pencil A",
                        text: "Turn any text into better writing",
                        gradient: viewModel.brandGradient
                    )
                    PaywallFeatureRow(
                        iconName: "Icons/icon/prompt A",
                        text: "Simplify complex information",
                        gradient: viewModel.brandGradient
                    )
                    PaywallFeatureRow(
                        iconName: "Icons/icon/Image to image",
                        text: "Create content with AI templates",
                        gradient: viewModel.brandGradient
                    )
                }
                .padding(.horizontal, 53)
                .padding(.top, 32)

                Spacer(minLength: 0)

                // Подписки
                VStack(spacing: 12) {
                    PaywallOptionView(
                        title: "Year \(viewModel.yearlyWeeklyPriceText)",
                        subtitle: viewModel.yearlyPriceText,
                        badge: "SAVE 80%",
                        isSelected: viewModel.isYearlySelected,
                        gradient: viewModel.brandGradient
                    )
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) {
                            viewModel.isYearlySelected = true
                        }
                    }

                    PaywallOptionView(
                        title: "Month \(viewModel.monthlyWeeklyPriceText)",
                        subtitle: viewModel.monthlyPriceText,
                        badge: nil,
                        isSelected: !viewModel.isYearlySelected,
                        gradient: viewModel.brandGradient
                    )
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) {
                            viewModel.isYearlySelected = false
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)

                // Bottom
                VStack(spacing: 0) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.clockwise.circle")
                        Text("Cancel Anytime")
                    }
                    .font(.custom("Inter-Medium", size: 12))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                    // Unlock кнопка
                    Button(action: {
                        viewModel.handleUnlock { dismiss() }
                    }) {
                        ZStack {
                            Text("Unlock now")
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .opacity(viewModel.isLoading ? 0 : 1)

                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint: .white)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.brandGradient)
                        .cornerRadius(27)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    // Ссылки
                    HStack {
                        Button(action: { openPrivacyPolicy() }) {
                            Text("Privacy Policy")
                        }
                        Spacer()
                        Button(action: {
                            viewModel.restorePurchases { dismiss() }
                        }) {
                            Text("Restore Purchases")
                        }
                        Spacer()
                        Button(action: { openTermsOfUse() }) {
                            Text("Terms of Use")
                        }
                    }
                    .font(.custom("Inter-Regular", size: 11))
                    .foregroundColor(.white.opacity(0.35))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: "https://nebulaapps.site/privacy") {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfUse() {
        if let url = URL(string: "https://nebulaapps.site/terms") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - PaywallFeatureRow

struct PaywallFeatureRow: View {
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
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.white.opacity(0.9))

            Spacer()
        }
    }
}

// MARK: - PaywallOptionView

struct PaywallOptionView: View {
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
                    isSelected
                        ? gradient
                        : LinearGradient(
                            colors: [Color.white.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
    }
}

#Preview {
    PaywallView()
}
