import Foundation
import MapKit
import Combine

@MainActor
public final class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published public var query: String = "" {
        didSet {
            handleQueryChange(query)
        }
    }
    @Published public var completions: [MKLocalSearchCompletion] = []
    @Published public var isSearching: Bool = false

    private let completer = MKLocalSearchCompleter()

    public static let popularDestinations: [(name: String, region: String, lat: Double, lon: Double)] = [
        ("Udaipur", "Rajasthan, India", 24.5854, 73.7125),
        ("Kyoto", "Kansai, Japan", 35.0116, 135.7681),
        ("Gokarna", "Karnataka, India", 14.5479, 74.3188),
        ("Lonavala", "Maharashtra, India", 18.7557, 73.4091),
        ("Paris", "Île-de-France, France", 48.8566, 2.3522),
        ("Rome", "Lazio, Italy", 41.9028, 12.4964),
        ("Bali", "Indonesia", -8.4095, 115.1889),
        ("New York City", "New York, USA", 40.7128, -74.0060),
        ("Cape Town", "Western Cape, South Africa", -33.9249, 18.4241),
        ("Banff", "Alberta, Canada", 51.1784, -115.5708),
        ("Santorini", "Cyclades, Greece", 36.3932, 25.4615),
        ("Zermatt", "Valais, Switzerland", 45.9765, 7.7491)
    ]

    public override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    private func handleQueryChange(_ newQuery: String) {
        let trimmed = newQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            completions = []
            isSearching = false
            completer.cancel()
        } else {
            isSearching = true
            completer.queryFragment = trimmed
        }
    }

    // MARK: - MKLocalSearchCompleterDelegate
    public nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            self.completions = completer.results
            self.isSearching = false
        }
    }

    public nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            self.isSearching = false
        }
    }

    // MARK: - Resolve Location
    public func resolveLocation(for completion: MKLocalSearchCompletion) async -> (name: String, region: String, coordinate: CLLocationCoordinate2D)? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            guard let item = response.mapItems.first else { return nil }
            let name = item.name ?? completion.title
            let placemark = item.placemark
            let locality = placemark.locality ?? placemark.subAdministrativeArea ?? ""
            let country = placemark.country ?? ""
            let region: String
            if !locality.isEmpty && !country.isEmpty {
                region = "\(locality), \(country)"
            } else if !locality.isEmpty {
                region = locality
            } else if !country.isEmpty {
                region = country
            } else {
                region = completion.subtitle
            }
            return (name: name, region: region, coordinate: placemark.coordinate)
        } catch {
            return nil
        }
    }

    // Reverse geocode fallback for custom map pins
    public func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> (name: String, region: String) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        if let placemarks = try? await geocoder.reverseGeocodeLocation(location),
           let mark = placemarks.first {
            let name = mark.name ?? mark.locality ?? "Selected Location"
            let region = [mark.administrativeArea, mark.country].compactMap { $0 }.joined(separator: ", ")
            return (name: name, region: region.isEmpty ? "Custom Pin" : region)
        }
        return (
            name: String(format: "Lat: %.3f, Lon: %.3f", coordinate.latitude, coordinate.longitude),
            region: "Coordinates"
        )
    }
}
