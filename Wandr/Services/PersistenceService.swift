import Foundation

public final class PersistenceService {
    public static let shared = PersistenceService()

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documents.appendingPathComponent("wandr_trips_v1.json")

        let enc = JSONEncoder()
        enc.outputFormatting = .prettyPrinted
        enc.dateEncodingStrategy = .iso8601
        self.encoder = enc

        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        self.decoder = dec
    }

    public func loadTrips() -> [Trip] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            let initialTrips = SampleDataGenerator.createInitialTrips()
            saveTrips(initialTrips)
            return initialTrips
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let trips = try decoder.decode([Trip].self, from: data)
            return trips
        } catch {
            print("Failed to decode trips from file, regenerating sample data: \(error.localizedDescription)")
            let initialTrips = SampleDataGenerator.createInitialTrips()
            saveTrips(initialTrips)
            return initialTrips
        }
    }

    public func saveTrips(_ trips: [Trip]) {
        do {
            let data = try encoder.encode(trips)
            try data.write(to: fileURL, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Failed to persist trips to disk: \(error.localizedDescription)")
        }
    }
}
