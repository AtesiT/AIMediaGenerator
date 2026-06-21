import SwiftUI
import Combine

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

final class ChatViewModel: ObservableObject {
    // Текст в поле ввода промпта
    @Published var inputText: String = ""
    
    // Фокус для автоматического открытия клавиатуры при входе
    @Published var isFocused: Bool = false
    
    // Лента сообщений
    @Published var messages: [ChatMessage] = []
    
    // Статус "мышления" ИИ (три точки)
    @Published var isAiTyping: Bool = false
    
    // Линейный градиент
    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969), // #98C6F7
            Color(red: 0.922, green: 0.357, blue: 0.573)  // #EB5B92
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    func goBack() {
        print("Назад на HomeView")
    }
    
    func changeModel() {
        print("Справа вверху кнопка нажата")
    }
    
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // 1. Добавляем сообщение пользователя
        let userMessage = ChatMessage(text: trimmedText, isUser: true)
        messages.append(userMessage)
        inputText = "" // Очищаем после отправки
        
        // 2. Включаем имитацию ИИ
        isAiTyping = true
        
        // 3. Через 2 секунды выключаем thinking и присылаем ответ
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring()) {
                self.isAiTyping = false
                let aiResponse = ChatMessage(text: "Hi! How can I help you?", isUser: false)
                self.messages.append(aiResponse)
            }
        }
    }
}
