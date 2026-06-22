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

// MARK: - Состояние загрузки истории

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

    // Chat который открываем
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

        do {
            let chats = try await chatService.getChats()

            if chats.isEmpty {
                loadingState = .empty
                sections = []
                return
            }

            // Группируем чаты по дате
            sections = groupChatsByDate(chats)
            loadingState = .loaded

        } catch {
            loadingState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    // MARK: - Группировка по датам

    private func groupChatsByDate(_ chats: [ChatDTO]) -> [HistorySection] {
        let calendar = Calendar.current
        let now = Date()

        // Парсер дат
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Простой парсер как fallback
        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        // Форматтер для отображения времени
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        // Форматтер для заголовка секции (March 4)
        let sectionFormatter = DateFormatter()
        sectionFormatter.dateFormat = "MMMM d"

        // Группируем
        var todayItems: [HistoryItem] = []
        var yesterdayItems: [HistoryItem] = []
        var olderSections: [String: [HistoryItem]] = [:]
        var sectionOrder: [String] = []

        for chat in chats {
            // Парсим дату
            var chatDate: Date?
            if let createdAt = chat.createdAt {
                chatDate = formatter.date(from: createdAt)
                    ?? simpleDateFormatter.date(from: createdAt)
            }

            let timeString = chatDate.map { timeFormatter.string(from: $0) } ?? ""
            let previewText = chat.title ?? "New conversation"

            let item = HistoryItem(
                id: chat.id,
                previewText: previewText,
                time: timeString
            )

            guard let date = chatDate else {
                // Если не удалось распарсить дату, значит это сегодняшний день
                todayItems.append(item)
                continue
            }

            if calendar.isDateInToday(date) {
                todayItems.append(item)
            } else if calendar.isDateInYesterday(date) {
                yesterdayItems.append(item)
            } else {
                let sectionTitle = sectionFormatter.string(from: date)
                if olderSections[sectionTitle] == nil {
                    olderSections[sectionTitle] = []
                    sectionOrder.append(sectionTitle)
                }
                olderSections[sectionTitle]?.append(item)
            }
        }

        // Собираем секции
        var result: [HistorySection] = []

        if !todayItems.isEmpty {
            result.append(HistorySection(title: "Today", items: todayItems))
        }
        if !yesterdayItems.isEmpty {
            result.append(HistorySection(title: "Yesterday", items: yesterdayItems))
        }
        for title in sectionOrder {
            if let items = olderSections[title], !items.isEmpty { 
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
