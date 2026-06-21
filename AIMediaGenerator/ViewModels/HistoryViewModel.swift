import SwiftUI
import Combine

// Для одной записи в истории
struct HistoryItem: Identifiable {
    let id = UUID()
    let previewText: String
    let time: String
}

// Для секции с датой
struct HistorySection: Identifiable {
    let id = UUID()
    let title: String
    let items: [HistoryItem]
}

final class HistoryViewModel: ObservableObject {
    // Массив секций для отображения в списке
    @Published var sections: [HistorySection] = []
    
    // Градиент для иконок (надо бы уже добавить цвета в Assets, но ладно :D)
    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969), // #98C6F7
            Color(red: 0.922, green: 0.357, blue: 0.573)  // #EB5B92
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    init() {
        loadMockHistory()
    }
    
    // Mock-данные у истории
    private func loadMockHistory() {
        self.sections = [
            HistorySection(title: "Today", items: [
                HistoryItem(previewText: "Just a test words.. i don't know", time: "5:30 AM"),
                HistoryItem(previewText: "Just a test words.. i don't know", time: "5:25 AM")
            ]),
            HistorySection(title: "Yesterday", items: [
                HistoryItem(previewText: "Just a test words.. i don't know", time: "6:11 AM"),
                HistoryItem(previewText: "Just a test words.. i don't know", time: "6:32 AM")
            ]),
            HistorySection(title: "March 4", items: [
                HistoryItem(previewText: "Just a test words.. i don't know", time: "9:32 AM"),
                HistoryItem(previewText: "Just a test words.. i don't know", time: "9:32 AM")
            ])
        ]
    }
    
    func openChat(item: HistoryItem) {
        print("Старый чат с id: \(item.id)")
    }
}


