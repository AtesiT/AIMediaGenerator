import SwiftUI
import Combine

struct HistoryItem: Identifiable {
    let id: String
    let previewText: String
    let time: String
}

struct HistorySection: Identifiable {
    let id = UUID()
    let title: String
    let items: [HistoryItem]
}

enum HistoryLoadingState {
    case idle
    case loading
    case empty
    case loaded
    case error(String)
}

final class HistoryViewModel: ObservableObject {

    @Published var sections: [HistorySection] = []
    @Published var loadingState: HistoryLoadingState = .idle
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var selectedChatId: String? = nil
    @Published var navigateToChat: Bool = false

    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private let storage = StorageService.shared
    private let chatService = ChatService.shared

    init() {
        loadHistory()
    }

    // MARK: - Загрузка истории

    func loadHistory() {
        Task {
            await performLoadHistory()
        }
    }

    @MainActor
    private func performLoadHistory() async {
        loadingState = .loading

        // Сначала загружаем локальную историю — мгновенно
        let localHistory = storage.loadChatHistory()

        if !localHistory.isEmpty {
            sections = groupEntriesByDate(localHistory)
            loadingState = .loaded
        }

        // Затем пробуем обновить с сервера
        do {
            let chats = try await chatService.getChats()

            if chats.isEmpty && localHistory.isEmpty {
                loadingState = .empty
                sections = []
                return
            }

            if !chats.isEmpty {
                // Мержим серверные данные с локальными
                sections = groupChatsByDate(chats)
                loadingState = .loaded
            }

        } catch {
            // Если сервер недоступен — показываем локальные данные
            if localHistory.isEmpty {
                loadingState = .empty
            }
            print("History server error: \(error.localizedDescription)")
        }
    }

    // MARK: - Группировка локальных записей

    private func groupEntriesByDate(
        _ entries: [ChatHistoryEntry]
    ) -> [HistorySection] {
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let sectionFormatter = DateFormatter()
        sectionFormatter.dateFormat = "MMMM d"

        var todayItems: [HistoryItem] = []
        var yesterdayItems: [HistoryItem] = []
        var olderSections: [String: [HistoryItem]] = [:]
        var sectionOrder: [String] = []

        for entry in entries {
            let item = HistoryItem(
                id: entry.chatId,
                previewText: entry.previewText,
                time: timeFormatter.string(from: entry.date)
            )

            if calendar.isDateInToday(entry.date) {
                todayItems.append(item)
            } else if calendar.isDateInYesterday(entry.date) {
                yesterdayItems.append(item)
            } else {
                let title = sectionFormatter.string(from: entry.date)
                if olderSections[title] == nil {
                    olderSections[title] = []
                    sectionOrder.append(title)
                }
                olderSections[title]?.append(item)
            }
        }

        var result: [HistorySection] = []
        if !todayItems.isEmpty {
            result.append(HistorySection(title: "Today", items: todayItems))
        }
        if !yesterdayItems.isEmpty {
            result.append(HistorySection(title: "Yesterday", items: yesterdayItems))
        }
        for title in sectionOrder {
            if let items = olderSections[title] {
                result.append(HistorySection(title: title, items: items))
            }
        }
        return result
    }

    // MARK: - Группировка серверных чатов

    private func groupChatsByDate(_ chats: [ChatDTO]) -> [HistorySection] {
        let calendar = Calendar.current
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let sectionFormatter = DateFormatter()
        sectionFormatter.dateFormat = "MMMM d"

        var todayItems: [HistoryItem] = []
        var yesterdayItems: [HistoryItem] = []
        var olderSections: [String: [HistoryItem]] = [:]
        var sectionOrder: [String] = []

        for chat in chats {
            var chatDate: Date?
            if let createdAt = chat.createdAt {
                chatDate = formatter.date(from: createdAt)
                    ?? simpleDateFormatter.date(from: createdAt)
            }

            let timeString = chatDate.map {
                timeFormatter.string(from: $0)
            } ?? ""

            let item = HistoryItem(
                id: chat.id,
                previewText: chat.title ?? "New conversation",
                time: timeString
            )

            guard let date = chatDate else {
                todayItems.append(item)
                continue
            }

            if calendar.isDateInToday(date) {
                todayItems.append(item)
            } else if calendar.isDateInYesterday(date) {
                yesterdayItems.append(item)
            } else {
                let title = sectionFormatter.string(from: date)
                if olderSections[title] == nil {
                    olderSections[title] = []
                    sectionOrder.append(title)
                }
                olderSections[title]?.append(item)
            }
        }

        var result: [HistorySection] = []
        if !todayItems.isEmpty {
            result.append(HistorySection(title: "Today", items: todayItems))
        }
        if !yesterdayItems.isEmpty {
            result.append(HistorySection(title: "Yesterday", items: yesterdayItems))
        }
        for title in sectionOrder {
            if let items = olderSections[title] {
                result.append(HistorySection(title: title, items: items))
            }
        }
        return result
    }

    // MARK: - Открыть чат

    func openChat(item: HistoryItem) {
        selectedChatId = item.id
        navigateToChat = true
    }
}
