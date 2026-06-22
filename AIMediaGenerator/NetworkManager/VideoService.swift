import Foundation
import UIKit

final class VideoService {

    static let shared = VideoService()
    private init() {}

    private let baseURL = "https://nebulaapps.site/pixverse"

    // Интервал опроса статуса в секундах
    private let pollingInterval: TimeInterval = 3.0

    // Максимальное время ожидания (5 минут)
    private let maxPollingDuration: TimeInterval = 300.0

    // MARK: - Шаблоны

    func getTemplates(appId: String = "com.test.test") async throws -> [TemplateDTO] {
        let response = try await NetworkService.shared.request(
            baseURL: baseURL,
            path: "/api/v1/get_templates/\(appId)",
            method: .get,
            responseType: TemplatesResponse.self
        )
        return response.templates
    }

    // MARK: - Image to Video (основной для нашего приложения)

    func generateImageToVideo(
        image: UIImage,
        prompt: String = "",
        quality: String = "1080p",
        aspectRatio: String = "16:9"
    ) async throws -> String {
        // Конвертируем изображение в JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            throw NetworkError.noData
        }

        let response = try await NetworkService.shared.multipartRequest(
            baseURL: baseURL,
            path: "/api/v1/image2video",
            fields: [
                "prompt": prompt,
                "quality": quality,
                "aspect_ratio": aspectRatio
            ],
            imageFields: ["image": imageData],
            responseType: VideoGenerationResponse.self
        )

        return response.videoId
    }

    // MARK: - Template to Video

    func generateTemplateToVideo(
        templateId: String,
        image: UIImage
    ) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            throw NetworkError.noData
        }

        let response = try await NetworkService.shared.multipartRequest(
            baseURL: baseURL,
            path: "/api/v1/template2video",
            fields: ["template_id": templateId],
            imageFields: ["image": imageData],
            responseType: VideoGenerationResponse.self
        )

        return response.videoId
    }

    // MARK: - Polling статуса

    // Опрашиваем сервер каждые 3 секунды пока не получим результат
    func pollStatus(
        videoId: String,
        onProgress: @escaping (String) -> Void
    ) async throws -> VideoStatusResponse {

        let startTime = Date()

        while true {
            // Проверяем таймаут
            if Date().timeIntervalSince(startTime) > maxPollingDuration {
                throw NetworkError.serverError(408, "Generation timeout")
            }

            let status = try await getStatus(videoId: videoId)
            onProgress(status.status.rawValue)

            switch status.status {
            case .completed:
                return status
            case .failed:
                throw NetworkError.serverError(
                    500,
                    status.errorMessage ?? "Generation failed"
                )
            case .pending, .processing:
                // Ждём перед следующим запросом
                try await Task.sleep(
                    nanoseconds: UInt64(pollingInterval * 1_000_000_000)
                )
            }
        }
    }

    // MARK: - Получить статус

    func getStatus(videoId: String) async throws -> VideoStatusResponse {
        return try await NetworkService.shared.request(
            baseURL: baseURL,
            path: "/api/v1/status",
            method: .get,
            queryItems: [URLQueryItem(name: "video_id", value: videoId)],
            responseType: VideoStatusResponse.self
        )
    }

    // MARK: - Баланс

    func getBalance() async throws -> BalanceResponse {
        return try await NetworkService.shared.request(
            baseURL: baseURL,
            path: "/api/v1/balance",
            method: .get,
            responseType: BalanceResponse.self
        )
    }
}
