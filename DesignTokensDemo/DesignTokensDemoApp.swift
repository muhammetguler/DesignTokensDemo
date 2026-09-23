import SwiftUI

@main
struct DesignTokensDemoApp: App {
    @StateObject private var themes = ThemeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themes)
        }
    }
}
