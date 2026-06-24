import SwiftUI
import ApphudSDK

@main
struct AIMediaGeneratorApp: App {

    @StateObject private var apphudService = ApphudService.shared

    init() {
        ApphudService.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(apphudService)
                .preferredColorScheme(.dark)
        }
    }
}
