import SwiftUI
import Combine

struct VideoHistoryItem: Identifiable {
    let id = UUID()
    let previewColor: Color // Заглушка вместо thumbnails
    let templateTitle: String
}

final class VideoHistoryViewModel: ObservableObject {

    @Published var items: [VideoHistoryItem] = []

    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    init() {
        // Mock — пустой для демонстрации empty state
        // Можно заполнить для проверки сетки:
        // loadMockItems()
    }

    private func loadMockItems() {
        items = [
            VideoHistoryItem(previewColor: Color(red: 0.35, green: 0.22, blue: 0.42), templateTitle: "Clay Fool"),
            VideoHistoryItem(previewColor: Color(red: 0.20, green: 0.28, blue: 0.50), templateTitle: "Anime Style"),
            VideoHistoryItem(previewColor: Color(red: 0.42, green: 0.22, blue: 0.30), templateTitle: "Oil Paint"),
            VideoHistoryItem(previewColor: Color(red: 0.20, green: 0.40, blue: 0.32), templateTitle: "Pixel Art"),
            VideoHistoryItem(previewColor: Color(red: 0.48, green: 0.30, blue: 0.20), templateTitle: "Watercolor"),
            VideoHistoryItem(previewColor: Color(red: 0.28, green: 0.28, blue: 0.52), templateTitle: "Neon Glow")
        ]
    }
}
