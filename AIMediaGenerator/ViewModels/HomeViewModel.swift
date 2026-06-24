import SwiftUI
import Combine

enum HomeDestination: Identifiable {
    case chat
    case paywall
    case videoList

    var id: Self { self }
}

final class HomeViewModel: ObservableObject {

    @Published var activeDestination: HomeDestination? = nil

    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private var apphudService: ApphudService {
        ApphudService.shared
    }

    func openSettings() {
        print("Настройки")
    }

    func startSearch() {
        activeDestination = .chat
    }

    func openPhotoToVideo() {
        if apphudService.isSubscribed {
            activeDestination = .videoList
        } else {
            activeDestination = .paywall
        }
    }

    func openFixAndImprove() {
        if apphudService.isSubscribed {
            print("Fix & Improve — coming soon")
        } else {
            activeDestination = .paywall
        }
    }

    func openUnderstandFaster() {
        if apphudService.isSubscribed {
            print("Understand Faster — coming soon")
        } else {
            activeDestination = .paywall
        }
    }
}
