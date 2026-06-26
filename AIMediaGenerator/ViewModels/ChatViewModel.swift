import SwiftUI
import Combine

enum ChatDestination: Identifiable {
    case history

    var id: Self { self }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// MARK: - Состояние загрузки

enum ChatLoadingState {
    case idle
    case loading
    case error(String)
}

final class ChatViewModel: ObservableObject {

    @Published var activeDestination: ChatDestination? = nil
    @Published var inputText: String = ""
    @Published var isFocused: Bool = false
    @Published var messages: [ChatMessage] = []
    @Published var isAiTyping: Bool = false
    @Published var loadingState: ChatLoadingState = .idle
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    // Флаг — открыт существующий чат или новый
    let isExistingChat: Bool
    private(set) var chatId: String

    private let chatService = ChatService.shared

    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    init(chatId: String? = nil) {
        if let chatId {
            self.chatId = chatId
            self.isExistingChat = true
        } else {
            self.chatId = ChatService.shared.generateChatId()
            self.isExistingChat = false
        }
    }

    // MARK: - onAppear

    func onAppear() {
        if isExistingChat {
            loadMessages()
        }
    }

    // MARK: - Navigation

    func goBack() {}

    func changeModel() {
        activeDestination = .history
    }

    // MARK: - Send Message

    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        guard case .idle = loadingState else { return }

        let userMessage = ChatMessage(text: trimmedText, isUser: true)
        withAnimation(.easeOut(duration: 0.2)) {
            messages.append(userMessage)
        }
        inputText = ""
        loadingState = .loading

        withAnimation(.easeOut(duration: 0.2)) {
            isAiTyping = true
        }

        Task {
            await performSendMessage(text: trimmedText)
        }
    }

    @MainActor
    private func performSendMessage(text: String) async {
        do {
            let response = try await chatService.sendMessage(
                chatId: chatId,
                message: text
            )

            withAnimation(.spring(response: 0.4)) {
                isAiTyping = false
                let aiMessage = ChatMessage(
                    text: response.assistantMessage,
                    isUser: false
                )
                messages.append(aiMessage)
                loadingState = .idle
            }

            StorageService.shared.saveChatId(chatId, preview: text)
            StorageService.shared.saveLastChatId(chatId)

        } catch NetworkError.unauthorized {
            handleError("Session expired. Please restart the app.")
        } catch NetworkError.serverError(let code, let message) {
            handleError("Server error \(code): \(message ?? "Unknown error")")
        } catch NetworkError.noData {
            handleError("No response from server. Try again.")
        } catch {
            handleError(error.localizedDescription)
        }
    }

    // MARK: - Load Messages (для существующего чата)

    func loadMessages() {
        Task {
            await performLoadMessages()
        }
    }

    @MainActor
    private func performLoadMessages() async {
        loadingState = .loading

        do {
            let messageDTOs = try await chatService.getMessages(chatId: chatId)

            withAnimation {
                messages = messageDTOs.map { dto in
                    ChatMessage(
                        text: dto.content,
                        isUser: dto.role == "user"
                    )
                }
                loadingState = .idle
            }

        } catch {
            // Сервер недоступен — показываем пустой чат
            // Это нормально для тестовой среды
            loadingState = .idle
            print("Load messages error: \(error.localizedDescription)")
        }
    }

    // MARK: - Error

    @MainActor
    private func handleError(_ message: String) {
        withAnimation {
            isAiTyping = false
            loadingState = .idle
        }
        errorMessage = message
        showErrorAlert = true
    }
}
