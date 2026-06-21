import SwiftUI
import Combine

final class VideoListViewModel: ObservableObject {

    @Published var categories: [VideoCategory] = []
    @Published var selectedCategoryIndex: Int = 0
    @Published var allTemplates: [VideoTemplate] = []

    var filteredTemplates: [VideoTemplate] {
        let category = categories[safe: selectedCategoryIndex]?.title ?? ""
        return allTemplates.filter { $0.category == category }
    }

    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    init() {
        loadMockData()
    }

    private func loadMockData() {
        categories = [
            VideoCategory(title: "Popular"),
            VideoCategory(title: "Funny"),
            VideoCategory(title: "Sad"),
            VideoCategory(title: "Trends"),
            VideoCategory(title: "Art")
        ]

        allTemplates = [
            // Popular
            VideoTemplate(title: "Clay Fool",     category: "Popular", photoCount: 1, previewColor: Color(red: 0.35, green: 0.22, blue: 0.42)),
            VideoTemplate(title: "Anime Style",   category: "Popular", photoCount: 1, previewColor: Color(red: 0.20, green: 0.28, blue: 0.50)),
            VideoTemplate(title: "Oil Paint",     category: "Popular", photoCount: 2, previewColor: Color(red: 0.42, green: 0.22, blue: 0.30)),
            VideoTemplate(title: "Pixel Art",     category: "Popular", photoCount: 1, previewColor: Color(red: 0.20, green: 0.40, blue: 0.32)),
            VideoTemplate(title: "Watercolor",    category: "Popular", photoCount: 2, previewColor: Color(red: 0.48, green: 0.30, blue: 0.20)),
            VideoTemplate(title: "Neon Glow",     category: "Popular", photoCount: 1, previewColor: Color(red: 0.28, green: 0.28, blue: 0.52)),

            // Funny
            VideoTemplate(title: "Cartoon Me",    category: "Funny",   photoCount: 1, previewColor: Color(red: 0.50, green: 0.35, blue: 0.20)),
            VideoTemplate(title: "Chibi Style",   category: "Funny",   photoCount: 1, previewColor: Color(red: 0.30, green: 0.45, blue: 0.28)),
            VideoTemplate(title: "Meme Lord",     category: "Funny",   photoCount: 2, previewColor: Color(red: 0.40, green: 0.25, blue: 0.45)),

            // Sad
            VideoTemplate(title: "Rainy Day",     category: "Sad",     photoCount: 1, previewColor: Color(red: 0.22, green: 0.30, blue: 0.45)),
            VideoTemplate(title: "Monochrome",    category: "Sad",     photoCount: 1, previewColor: Color(red: 0.28, green: 0.28, blue: 0.32)),

            // Trends
            VideoTemplate(title: "Y2K Vibes",     category: "Trends",  photoCount: 1, previewColor: Color(red: 0.50, green: 0.28, blue: 0.38)),
            VideoTemplate(title: "Retro Wave",    category: "Trends",  photoCount: 2, previewColor: Color(red: 0.30, green: 0.20, blue: 0.50)),

            // Art
            VideoTemplate(title: "Van Gogh",      category: "Art",     photoCount: 1, previewColor: Color(red: 0.42, green: 0.35, blue: 0.18)),
            VideoTemplate(title: "Cubism",        category: "Art",     photoCount: 1, previewColor: Color(red: 0.25, green: 0.38, blue: 0.42)),
            VideoTemplate(title: "Impressionist", category: "Art",     photoCount: 2, previewColor: Color(red: 0.38, green: 0.28, blue: 0.20))
        ]
    }

    func selectCategory(_ index: Int) {
        withAnimation(.easeOut(duration: 0.2)) {
            selectedCategoryIndex = index
        }
    }
}
