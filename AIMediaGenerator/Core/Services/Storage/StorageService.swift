import SwiftUI

final class StorageService {

    static let shared = StorageService()
    private init() {}

    private let defaults = UserDefaults.standard

    // MARK: - Keys

    private enum Keys {
        static let chatHistory = "chat_history"
        static let videoHistory = "video_history"
        static let lastChatId = "last_chat_id"
    }

    // MARK: - Chat History

    func saveChatId(_ chatId: String, preview: String) {
        var history = loadChatHistory()

        // Убираем старую запись если есть
        history.removeAll { $0.chatId == chatId }

        // Добавляем новую в начало только если есть текст
        guard !preview.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let entry = ChatHistoryEntry(
            chatId: chatId,
            previewText: preview,
            date: Date()
        )
        history.insert(entry, at: 0)

        if history.count > 50 {
            history = Array(history.prefix(50))
        }

        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: Keys.chatHistory)
        }
    }

    func loadChatHistory() -> [ChatHistoryEntry] {
        guard let data = defaults.data(forKey: Keys.chatHistory),
              let history = try? JSONDecoder().decode(
                [ChatHistoryEntry].self,
                from: data
              ) else {
            return []
        }
        return history
    }

    func clearChatHistory() {
        defaults.removeObject(forKey: Keys.chatHistory)
    }

    // MARK: - Video History

    func saveVideoResult(_ entry: VideoHistoryEntry) {
        var history = loadVideoHistory()
        history.insert(entry, at: 0)

        if history.count > 30 {
            history = Array(history.prefix(30))
        }

        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: Keys.videoHistory)
        }
    }

    func loadVideoHistory() -> [VideoHistoryEntry] {
        guard let data = defaults.data(forKey: Keys.videoHistory),
              let history = try? JSONDecoder().decode(
                [VideoHistoryEntry].self,
                from: data
              ) else {
            return []
        }
        return history
    }

    func clearVideoHistory() {
        defaults.removeObject(forKey: Keys.videoHistory)
    }

    // MARK: - Last Chat ID

    func saveLastChatId(_ chatId: String) {
        defaults.set(chatId, forKey: Keys.lastChatId)
    }

    func loadLastChatId() -> String? {
        defaults.string(forKey: Keys.lastChatId)
    }

    // MARK: - Messages Cache

    func saveMessages(_ messages: [ChatMessage], chatId: String) {
        let data = messages.map { ["text": $0.text, "isUser": $0.isUser] as [String: Any] }
        defaults.set(data, forKey: "messages_\(chatId)")
    }

    func loadMessages(chatId: String) -> [ChatMessage] {
        guard let data = defaults.array(forKey: "messages_\(chatId)") as? [[String: Any]] else {
            return []
        }
        return data.compactMap { dict in
            guard
                let text = dict["text"] as? String,
                let isUser = dict["isUser"] as? Bool
            else { return nil }
            return ChatMessage(text: text, isUser: isUser)
        }
    }

    func clearMessages(chatId: String) {
        defaults.removeObject(forKey: "messages_\(chatId)")
    }
}

// MARK: - Models

struct ChatHistoryEntry: Codable, Identifiable {
    let id: UUID
    let chatId: String
    let previewText: String
    let date: Date

    init(chatId: String, previewText: String, date: Date) {
        self.id = UUID()
        self.chatId = chatId
        self.previewText = previewText
        self.date = date
    }
}

struct VideoHistoryEntry: Codable, Identifiable {
    let id: UUID
    let templateTitle: String
    let format: String
    let quality: String
    let date: Date
    // Сохраняем превью фото как Data
    let previewImageData: Data?

    init(
        templateTitle: String,
        format: String,
        quality: String,
        date: Date,
        previewImage: UIImage?
    ) {
        self.id = UUID()
        self.templateTitle = templateTitle
        self.format = format
        self.quality = quality
        self.date = date
        self.previewImageData = previewImage?.jpegData(compressionQuality: 0.6)
    }

    var previewImage: UIImage? {
        guard let data = previewImageData else { return nil }
        return UIImage(data: data)
    }
}
