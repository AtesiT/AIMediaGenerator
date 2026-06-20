import SwiftUI
import Combine

final class PaywallViewModel: ObservableObject {
    // Состояние отложенного показа крестика
    @Published var showCloseButton = false
    
    // Тариф (true - год, false - месяц)
    @Published var isYearlySelected = true
    
    // Градиент
    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969), // #98C6F7
            Color(red: 0.922, green: 0.357, blue: 0.573)  // #EB5B92
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    // Таймер для появления крестика
    func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.linear(duration: 0.3)) {
                self.showCloseButton = true
            }
        }
    }
    
    // Метод обработки нажатия на главную кнопку
    func handleUnlock(completion: @escaping () -> Void) {
        // Здесь в будущем будет вызов Apphud метода покупки
        print("Покупка тарифа: \(isYearlySelected ? "Год" : "Месяц")")
        completion() // Закрытие экрана
    }
}
