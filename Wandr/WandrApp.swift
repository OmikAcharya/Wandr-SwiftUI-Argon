import SwiftUI

@main
struct WandrApp: App {
    @StateObject private var store = WandrStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
        }
    }
}
