import SwiftUI

public struct TripsHomeView: View {
    @EnvironmentObject private var store: WandrStore
    @State private var isShowingNewTripSheet: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCountersBanner
                    categoryFilterBar
                    tripsListOrEmptyState
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Wandr")
            .searchable(text: $store.searchText, prompt: "Search trips, cities, or countries...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingNewTripSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .fontWeight(.bold)
                            Text("New Trip")
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(WandrTheme.terracotta)
                        .clipShape(Capsule())
                    }
                }
            }
            .sheet(isPresented: $isShowingNewTripSheet) {
                AddEditTripSheet()
            }
        }
    }

    // MARK: - Summary Counters Banner
    @ViewBuilder
    private var summaryCountersBanner: some View {
        let stats = store.statistics
        HStack(spacing: 0) {
            statCounterItem(number: "\(stats.totalTrips)", label: "Trips", icon: "suitcase.fill", color: WandrTheme.terracotta)
            Divider().frame(height: 32)
            statCounterItem(number: "\(stats.totalDaysTraveled)", label: "Days", icon: "calendar", color: WandrTheme.amberGold)
            Divider().frame(height: 32)
            statCounterItem(number: "\(stats.totalEntries)", label: "Memories", icon: "book.fill", color: WandrTheme.deepForest)
            Divider().frame(height: 32)
            statCounterItem(number: "\(stats.totalPhotos)", label: "Photos", icon: "photo.stack.fill", color: WandrTheme.oceanTeal)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .wandrCardStyle(cornerRadius: 16)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    @ViewBuilder
    private func statCounterItem(number: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
                Text(number)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(WandrTheme.textPrimary)
            }
            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(WandrTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Filter Bar
    @ViewBuilder
    private var categoryFilterBar: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // All Pill
                    Button {
                        store.selectedCategory = nil
                        store.showFavoritesOnly = false
                    } label: {
                        Text("All")
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                store.selectedCategory == nil && !store.showFavoritesOnly
                                    ? WandrTheme.terracotta
                                    : WandrTheme.cardSurface
                            )
                            .foregroundColor(
                                store.selectedCategory == nil && !store.showFavoritesOnly
                                    ? .white
                                    : WandrTheme.textPrimary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    // Favorites Pill
                    Button {
                        store.showFavoritesOnly.toggle()
                        if store.showFavoritesOnly {
                            store.selectedCategory = nil
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(red: 0.95, green: 0.28, blue: 0.35))
                            Text("Favorites")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(store.showFavoritesOnly ? Color(red: 0.95, green: 0.28, blue: 0.35) : WandrTheme.cardSurface)
                        .foregroundColor(store.showFavoritesOnly ? .white : WandrTheme.textPrimary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    // Categories
                    ForEach(TripCategory.allCases) { category in
                        Button {
                            if store.selectedCategory == category {
                                store.selectedCategory = nil
                            } else {
                                store.selectedCategory = category
                                store.showFavoritesOnly = false
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 10))
                                Text(category.title)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(store.selectedCategory == category ? category.accentColor : WandrTheme.cardSurface)
                            .foregroundColor(store.selectedCategory == category ? .white : WandrTheme.textPrimary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 4)
            }

            // Sort Menu
            Menu {
                ForEach(TripSortOption.allCases) { opt in
                    Button {
                        store.sortOption = opt
                    } label: {
                        HStack {
                            Text(opt.rawValue)
                            if store.sortOption == opt {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 20))
                    .foregroundColor(WandrTheme.terracotta)
                    .padding(.trailing, 16)
            }
        }
    }

    // MARK: - Trips List or Empty State
    @ViewBuilder
    private var tripsListOrEmptyState: some View {
        let trips = store.filteredTrips
        if trips.isEmpty {
            emptyStateView
        } else {
            LazyVStack(spacing: 16) {
                ForEach(trips) { trip in
                    NavigationLink {
                        TripDetailView(tripId: trip.id)
                    } label: {
                        TripCardView(
                            trip: trip,
                            onToggleFavorite: {
                                store.toggleTripFavorite(id: trip.id)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "map.circle")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(WandrTheme.terracotta.opacity(0.7))
                .padding(.top, 40)

            Text("No trips match your filters")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(WandrTheme.textPrimary)

            Text("Try clearing search keywords or switching categories to explore your journal.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                store.searchText = ""
                store.selectedCategory = nil
                store.showFavoritesOnly = false
            } label: {
                Text("Reset Filters")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(WandrTheme.terracotta)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(WandrTheme.terracotta.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}
