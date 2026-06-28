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

    let isExistingChat: Bool

    private var _chatId: String?
    private(set) var chatId: String {
        get {
            if let id = _chatId { return id }
            let newId = UUID().uuidString
            _chatId = newId
            return newId
        }
        set { _chatId = newValue }
    }

    // Флаг что сообщения уже загружены (Чтобы не грузить повторно при каждом onAppear)
    private var messagesLoaded = false

    private let chatService = ChatService.shared

    init(chatId: String? = nil) {
        if let chatId {
            self._chatId = chatId
            self.isExistingChat = true
        } else {
            self._chatId = nil
            self.isExistingChat = false
        }
    }

    // MARK: - onAppear

    func onAppear() {
        if isExistingChat && !messagesLoaded {
            loadMessages()
        } else if !isExistingChat {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Фокус на поле ввода для нового чата
            
            }
        }
    }

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

        let currentChatId = chatId

        Task {
            await performSendMessage(text: trimmedText, chatId: currentChatId)
        }
    }

    @MainActor
    private func performSendMessage(text: String, chatId: String) async {
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

            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                StorageService.shared.saveChatId(chatId, preview: text)
                StorageService.shared.saveLastChatId(chatId)
            }

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

    // MARK: - Load Messages

    func loadMessages() {
        guard let chatId = _chatId else { return }
        // Не грузим повторно если уже загружено
        guard !messagesLoaded else { return }

        Task {
            await performLoadMessages(chatId: chatId)
        }
    }

    @MainActor
    private func performLoadMessages(chatId: String) async {
        guard case .idle = loadingState else { return }
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
                // Помечаем что сообщения загружены
                messagesLoaded = true
            }

            print("✅ Loaded \(messageDTOs.count) messages for chat \(chatId)")

        } catch {
            loadingState = .idle
            // При ошибке позволяем повторить попытку
            messagesLoaded = false
            print("Load messages error: \(error.localizedDescription)")
        }
    }

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
