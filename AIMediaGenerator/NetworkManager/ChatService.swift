import Foundation

final class ChatService {

    static let shared = ChatService()
    private init() {}

    // baseURL уже содержит /dola — поэтому в path НЕ добавляем /dola
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
            path: "/chats/\(chatId)/messages", // ← убрали /dola
            method: .post,
            body: body,
            responseType: SendMessageResponse.self
        )
    }

    // MARK: - Получить сообщения чата

    func getMessages(chatId: String) async throws -> [MessageDTO] {
        let response = try await NetworkService.shared.request(
            baseURL: baseURL,
            path: "/chats/\(chatId)/messages", // ← убрали /dola
            method: .get,
            responseType: MessagesListResponse.self
        )
        return response.messages
    }

    // MARK: - Получить список чатов

    func getChats() async throws -> [ChatDTO] {
        let response = try await NetworkService.shared.request(
            baseURL: baseURL,
            path: "/chats", // ← убрали /dola
            method: .get,
            responseType: ChatsListResponse.self
        )
        return response.chats
    }

    // MARK: - Генерация chat_id

    func generateChatId() -> String {
        UUID().uuidString
    }
}
