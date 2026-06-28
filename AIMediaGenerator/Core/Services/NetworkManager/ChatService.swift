import Foundation

final class ChatService {

    static let shared = ChatService()
    private init() {}

    private let baseURL = "https://nebulaapps.site/dola"

    // MARK: - Отправить сообщение

    func sendMessage(
        chatId: String,
        message: String,
        personaId: Int? = nil
    ) async throws -> SendMessageResponse {

        let body = SendMessageRequest(
            message: message,
            personaId: personaId,
            additionalPrompt: nil
        )

        return try await NetworkService.shared.request(
            baseURL: baseURL,
            path: "/chats/\(chatId)/messages",
            method: .post,
            body: body,
            responseType: SendMessageResponse.self
        )
    }

    // MARK: - Получить сообщения чата

    func getMessages(chatId: String) async throws -> [MessageDTO] {
        return try await NetworkService.shared.request(
            baseURL: baseURL,
            path: "/chats/\(chatId)/messages",
            method: .get,
            responseType: [MessageDTO].self  // ← напрямую массив
        )
    }

    // MARK: - Получить список чатов

    func getChats() async throws -> [ChatDTO] {
        return try await NetworkService.shared.request(
            baseURL: baseURL,
            path: "/chats",
            method: .get,
            responseType: [ChatDTO].self  // ← напрямую массив
        )
    }

    // MARK: - Генерация chat_id

    func generateChatId() -> String {
        UUID().uuidString
    }
}
