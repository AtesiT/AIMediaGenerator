import SwiftUI
import ApphudSDK

@main
struct AIMediaGeneratorApp: App {

    @StateObject private var appHudService = ApphudService.shared

    init() {
        // Инициализация Apphud
        ApphudService.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appHudService)
                // TODO: Возможно убрать потом, или всё-таки background black
                .preferredColorScheme(.dark)
        }
    }
}
