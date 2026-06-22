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
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "chat_id"
        case title
        case createdAt = "created_at"
    }
}

// MARK: - Сообщение из истории

struct MessageDTO: Decodable, Identifiable {
    let id: String
    let role: String  
    let content: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "message_id"
        case role
        case content
        case createdAt = "created_at"
    }
}

// MARK: - Список чатов

struct ChatsListResponse: Decodable {
    let chats: [ChatDTO]
}

// MARK: - Список сообщений

struct MessagesListResponse: Decodable {
    let messages: [MessageDTO]
}
