import Foundation

// MARK: - Text to Video

struct Text2VideoRequest: Encodable {
    let prompt: String
    let duration: Int
    let model: String
    let quality: String
    let aspectRatio: String

    enum CodingKeys: String, CodingKey {
        case prompt
        case duration
        case model
        case quality
        case aspectRatio = "aspect_ratio"
    }

    init(
        prompt: String,
        duration: Int = 5,
        model: String = "v6",
        quality: String = "1080p",
        aspectRatio: String = "16:9"
    ) {
        self.prompt = prompt
        self.duration = duration
        self.model = model
        self.quality = quality
        self.aspectRatio = aspectRatio
    }
}

// MARK: - Ответ на запрос генерации

struct VideoGenerationResponse: Decodable {
    let videoId: String

    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let intId = try? container.decode(Int.self, forKey: .videoId) {
            self.videoId = String(intId)
        } else {
            self.videoId = try container.decode(String.self, forKey: .videoId)
        }
    }
}

// MARK: - Статус генерации

struct VideoStatusResponse: Decodable {
    let videoId: String?
    let status: VideoStatus
    let videoUrl: String?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case status
        case videoUrl = "video_url"
        case errorMessage = "error_message"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let intId = try? container.decodeIfPresent(Int.self, forKey: .videoId) {
            self.videoId = String(intId)
        } else {
            self.videoId = try? container.decodeIfPresent(String.self, forKey: .videoId)
        }
        
        self.status = try container.decode(VideoStatus.self, forKey: .status)
        self.videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
    }
}

enum VideoStatus: String, Decodable {
    case pending
    case processing
    case completed
    case failed
}

// MARK: - Шаблоны

struct TemplateDTO: Decodable, Identifiable {
    let id: String
    let title: String
    let previewUrl: String?
    let category: String?
    let photoCount: Int?

    enum CodingKeys: String, CodingKey {
        case id = "template_id"
        case title
        case previewUrl = "preview_url"
        case category
        case photoCount = "photo_count"
    }
}

struct TemplatesResponse: Decodable {
    let templates: [TemplateDTO]
}

// MARK: - Баланс

struct BalanceResponse: Decodable {
    let balance: Int
    let currency: String?
}
