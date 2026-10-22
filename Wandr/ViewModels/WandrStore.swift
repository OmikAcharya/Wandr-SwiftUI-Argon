import SwiftUI
import Combine

@MainActor
public final class WandrStore: ObservableObject {
    @Published public private(set) var trips: [Trip] = []
    @Published public var searchText: String = ""
    @Published public var selectedCategory: TripCategory? = nil
    @Published public var sortOption: TripSortOption = .newestFirst
    @Published public var showFavoritesOnly: Bool = false

    private let persistence = PersistenceService.shared
    private let imageStorage = ImageStorageService.shared

    public init() {
        self.trips = persistence.loadTrips()
    }

    // MARK: - Computed Properties
    public var filteredTrips: [Trip] {
        var result = trips

        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { trip in
                trip.title.lowercased().contains(query) ||
                trip.destination.lowercased().contains(query) ||
                trip.countryOrRegion.lowercased().contains(query) ||
                trip.summary.lowercased().contains(query) ||
                trip.entries.contains { entry in
                    entry.title.lowercased().contains(query) ||
                    entry.content.lowercased().contains(query) ||
                    entry.locationName.lowercased().contains(query) ||
                    entry.tags.contains { $0.lowercased().contains(query) }
                }
            }
        }

        switch sortOption {
        case .newestFirst:
            result.sort { $0.startDate > $1.startDate }
        case .oldestFirst:
            result.sort { $0.startDate < $1.startDate }
        case .alphabetical:
            result.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .mostMemories:
            result.sort { $0.entries.count > $1.entries.count }
        }

        return result
    }

    public var favoriteTrips: [Trip] {
        trips.filter { $0.isFavorite }
    }

    public var allEntriesChronological: [(trip: Trip, entry: JournalEntry)] {
        var items: [(trip: Trip, entry: JournalEntry)] = []
        for trip in trips {
            for entry in trip.entries {
                items.append((trip: trip, entry: entry))
            }
        }
        return items.sorted { $0.entry.date > $1.entry.date }
    }

    public var statistics: TravelStatistics {
        let totalTrips = trips.count
        let totalEntries = trips.reduce(0) { $0 + $1.entries.count }
        let totalPhotos = trips.reduce(0) { $0 + $1.allPhotoFilenames.count }
        let totalDaysTraveled = trips.reduce(0) { $0 + $1.durationInDays }
        let uniqueRegionsCount = Set(trips.map { $0.countryOrRegion.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }).count
        let totalWordsWritten = trips.reduce(0) { sum, trip in
            sum + trip.entries.reduce(0) { $0 + $1.wordCount }
        }

        var moodMap: [MoodTag: Int] = [:]
        for trip in trips {
            for entry in trip.entries {
                moodMap[entry.mood, default: 0] += 1
            }
        }
        let moodCounts = MoodTag.allCases.map { ($0, moodMap[$0] ?? 0) }

        var categoryMap: [TripCategory: Int] = [:]
        for trip in trips {
            categoryMap[trip.category, default: 0] += 1
        }
        let categoryCounts = TripCategory.allCases.map { ($0, categoryMap[$0] ?? 0) }

        return TravelStatistics(
            totalTrips: totalTrips,
            totalEntries: totalEntries,
            totalPhotos: totalPhotos,
            totalDaysTraveled: totalDaysTraveled,
            uniqueRegionsCount: uniqueRegionsCount,
            totalWordsWritten: totalWordsWritten,
            moodCounts: moodCounts,
            categoryCounts: categoryCounts
        )
    }

    // MARK: - CRUD Operations
    public func addTrip(_ trip: Trip) {
        trips.insert(trip, at: 0)
        persistence.saveTrips(trips)
    }

    public func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            persistence.saveTrips(trips)
        }
    }

    public func deleteTrip(id: UUID) {
        if let trip = trips.first(where: { $0.id == id }) {
            for photo in trip.allPhotoFilenames {
                imageStorage.deleteImage(filename: photo)
            }
            trips.removeAll { $0.id == id }
            persistence.saveTrips(trips)
        }
    }

    public func toggleTripFavorite(id: UUID) {
        if let index = trips.firstIndex(where: { $0.id == id }) {
            trips[index].isFavorite.toggle()
            persistence.saveTrips(trips)
        }
    }

    public func addEntry(_ entry: JournalEntry, to tripId: UUID) {
        if let index = trips.firstIndex(where: { $0.id == tripId }) {
            trips[index].entries.append(entry)
            persistence.saveTrips(trips)
        }
    }

    public func updateEntry(_ entry: JournalEntry, in tripId: UUID) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }),
           let entryIndex = trips[tripIndex].entries.firstIndex(where: { $0.id == entry.id }) {
            trips[tripIndex].entries[entryIndex] = entry
            persistence.saveTrips(trips)
        }
    }

    public func deleteEntry(entryId: UUID, from tripId: UUID) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
            if let entry = trips[tripIndex].entries.first(where: { $0.id == entryId }) {
                for photo in entry.photoFilenames {
                    imageStorage.deleteImage(filename: photo)
                }
                trips[tripIndex].entries.removeAll { $0.id == entryId }
                persistence.saveTrips(trips)
            }
        }
    }

    public func toggleEntryFavorite(entryId: UUID, in tripId: UUID) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }),
           let entryIndex = trips[tripIndex].entries.firstIndex(where: { $0.id == entryId }) {
            trips[tripIndex].entries[entryIndex].isFavorite.toggle()
            persistence.saveTrips(trips)
        }
    }

    public func getTrip(by id: UUID) -> Trip? {
        trips.first { $0.id == id }
    }

    public func resetToSampleData() {
        // Clear all current photo files
        for trip in trips {
            for photo in trip.allPhotoFilenames {
                imageStorage.deleteImage(filename: photo)
            }
        }
        let samples = SampleDataGenerator.createInitialTrips()
        self.trips = samples
        persistence.saveTrips(samples)
    }
}
