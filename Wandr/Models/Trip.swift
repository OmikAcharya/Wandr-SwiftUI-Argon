import Foundation
import CoreLocation

public struct Trip: Identifiable, Codable, Hashable, Equatable {
    public var id: UUID = UUID()
    public var title: String
    public var destination: String
    public var countryOrRegion: String
    public var startDate: Date
    public var endDate: Date
    public var summary: String
    public var category: TripCategory
    public var coverPhotoFilename: String?
    public var latitude: Double
    public var longitude: Double
    public var isFavorite: Bool = false
    public var entries: [JournalEntry] = []
    public var createdAt: Date = Date()

    public init(
        id: UUID = UUID(),
        title: String,
        destination: String,
        countryOrRegion: String,
        startDate: Date,
        endDate: Date,
        summary: String,
        category: TripCategory,
        coverPhotoFilename: String? = nil,
        latitude: Double,
        longitude: Double,
        isFavorite: Bool = false,
        entries: [JournalEntry] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.countryOrRegion = countryOrRegion
        self.startDate = startDate
        self.endDate = endDate
        self.summary = summary
        self.category = category
        self.coverPhotoFilename = coverPhotoFilename
        self.latitude = latitude
        self.longitude = longitude
        self.isFavorite = isFavorite
        self.entries = entries
        self.createdAt = createdAt
    }

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public var durationInDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(1, (components.day ?? 0) + 1)
    }

    public var allPhotoFilenames: [String] {
        var photos: [String] = []
        if let cover = coverPhotoFilename {
            photos.append(cover)
        }
        for entry in entries {
            photos.append(contentsOf: entry.photoFilenames)
        }
        // Preserve order while removing duplicates
        var seen = Set<String>()
        return photos.filter { seen.insert($0).inserted }
    }

    public var heroPhotoFilename: String? {
        coverPhotoFilename ?? entries.first?.photoFilenames.first
    }

    public var sortedEntries: [JournalEntry] {
        entries.sorted { $0.date < $1.date }
    }
}

public struct TravelStatistics: Equatable {
    public let totalTrips: Int
    public let totalEntries: Int
    public let totalPhotos: Int
    public let totalDaysTraveled: Int
    public let uniqueRegionsCount: Int
    public let totalWordsWritten: Int
    public let moodCounts: [(MoodTag, Int)]
    public let categoryCounts: [(TripCategory, Int)]

    public init(
        totalTrips: Int = 0,
        totalEntries: Int = 0,
        totalPhotos: Int = 0,
        totalDaysTraveled: Int = 0,
        uniqueRegionsCount: Int = 0,
        totalWordsWritten: Int = 0,
        moodCounts: [(MoodTag, Int)] = [],
        categoryCounts: [(TripCategory, Int)] = []
    ) {
        self.totalTrips = totalTrips
        self.totalEntries = totalEntries
        self.totalPhotos = totalPhotos
        self.totalDaysTraveled = totalDaysTraveled
        self.uniqueRegionsCount = uniqueRegionsCount
        self.totalWordsWritten = totalWordsWritten
        self.moodCounts = moodCounts
        self.categoryCounts = categoryCounts
    }

    public static func == (lhs: TravelStatistics, rhs: TravelStatistics) -> Bool {
        lhs.totalTrips == rhs.totalTrips &&
        lhs.totalEntries == rhs.totalEntries &&
        lhs.totalPhotos == rhs.totalPhotos &&
        lhs.totalDaysTraveled == rhs.totalDaysTraveled &&
        lhs.uniqueRegionsCount == rhs.uniqueRegionsCount &&
        lhs.totalWordsWritten == rhs.totalWordsWritten &&
        lhs.moodCounts.map { "\($0.0.rawValue):\($0.1)" } == rhs.moodCounts.map { "\($0.0.rawValue):\($0.1)" } &&
        lhs.categoryCounts.map { "\($0.0.rawValue):\($0.1)" } == rhs.categoryCounts.map { "\($0.0.rawValue):\($0.1)" }
    }
}
