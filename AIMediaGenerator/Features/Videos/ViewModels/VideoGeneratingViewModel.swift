import SwiftUI
import Combine

// MARK: - Состояние генерации

enum GeneratingState {
    case uploading   // Загружаем фото
    case generating// Ждём результат
    case completed(VideoResultData)
    case failed(String)
}

final class VideoGeneratingViewModel: ObservableObject {

    let context: VideoGenerationContext

    @Published var state: GeneratingState = .uploading
    @Published var statusText: String = "Uploading photo..."
    @Published var isPulsing: Bool = false
    @Published var isRotating: Bool = false

    private let videoService = VideoService.shared
    private var generationTask: Task<Void, Never>?

    init(context: VideoGenerationContext) {
        self.context = context
    }

    // MARK: - Анимации

    func startAnimations() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            isPulsing = true
        }
        withAnimation(
            .linear(duration: 9.0)
            .repeatForever(autoreverses: false)
        ) {
            isRotating = true
        }
    }

    // MARK: - Запуск генерации

    func startGeneration() {
        generationTask = Task {
            await performGeneration()
        }
    }

    // MARK: - Отмена

    func cancelGeneration() {
        generationTask?.cancel()
    }

    // MARK: - Основная логика генерации

    @MainActor
    private func performGeneration() async {
        guard let firstPhoto = context.photos.first else {
            state = .failed("No photo selected")
            return
        }

        do {
            // Шаг 1: Загружаем фото и запускаем генерацию
            await updateStatus("Uploading photo...")
            state = .uploading

            let videoId: String

            // Выбираем метод генерации:
            // Если у шаблона есть remoteId — используем template2video
            // Иначе — image2video
            if let templateId = context.template.remoteId {
                videoId = try await videoService.generateTemplateToVideo(
                    templateId: templateId,
                    image: firstPhoto
                )
            } else {
                videoId = try await videoService.generateImageToVideo(
                    image: firstPhoto,
                    prompt: "Apply \(context.template.title) style",
                    quality: mapQuality(context.quality),
                    aspectRatio: context.format
                )
            }

            // Шаг 2: Polling статуса
            await updateStatus("Generating your video...")
            state = .generating

            let statusResponse = try await videoService.pollStatus(
                videoId: videoId
            ) { [weak self] statusText in
                Task { @MainActor [weak self] in
                    self?.updateStatusFromServer(statusText)
                }
            }

            // Шаг 3: Успех
            let resultData = VideoResultData(
                videoUrl: statusResponse.videoUrl,
                previewImage: firstPhoto,
                context: context
            )

            withAnimation(.easeOut(duration: 0.3)) {
                state = .completed(resultData)
            }

        } catch NetworkError.serverError(let code, let message) {
            await updateStatus("Error")
            state = .failed("Server error \(code): \(message ?? "")")

        } catch NetworkError.unauthorized {
            state = .failed("Unauthorized. Please restart the app.")

        } catch is CancellationError {
            // Пользователь нажал назад — молча выходим
            return

        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    // MARK: - Helpers

    @MainActor
    private func updateStatus(_ text: String) {
        statusText = text
    }

    private func updateStatusFromServer(_ status: String) {
        switch status {
        case "pending":
            statusText = "In queue..."
        case "processing":
            statusText = "Generating your video..."
        default:
            statusText = "Generating..."
        }
    }

    // Маппинг качества в формат API
    private func mapQuality(_ quality: String) -> String {
        switch quality {
        case "540p":  return "540p"
        case "720p":  return "720p"
        case "1080p": return "1080p"
        //  Сервер не поддерживает 4K, а в UI он есть. Если сервер возвращает одинаковый ответ, то тогда вернём 1080p.
        case "4K":    return "1080p"
        default:      return "1080p"
        }
    }
    
    deinit {
        generationTask?.cancel()
        print("VideoGeneratingViewModel deinitialized")
    }
}

extension GeneratingState: Equatable {
    static func == (lhs: GeneratingState, rhs: GeneratingState) -> Bool {
        switch (lhs, rhs) {
        case (.uploading, .uploading):     return true
        case (.generating, .generating):   return true
        case (.completed, .completed):     return true
        case (.failed(let a), .failed(let b)): return a == b
        default: return false
        }
    }
}
