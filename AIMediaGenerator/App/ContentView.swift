import SwiftUI

struct ContentView: View {
    @EnvironmentObject var apphudService: ApphudService

    var body: some View {
        HomeView()
    }
}
