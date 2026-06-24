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

    // MARK: - Navigation

    @Published var activeDestination: ChatDestination? = nil

    // MARK: - UI State

    @Published var inputText: String = ""
    @Published var isFocused: Bool = false
    @Published var messages: [ChatMessage] = []
    @Published var isAiTyping: Bool = false
    @Published var loadingState: ChatLoadingState = .idle

    // Показываем алерт при ошибке
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    // MARK: - Chat ID
    // Генерируем один раз при создании ViewModel
    // В будущем можно передавать существующий chat_id из истории

    private(set) var chatId: String

    // MARK: - Services

    private let chatService = ChatService.shared

    // MARK: - Gradient

    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Init

    init(chatId: String? = nil) {
        // Если передан существующий chatId — используем его
        // Иначе генерируем новый
        self.chatId = chatId ?? ChatService.shared.generateChatId()
    }

    // MARK: - Navigation

    func goBack() {
        print("Назад на HomeView")
    }

    func changeModel() {
        activeDestination = .history
    }

    // MARK: - Send Message

    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        guard case .idle = loadingState else { return } // Блокируем повторную отправку

        // 1. Добавляем сообщение пользователя
        let userMessage = ChatMessage(text: trimmedText, isUser: true)
        withAnimation(.easeOut(duration: 0.2)) {
            messages.append(userMessage)
        }
        inputText = ""
        loadingState = .loading

        // 2. Показываем индикатор печати
        withAnimation(.easeOut(duration: 0.2)) {
            isAiTyping = true
        }

        // 3. Отправляем реальный запрос
        Task {
            await performSendMessage(text: trimmedText)
        }
    }

    // MARK: - Private: выполняем запрос

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

            // Сохраняем чат в локальную историю
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

    // MARK: - Error Handling

    @MainActor
    private func handleError(_ message: String) {
        withAnimation {
            isAiTyping = false
            loadingState = .idle
        }
        errorMessage = message
        showErrorAlert = true
    }

    // MARK: - Load existing chat messages
    // Вызывается когда открываем чат из истории

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
            // Пустой чат, если ничего не загрузится.
            loadingState = .idle
        }
    }
}
