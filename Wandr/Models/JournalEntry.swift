import Foundation
import CoreLocation

public struct JournalEntry: Identifiable, Codable, Hashable, Equatable {
    public var id: UUID = UUID()
    public var tripId: UUID
    public var title: String
    public var content: String
    public var date: Date
    public var locationName: String
    public var latitude: Double?
    public var longitude: Double?
    public var mood: MoodTag
    public var weather: WeatherTag
    public var photoFilenames: [String]
    public var tags: [String]
    public var isFavorite: Bool = false
    public var createdAt: Date = Date()

    public init(
        id: UUID = UUID(),
        tripId: UUID,
        title: String,
        content: String,
        date: Date,
        locationName: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        mood: MoodTag,
        weather: WeatherTag,
        photoFilenames: [String] = [],
        tags: [String] = [],
        isFavorite: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.tripId = tripId
        self.title = title
        self.content = content
        self.date = date
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.mood = mood
        self.weather = weather
        self.photoFilenames = photoFilenames
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }

    public var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    public var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }

    public var readingTimeMinutes: Int {
        max(1, Int(ceil(Double(wordCount) / 180.0)))
    }
}
