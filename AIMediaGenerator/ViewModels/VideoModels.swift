import SwiftUI

// MARK: - VideoTemplate

struct VideoTemplate: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let category: String
    let photoCount: Int
    let previewColor: Color

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: VideoTemplate, rhs: VideoTemplate) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - VideoCategory

struct VideoCategory: Identifiable {
    let id = UUID()
    let title: String
}

// MARK: - VideoGenerationContext

struct VideoGenerationContext {
    let template: VideoTemplate
    let photos: [UIImage]
    let format: String
    let quality: String
}

// MARK: - Safe Array subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
