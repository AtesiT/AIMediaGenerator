import SwiftUI
import Photos
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
                // Скачиваем файл
                let (tempUrl, _) = try await URLSession.shared.download(from: url)
                
                // Копируем во временную директорию с постоянным путём
                let fileManager = FileManager.default
                let documentsPath = fileManager.temporaryDirectory
                let destinationUrl = documentsPath.appendingPathComponent("temp_video.mp4")
                
                // Удаляем старый файл если есть
                try? fileManager.removeItem(at: destinationUrl)
                
                // Копируем
                try fileManager.copyItem(at: tempUrl, to: destinationUrl)
                
                // Запрашиваем доступ к галерее
                let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                
                guard status == .authorized || status == .limited else {
                    await MainActor.run {
                        isDownloading = false
                        print("❌ Photo library access denied")
                    }
                    return
                }

                // Сохраняем в галерею
                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(
                        atFileURL: destinationUrl
                    )
                }

                // Удаляем временный файл
                try? fileManager.removeItem(at: destinationUrl)

                await MainActor.run {
                    isDownloading = false
                    showToast()
                    print("✅ Video saved to gallery")
                }

            } catch {
                await MainActor.run {
                    isDownloading = false
                    print("❌ Download error: \(error.localizedDescription)")
                    // Fallback — сохраняем превью
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
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Delay.toastDuration) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.showSavedToast = false
            }
        }
    }
}
