import SwiftUI
import Combine

final class VideoHistoryViewModel: ObservableObject {

    @Published var items: [VideoHistoryEntry] = []
    @Published var isLoading: Bool = false

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
