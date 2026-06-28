import SwiftUI

// MARK: - VideoTemplate

struct VideoTemplate: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let category: String
    let photoCount: Int
    let previewColor: Color

    // Опциональные, потому что могут отсутствовать в mock
    var remoteId: String?
    var previewUrl: String?

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

struct VideoGenerationContext: Identifiable {
    let id = UUID()
    let template: VideoTemplate
    let photos: [UIImage]
    let format: String
    let quality: String
}

// MARK: - VideoResultData

struct VideoResultData: Identifiable {
    let id = UUID()
    let videoUrl: String?
    let previewImage: UIImage?
    let context: VideoGenerationContext
}

// MARK: - Safe Array subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
