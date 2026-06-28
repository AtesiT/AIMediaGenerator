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
