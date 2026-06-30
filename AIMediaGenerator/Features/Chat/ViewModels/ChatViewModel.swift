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

final class ChatViewModel: ObservableObject {

    @Published var activeDestination: ChatDestination? = nil
    @Published var inputText: String = ""
    @Published var isFocused: Bool = false
    @Published var messages: [ChatMessage] = []
    @Published var isAiTyping: Bool = false
    @Published var loadingState: LoadingState<Empty> = .idle
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

    private let chatService = ChatService.shared

    init(chatId: String? = nil) {
        if let chatId {
            self._chatId = chatId
            self.isExistingChat = true
        } else {
            self._chatId = nil
            self.isExistingChat = false
        }
        print("🔵 ChatViewModel init, chatId: \(chatId ?? "nil")")
    }

    // MARK: - Cleanup

    deinit {
        print("🗑️ ChatViewModel deinitialized")
    }

    // MARK: - onAppear

    func onAppear() {
        if isExistingChat {
            if messages.isEmpty && !loadingState.isLoading {
                // Небольшая задержка чтобы дать fullScreenCover завершить анимацию
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Delay.autofocus) { [weak self] in
                    guard let self else { return }
                    if self.messages.isEmpty && !self.loadingState.isLoading {
                        self.loadMessages()
                    }
                }
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
        guard !loadingState.isLoading else { return }

        let userMessage = ChatMessage(text: trimmedText, isUser: true)
        withAnimation(.easeOut(duration: Constants.Animation.normal)) {
            messages.append(userMessage)
        }
        inputText = ""
        loadingState = .loading as LoadingState<Empty>

        withAnimation(.easeOut(duration: Constants.Animation.normal)) {
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

            withAnimation(.spring(response: Constants.Animation.spring)) {
                isAiTyping = false
                let aiMessage = ChatMessage(
                    text: response.assistantMessage,
                    isUser: false
                )
                messages.append(aiMessage)
                loadingState = .idle as LoadingState<Empty>
            }

            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                StorageService.shared.saveChatId(chatId, preview: text)
                StorageService.shared.saveLastChatId(chatId)
                
                // Кэшируем все сообщения после получения ответа
                StorageService.shared.saveMessages(messages, chatId: chatId)
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

        Task {
            await performLoadMessages(chatId: chatId)
        }
    }

    @MainActor
    private func performLoadMessages(chatId: String) async {
        guard !loadingState.isLoading else { return }

        // Сначала показываем кэшированные сообщения мгновенно
        let cached = StorageService.shared.loadMessages(chatId: chatId)
        if !cached.isEmpty {
            messages = cached
            print("📱 Loaded \(cached.count) messages from cache")
        }

        loadingState = .loading as LoadingState<Empty>

        do {
            let messageDTOs = try await chatService.getMessages(chatId: chatId)

            // Обновляем только если сервер вернул данные
            if !messageDTOs.isEmpty {
                let newMessages = messageDTOs.map { dto in
                    ChatMessage(
                        text: dto.content,
                        isUser: dto.role == "user"
                    )
                }

                withAnimation {
                    messages = newMessages
                    loadingState = .idle as LoadingState<Empty>
                }

                // Кэшируем актуальные сообщения
                StorageService.shared.saveMessages(newMessages, chatId: chatId)
                print("✅ Loaded \(messageDTOs.count) messages from server for chat \(chatId)")

            } else {
                // Сервер вернул пустой массив — оставляем кэш
                withAnimation {
                    loadingState = .idle as LoadingState<Empty>
                }
                print("⚠️ Server returned empty, keeping cache for chat \(chatId)")
            }

        } catch {
            // Ошибка — оставляем кэш
            loadingState = .idle as LoadingState<Empty>
            print("❌ Load messages error: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func handleError(_ message: String) {
        withAnimation {
            isAiTyping = false
            loadingState = .idle as LoadingState<Empty>
        }
        errorMessage = message
        showErrorAlert = true
    }
}
