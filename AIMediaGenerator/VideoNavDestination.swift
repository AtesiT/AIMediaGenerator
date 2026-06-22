import SwiftUI

enum VideoNavDestination: Hashable {
    case templateDetail(VideoTemplate)
    case generating(VideoGenerationContext)
    case result(VideoResultData) // Передаём VideoResultData
    case history

    func hash(into hasher: inout Hasher) {
        switch self {
        case .templateDetail(let t):
            hasher.combine("detail")
            hasher.combine(t.id)
        case .generating:
            hasher.combine("generating")
        case .result:
            hasher.combine("result")
        case .history:
            hasher.combine("history")
        }
    }

    static func == (lhs: VideoNavDestination, rhs: VideoNavDestination) -> Bool {
        switch (lhs, rhs) {
        case (.templateDetail(let a), .templateDetail(let b)):
            return a.id == b.id
        case (.generating, .generating):
            return true
        case (.result, .result):
            return true
        case (.history, .history):
            return true
        default:
            return false
        }
    }
}
