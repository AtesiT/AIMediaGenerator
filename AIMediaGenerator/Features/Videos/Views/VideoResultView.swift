import SwiftUI

struct VideoResultView: View {
    @Environment(\.dismiss) var dismiss

    let resultData: VideoResultData
    let onReplace: () -> Void

    @StateObject private var viewModel: VideoResultViewModel
    @State private var isPlaying = false

    init(
        resultData: VideoResultData,
        onReplace: @escaping () -> Void
    ) {
        self.resultData = resultData
        self.onReplace = onReplace
        self._viewModel = StateObject(
            wrappedValue: VideoResultViewModel(resultData: resultData)
        )
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                Spacer(minLength: 12)

                videoPreview
                    .padding(.horizontal, 16)

                Spacer()

                bottomButtons
                    .padding(.bottom, 36)
            }

            if viewModel.showSavedToast {
                savedToast
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - NavBar

    private var navBar: some View {
        NavBar(
            title: "Result",
            onLeadingTap: { dismiss() }
        )
    }
    
    // MARK: - Video Preview

    private var videoPreview: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = resultData.previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Color(red: 0.14, green: 0.10, blue: 0.18)
                        .frame(height: 460)
                }
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                Button(action: { viewModel.togglePlay() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.22))
                            .frame(width: 64, height: 64)
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .offset(x: isPlaying ? 0 : 2)
                    }
                }
            )

            // Replace
            Button(action: {
                onReplace()
            }) {
                HStack(spacing: 6) {
                    Image("Icons/vuesax/linear/refresh-2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.white.opacity(0.85))
                    Text("Replace")
                        .font(.custom("Inter-Medium", size: 13))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.18))
                .cornerRadius(20)
            }
            .padding(.top, 12)
            .padding(.trailing, 12)
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        GeometryReader { geo in
            let totalSpacing: CGFloat = 16 + 16 + 12
            let buttonWidth = (geo.size.width - totalSpacing) / 2

            HStack(spacing: 12) {
                Button(action: { shareContent() }) {
                    Text("Share")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .frame(width: buttonWidth, height: 54)
                        .background(
                            Color(
                                red: 0x1F / 255.0,
                                green: 0x19 / 255.0,
                                blue: 0x1F / 255.0
                            ).opacity(0.50)
                        )
                        .cornerRadius(27)
                }

                Button(action: { viewModel.download() }) {
                    ZStack {
                        Text("Download")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .opacity(viewModel.isDownloading ? 0 : 1)

                        if viewModel.isDownloading {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: .white)
                                )
                        }
                    }
                    .frame(width: buttonWidth, height: 54)
                    .background(Theme.brandGradient)
                    .cornerRadius(27)
                }
                .disabled(viewModel.isDownloading)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 54)
        .padding(.bottom, 36)
    }

    // MARK: - Share

    private func shareContent() {
        let items: [Any]
        if let image = resultData.previewImage {
            items = [image]
        } else {
            items = ["Check out my AI generated video!"]
        }

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let rootVC = windowScene.windows
                .first(where: { $0.isKeyWindow })?
                .rootViewController
        else { return }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(
                x: topVC.view.bounds.midX,
                y: topVC.view.bounds.maxY - 100,
                width: 0,
                height: 0
            )
        }

        topVC.present(activityVC, animated: true)
    }

    // MARK: - Toast

    private var savedToast: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 14) {
                Theme.brandGradient
                    .mask(
                        Image("Icons/check")
                            .resizable()
                            .scaledToFit()
                    )
                    .frame(width: 30, height: 30)

                Text("Video has been saved\nto your gallery")
                    .font(.custom("Inter-SemiBold", size: 15))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        Color(
                            red: 0x1F / 255.0,
                            green: 0x19 / 255.0,
                            blue: 0x1F / 255.0
                        ).opacity(0.60)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 24)
            )
            .padding(.horizontal, 52)
        }
    }
}

//#Preview {
//    VideoResultView(
//        context: VideoGenerationContext(
//            template: VideoTemplate(
//                title: "Clay Fool",
//                category: "Popular",
//                photoCount: 1,
//                previewColor: .purple
//            ),
//            photos: [],
//            format: "16:9",
//            quality: "1080p"
//        ),
//        navigationPath: .constant([])
//    )
//}
