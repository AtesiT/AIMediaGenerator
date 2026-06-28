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

        // Сначала показываем локальную историю мгновенно
        let localHistory = storage.loadChatHistory()
        if !localHistory.isEmpty {
            sections = groupEntriesByDate(localHistory)
            loadingState = .loaded
        }

        // Затем обновляем с сервера
        do {
            let allChats = try await chatService.getChats()

            // Фильтруем — показываем только чаты с сообщениями
            let chats = allChats.filter {
                $0.lastMessagePreview != nil &&
                !($0.lastMessagePreview?.isEmpty ?? true)
            }

            if chats.isEmpty && localHistory.isEmpty {
                loadingState = .empty
                sections = []
                return
            }

            if !chats.isEmpty {
                sections = groupChatsByDate(chats)
                loadingState = .loaded
            }

        } catch {
            // Сервер недоступен — показываем локальные
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
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let sectionFormatter = DateFormatter()
        sectionFormatter.dateFormat = "MMMM d"

        var todayItems: [HistoryItem] = []
        var yesterdayItems: [HistoryItem] = []
        var olderSections: [String: [HistoryItem]] = [:]
        var sectionOrder: [String] = []

        for chat in chats {
            // Используем updated_at
            var chatDate: Date?
            if let updatedAt = chat.updatedAt {
                chatDate = formatter.date(from: updatedAt)
            }

            let timeString = chatDate.map {
                timeFormatter.string(from: $0)
            } ?? ""

            // Используем last_message_preview как текст превью
            let previewText = chat.lastMessagePreview
                ?? chat.title
                ?? "New conversation"

            let item = HistoryItem(
                id: chat.id,
                previewText: previewText,
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
    deinit {
        print("HistoryViewModel deinitialized")
    }
}
