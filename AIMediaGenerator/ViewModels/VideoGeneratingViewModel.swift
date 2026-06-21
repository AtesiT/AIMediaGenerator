import SwiftUI
import Combine

final class VideoGeneratingViewModel: ObservableObject {

    let context: VideoGenerationContext

    // Анимация шара
    @Published var isPulsing: Bool = false
    @Published var isRotating: Bool = false

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

    func startAnimations() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            isPulsing = true
        }
        withAnimation(.linear(duration: 9.0).repeatForever(autoreverses: false)) {
            isRotating = true
        }
    }

    // Имитация генерации — через 3 секунды вернёт результат
    func simulateGeneration(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            completion()
        }
    }
}
