import SwiftUI
import Combine

enum HomeDestination: Identifiable {
    case chat
    case paywall
    
    var id: Self { self }
}

final class HomeViewModel: ObservableObject {
    @Published var activeDestination: HomeDestination? = nil
    // Линейный градиент
    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969), // #98C6F7
            Color(red: 0.922, green: 0.357, blue: 0.573)  // #EB5B92
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Заглушки
    // TODO: Переделать заглушки для перехода
    func openSettings() {
        print("Настройки")
    }
    
    func startSearch() {
        activeDestination = .chat
    }
    
    func openPhotoToVideo() {
        //  Заглушка такая =)
        activeDestination = .paywall
    }
    
    // TODO: Добавить переходы для новых карточек
    func openFixAndImprove() {
        activeDestination = .paywall
    }
    
    func openUnderstandFaster() {
        activeDestination = .paywall
    }
}
