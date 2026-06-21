import SwiftUI
import Combine

final class VideoResultViewModel: ObservableObject {

    let context: VideoGenerationContext

    @Published var showSavedToast: Bool = false
    @Published var isPlaying: Bool = false

    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    init(context: VideoGenerationContext) {
        self.context = context
    }

    func togglePlay() {
        withAnimation(.spring(response: 0.3)) {
            isPlaying.toggle()
        }
    }

    // Скачать — имитация, в будущем реальное сохранение видео
    func download() {
        withAnimation(.spring(response: 0.4)) {
            showSavedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.showSavedToast = false
            }
        }
    }
}
