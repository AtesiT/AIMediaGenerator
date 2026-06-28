import SwiftUI
import Combine

final class VideoResultViewModel: ObservableObject {

    let resultData: VideoResultData

    @Published var showSavedToast: Bool = false
    @Published var isPlaying: Bool = false
    @Published var isDownloading: Bool = false

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

        // Сохраняем в историю
        let entry = VideoHistoryEntry(
            templateTitle: resultData.context.template.title,
            format: resultData.context.format,
            quality: resultData.context.quality,
            date: Date(),
            previewImage: resultData.previewImage
        )
        StorageService.shared.saveVideoResult(entry)

        // Скачиваем
        if let videoUrlString = resultData.videoUrl,
           let videoUrl = URL(string: videoUrlString) {
            downloadVideo(from: videoUrl)
        } else {
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
