import SwiftUI

struct VideoGeneratingView: View {
    @Environment(\.dismiss) var dismiss

    let context: VideoGenerationContext
    let onComplete: (VideoResultData) -> Void
    let onCancel: () -> Void

    @StateObject private var viewModel: VideoGeneratingViewModel

    init(
        context: VideoGenerationContext,
        onComplete: @escaping (VideoResultData) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.context = context
        self.onComplete = onComplete
        self.onCancel = onCancel
        self._viewModel = StateObject(
            wrappedValue: VideoGeneratingViewModel(context: context)
        )
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        viewModel.cancelGeneration()
                        onCancel()
                    }) {
                        Image("Icons/arrow").foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    Spacer()
                }
                .frame(height: 56)

                Spacer()

                ZStack {
                    Image("image 4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 316, height: 444)
                        .cornerRadius(20)
                    orbView.frame(width: 300, height: 300)
                }

                VStack(spacing: 10) {
                    Text("Generating...")
                        .font(.custom("Inter-Bold", size: 22))
                        .foregroundColor(.white)
                    Text(viewModel.statusText)
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .animation(.easeOut(duration: 0.3), value: viewModel.statusText)
                }
                .padding(.top, 32)

                Spacer()
                Spacer()
            }

            if case .failed(let message) = viewModel.state {
                errorOverlay(message: message)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startAnimations()
            viewModel.startGeneration()
        }
        .onChange(of: viewModel.state) { newState in
            if case .completed(let resultData) = newState {
                onComplete(resultData)
            }
        }
    }

    // orb и errorOverlay остаются без изменений
    private func errorOverlay(message: String) -> some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.6))
                Text("Generation failed")
                    .font(.custom("Inter-Bold", size: 20))
                    .foregroundColor(.white)
                Text(message)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                HStack(spacing: 12) {
                    Button(action: { onCancel() }) {
                        Text("Go back")
                            .font(.custom("Inter-SemiBold", size: 15))
                            .foregroundColor(.white)
                            .frame(width: 130, height: 48)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(24)
                    }
                    Button(action: { viewModel.startGeneration() }) {
                        Text("Try again")
                            .font(.custom("Inter-SemiBold", size: 15))
                            .foregroundColor(.white)
                            .frame(width: 130, height: 48)
                            .background(viewModel.brandGradient)
                            .cornerRadius(24)
                    }
                }
            }
            .padding(32)
        }
    }

    private var orbView: some View {
        ZStack {
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
                        .rotationEffect(.degrees(viewModel.isRotating ? 360 : 0))
                )
                .shadow(
                    color: Color(red: 0.68, green: 0.48, blue: 0.78).opacity(0.55),
                    radius: 35
                )
        }
    }
}
