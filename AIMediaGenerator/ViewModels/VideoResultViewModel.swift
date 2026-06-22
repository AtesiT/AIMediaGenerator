import SwiftUI
import Combine

final class VideoResultViewModel: ObservableObject {

    let resultData: VideoResultData

    @Published var showSavedToast: Bool = false
    @Published var isPlaying: Bool = false
    @Published var isDownloading: Bool = false

    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    init(resultData: VideoResultData) {
        self.resultData = resultData
    }

    func togglePlay() {
        withAnimation(.spring(response: 0.3)) {
            isPlaying.toggle()
        }
    }

    // MARK: - Download

    func download() {
        guard !isDownloading else { return }

        // Если есть URL видео — скачиваем реальное видео
        if let videoUrlString = resultData.videoUrl,
           let videoUrl = URL(string: videoUrlString) {
            downloadVideo(from: videoUrl)
        } else {
            // Fallback — сохраняем превью фото
            savePreviewImage()
        }
    }

    private func downloadVideo(from url: URL) {
        isDownloading = true

        Task {
            do {
                let (localUrl, _) = try await URLSession.shared.download(from: url)

                // Сохраняем в фото галерею
                await MainActor.run {
                    UISaveVideoAtPathToSavedPhotosAlbum(
                        localUrl.path,
                        nil, nil, nil
                    )
                    isDownloading = false
                    showToast()
                }
            } catch {
                // Fallback — сохраняем превью
                await MainActor.run {
                    isDownloading = false
                    savePreviewImage()
                }
            }
        }
    }

    private func savePreviewImage() {
        guard let image = resultData.previewImage else {
            showToast()
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast()
    }

    private func showToast() {
        withAnimation(.spring(response: 0.4)) {
            showSavedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.showSavedToast = false
            }
        }
    }
}
