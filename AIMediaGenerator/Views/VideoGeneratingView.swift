import SwiftUI

struct VideoGeneratingView: View {
    @Environment(\.dismiss) var dismiss

    let context: VideoGenerationContext
    @Binding var navigationPath: [VideoNavDestination]

    @StateObject private var viewModel: VideoGeneratingViewModel

    init(context: VideoGenerationContext, navigationPath: Binding<[VideoNavDestination]>) {
        self.context = context
        self._navigationPath = navigationPath
        self._viewModel = StateObject(
            wrappedValue: VideoGeneratingViewModel(context: context)
        )
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Кнопка назад
                HStack {
                    Button(action: { dismiss() }) {
                        Image("Icons/arrow")
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    Spacer()
                }
                .frame(height: 56)

                Spacer()

                // Фоновая картинка + шар поверх
                ZStack {
                    // Фоновая картинка из Assets
                    Image("image 4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 316, height: 444)
                        .cornerRadius(20)

                    // Анимированный шар поверх картинки
                    orbView
                        .frame(width: 300, height: 300)
                }

                // Тексты
                VStack(spacing: 10) {
                    Text("Generating...")
                        .font(.custom("Inter-Bold", size: 22))
                        .foregroundColor(.white)

                    Text("We're creating the best result for you")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)

                Spacer()
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startAnimations()
            viewModel.simulateGeneration {
                navigationPath.append(.result(context))
            }
        }
    }

    // MARK: - Orb

    private var orbView: some View {
        ZStack {
            // Внешнее свечение
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.80, green: 0.60, blue: 0.85).opacity(0.25),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 90,
                        endRadius: 170
                    )
                )
                .scaleEffect(viewModel.isPulsing ? 1.18 : 0.92)

            // Основной шар
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.96, green: 0.90, blue: 0.96),
                            Color(red: 0.78, green: 0.62, blue: 0.80),
                            Color(red: 0.58, green: 0.42, blue: 0.62),
                            Color(red: 0.28, green: 0.18, blue: 0.32)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.28),
                        startRadius: 8,
                        endRadius: 140
                    )
                )
                .frame(width: 250, height: 250)
                .scaleEffect(viewModel.isPulsing ? 1.05 : 0.96)
                .overlay(
                    // Блик
                    Ellipse()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.55), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: 110, height: 65)
                        .offset(x: -35, y: -75)
                        .rotationEffect(
                            .degrees(viewModel.isRotating ? 360 : 0)
                        )
                )
                .shadow(
                    color: Color(red: 0.68, green: 0.48, blue: 0.78).opacity(0.55),
                    radius: 35
                )
        }
    }
}

#Preview {
    VideoGeneratingView(
        context: VideoGenerationContext(
            template: VideoTemplate(
                title: "Clay Fool",
                category: "Popular",
                photoCount: 1,
                previewColor: .purple
            ),
            photos: [],
            format: "16:9",
            quality: "1080p"
        ),
        navigationPath: .constant([])
    )
}
