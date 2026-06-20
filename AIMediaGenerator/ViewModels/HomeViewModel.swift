import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
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
        print("Ask anything")
    }
    
    func openPhotoToVideo() {
        print("Turn Photo into Video")
    }
}
