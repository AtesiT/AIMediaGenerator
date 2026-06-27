import Foundation

// MARK: - Запрос отправки сообщения

struct SendMessageRequest: Encodable {
    let message: String
    let personaId: Int?
    let additionalPrompt: String?

    enum CodingKeys: String, CodingKey {
        case message
        case personaId = "persona_id"
        case additionalPrompt = "additional_prompt"
    }
}

// MARK: - Ответ на отправку сообщения

struct SendMessageResponse: Decodable {
    let chatId: String
    let assistantMessage: String

    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case assistantMessage = "assistant_message"
    }
}

// MARK: - Чат

struct ChatDTO: Decodable, Identifiable {
    let id: String
    let title: String?
    let updatedAt: String?
    let lastMessagePreview: String?

    enum CodingKeys: String, CodingKey {
        case id = "chat_id"
        case title
        case updatedAt = "updated_at"
        case lastMessagePreview = "last_message_preview"
    }
}

// MARK: - Сообщение

struct MessageDTO: Decodable, Identifiable {
    // Генерируем id на клиенте если сервер не возвращает
    let id: String
    let role: String
    let content: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.role = try container.decode(String.self, forKey: .role)
        self.content = try container.decode(String.self, forKey: .content)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }
}
