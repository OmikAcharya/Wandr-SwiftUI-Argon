import SwiftUI

// MARK: - Trip Category
public enum TripCategory: String, CaseIterable, Codable, Identifiable, Hashable {
    case roadTrip
    case mountains
    case beach
    case cityBreak
    case cultural
    case solo
    case backpacking
    case foodTrail

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .roadTrip: return "Road Trip"
        case .mountains: return "Mountains"
        case .beach: return "Beach & Coast"
        case .cityBreak: return "City Break"
        case .cultural: return "Cultural"
        case .solo: return "Solo Escape"
        case .backpacking: return "Backpacking"
        case .foodTrail: return "Food Trail"
        }
    }

    public var icon: String {
        switch self {
        case .roadTrip: return "car.fill"
        case .mountains: return "mountain.2.fill"
        case .beach: return "sun.max.fill"
        case .cityBreak: return "building.2.fill"
        case .cultural: return "theatermasks.fill"
        case .solo: return "figure.walk"
        case .backpacking: return "tent.fill"
        case .foodTrail: return "fork.knife"
        }
    }

    public var accentColor: Color {
        switch self {
        case .roadTrip: return Color(red: 0.82, green: 0.38, blue: 0.27) // Terracotta
        case .mountains: return Color(red: 0.14, green: 0.42, blue: 0.35) // Deep Green
        case .beach: return Color(red: 0.18, green: 0.58, blue: 0.68) // Ocean Teal
        case .cityBreak: return Color(red: 0.45, green: 0.35, blue: 0.65) // Slate Violet
        case .cultural: return Color(red: 0.78, green: 0.45, blue: 0.20) // Ochre
        case .solo: return Color(red: 0.30, green: 0.50, blue: 0.40) // Forest Sage
        case .backpacking: return Color(red: 0.70, green: 0.30, blue: 0.25) // Rust
        case .foodTrail: return Color(red: 0.85, green: 0.50, blue: 0.15) // Amber
        }
    }
}

// MARK: - Mood Tag
public enum MoodTag: String, CaseIterable, Codable, Identifiable, Hashable {
    case euphoric
    case peaceful
    case adventurous
    case nostalgic
    case grateful
    case inspired
    case cozy

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .euphoric: return "Euphoric"
        case .peaceful: return "Peaceful"
        case .adventurous: return "Adventurous"
        case .nostalgic: return "Nostalgic"
        case .grateful: return "Grateful"
        case .inspired: return "Inspired"
        case .cozy: return "Cozy"
        }
    }

    public var emoji: String {
        switch self {
        case .euphoric: return "✨"
        case .peaceful: return "🌿"
        case .adventurous: return "🧭"
        case .nostalgic: return "🕰️"
        case .grateful: return "🙏"
        case .inspired: return "🎨"
        case .cozy: return "☕"
        }
    }

    public var color: Color {
        switch self {
        case .euphoric: return Color(red: 0.95, green: 0.75, blue: 0.20)
        case .peaceful: return Color(red: 0.35, green: 0.68, blue: 0.48)
        case .adventurous: return Color(red: 0.88, green: 0.42, blue: 0.22)
        case .nostalgic: return Color(red: 0.60, green: 0.45, blue: 0.35)
        case .grateful: return Color(red: 0.82, green: 0.52, blue: 0.60)
        case .inspired: return Color(red: 0.38, green: 0.52, blue: 0.78)
        case .cozy: return Color(red: 0.72, green: 0.50, blue: 0.36)
        }
    }
}

// MARK: - Weather Tag
public enum WeatherTag: String, CaseIterable, Codable, Identifiable, Hashable {
    case sunny
    case cloudy
    case rainy
    case breezy
    case snowy
    case starry

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .sunny: return "Sunny"
        case .cloudy: return "Cloudy"
        case .rainy: return "Rainy"
        case .breezy: return "Breezy"
        case .snowy: return "Snowy"
        case .starry: return "Starry"
        }
    }

    public var symbol: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .breezy: return "wind"
        case .snowy: return "snowflake"
        case .starry: return "moon.stars.fill"
        }
    }
}

// MARK: - Trip Sort Option
public enum TripSortOption: String, CaseIterable, Identifiable {
    case newestFirst = "Newest"
    case oldestFirst = "Oldest"
    case alphabetical = "A–Z"
    case mostMemories = "Most Memories"

    public var id: String { rawValue }
}
