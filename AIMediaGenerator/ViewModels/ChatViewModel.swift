import SwiftUI
import Combine

final class ChatViewModel: ObservableObject {
    // Текст в поле ввода промпта
    @Published var inputText: String = ""
    
    // Фокус для автоматического открытия клавиатуры при входе
    @Published var isFocused: Bool = false
    
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
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        print("Отправлено сообщение: \(inputText)")
        inputText = "" // Очищаем после отправки
    }
}
