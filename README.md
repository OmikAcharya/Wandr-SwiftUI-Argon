# Wandr 🧭

An elegant, editorial travel diary & memory keeping application built natively with SwiftUI for iOS 17+.

Save memories from your trips, write journal entries with rich mood and weather metadata, capture photos into nostalgic Polaroid scrapbooks, and view your journeys on interactive route maps.

---

## ✨ Features

- **Trips Dashboard:** Editorial summary counters (Trips, Days on Road, Memories, Photos), category filter chips, search across destinations, and sort modes.
- **Journal Timeline:** Chronological timeline cards with date badges, continuous connector lines, read time estimations, mood emojis, and inline photo reels.
- **Photo Scrapbook:** Responsive 2-column grid of Polaroid-framed photos with custom tilt angles and full-screen pinch-to-zoom lightboxes.
- **Trip Route Map:** Interactive iOS 17 MapKit integration showcasing geotagged locations connected with dashed polyline travel paths.
- **Global Atlas:** Interactive world map toggling between Trip Hubs and individual Memory Pins with bottom carousel cards.
- **Look Back Feed:** Nostalgic scrapbook stream featuring a randomized Memory Spotlight hero card.
- **Travel Passport & Analytics:** Authentic traveler passport dashboard featuring dynamic travel badges (Wayfarer to Master Cartographer), ink destination stamps with rotation effects, and vibe/mood distribution graphs.
- **Zero External Dependencies:** Built 100% with native Apple frameworks (`SwiftUI`, `Foundation`, `PhotosUI`, `MapKit`, `CoreLocation`, `UIKit`, `Combine`).

---

## 🏗 Architecture & Design Guardrails

- **State Management:** Strictly utilizes `ObservableObject`, `@Published`, `@StateObject`, and `@EnvironmentObject`.
- **Coordinate Codability:** Stores coordinates as primitive `latitude: Double` and `longitude: Double` properties on `Trip` and `JournalEntry` models to preserve full `Codable`, `Hashable`, and `Equatable` conformance while exposing computed `CLLocationCoordinate2D` properties.
- **Safe Image Storage:** Never serializes raw image binaries directly into JSON. High-res photos and procedurally generated cards are saved under `Documents/WandrImages/` with `NSCache` memory safety.
- **MapKit iOS 17 Standard:** Built with `Map(position:)`, `Annotation`, and `MapPolyline` APIs.

---

## 🚀 Building & Running

### Prerequisites
- macOS Sonoma or later
- Xcode 15.0+ (iOS 17.0+ SDK)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (optional, `Wandr.xcodeproj` is pre-generated)

### Option 1: Open existing Xcode Project
```bash
open Wandr.xcodeproj
```
Select an iOS 17+ Simulator or connected iPhone and press **Run (Cmd + R)**.

### Option 2: Regenerate Project via XcodeGen
```bash
xcodegen generate
open Wandr.xcodeproj
```

---

## 📂 Project Structure

```text
Wandr/
├── WandrApp.swift
├── Models/
│   ├── Trip.swift
│   ├── JournalEntry.swift
│   └── TravelEnums.swift
├── Services/
│   ├── ImageStorageService.swift
│   ├── PersistenceService.swift
│   ├── SampleDataGenerator.swift
│   └── LocationSearchService.swift
├── ViewModels/
│   └── WandrStore.swift
├── Utilities/
│   ├── WandrTheme.swift
│   └── DateExtensions.swift
├── Components/
│   ├── AsyncDiskImage.swift
│   ├── PolaroidPhotoCard.swift
│   ├── TripCardView.swift
│   ├── EntryTimelineRow.swift
│   ├── PhotoLightboxView.swift
│   └── FlowLayout.swift
└── Views/
    ├── MainTabView.swift
    ├── Trips/
    │   ├── TripsHomeView.swift
    │   ├── TripDetailView.swift
    │   └── AddEditTripSheet.swift
    ├── Entries/
    │   ├── EntryDetailView.swift
    │   └── AddEditEntrySheet.swift
    ├── Atlas/
    │   ├── AtlasMapView.swift
    │   └── LocationPickerSheet.swift
    ├── Memories/
    │   └── MemoriesFeedView.swift
    └── Passport/
        └── TravelPassportView.swift
```
