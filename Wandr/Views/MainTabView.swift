import SwiftUI

public struct MainTabView: View {
    public init() {}

    public var body: some View {
        TabView {
            TripsHomeView()
                .tabItem {
                    Label("Trips", systemImage: "suitcase.rolling.fill")
                }

            AtlasMapView()
                .tabItem {
                    Label("Atlas", systemImage: "map.fill")
                }

            MemoriesFeedView()
                .tabItem {
                    Label("Look Back", systemImage: "photo.on.rectangle.angled")
                }

            TravelPassportView()
                .tabItem {
                    Label("Passport", systemImage: "book.closed.fill")
                }
        }
        .tint(WandrTheme.terracotta)
    }
}
