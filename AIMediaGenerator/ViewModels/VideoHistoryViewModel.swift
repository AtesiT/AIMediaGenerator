import SwiftUI
import Combine

final class VideoHistoryViewModel: ObservableObject {

    @Published var items: [VideoHistoryEntry] = []
    @Published var isLoading: Bool = false

    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    private let storage = StorageService.shared

    init() {
        loadHistory()
    }

    func loadHistory() {
        items = storage.loadVideoHistory()
    }

    func clearHistory() {
        storage.clearVideoHistory()
        withAnimation(.easeOut(duration: 0.3)) {
            items = []
        }
    }
}
