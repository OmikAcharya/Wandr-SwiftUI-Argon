import UIKit
import CoreLocation

public enum SampleDataGenerator {
    public static func createInitialTrips() -> [Trip] {
        let storage = ImageStorageService.shared
        let calendar = Calendar.current
        let now = Date()

        // MARK: - Trip 1: Palaces & Lakes of Mewar (Udaipur)
        let trip1Id = UUID()
        let trip1Start = calendar.date(byAdding: .day, value: -45, to: now) ?? now
        let trip1End = calendar.date(byAdding: .day, value: -41, to: now) ?? now

        let udaipurCover = storage.generateProceduralPostcard(
            title: "Lakes & Marble Palaces",
            subtitle: "Udaipur, Rajasthan",
            topColor: UIColor(red: 0.85, green: 0.45, blue: 0.22, alpha: 1.0),
            bottomColor: UIColor(red: 0.35, green: 0.18, blue: 0.35, alpha: 1.0),
            symbolName: "building.columns.fill"
        )

        let udaipurPhoto1 = storage.generateProceduralPostcard(
            title: "Golden Pichola",
            subtitle: "Jag Mandir Island",
            topColor: UIColor(red: 0.95, green: 0.60, blue: 0.20, alpha: 1.0),
            bottomColor: UIColor(red: 0.25, green: 0.35, blue: 0.55, alpha: 1.0),
            symbolName: "sailboat.fill"
        )

        let udaipurPhoto2 = storage.generateProceduralPostcard(
            title: "Courtyard of Peacock Tiles",
            subtitle: "City Palace",
            topColor: UIColor(red: 0.20, green: 0.55, blue: 0.65, alpha: 1.0),
            bottomColor: UIColor(red: 0.15, green: 0.25, blue: 0.35, alpha: 1.0),
            symbolName: "theatermasks.fill"
        )

        let udaipurPhoto3 = storage.generateProceduralPostcard(
            title: "Sunset Over Sajjangarh",
            subtitle: "Monsoon Palace Ridge",
            topColor: UIColor(red: 0.90, green: 0.35, blue: 0.30, alpha: 1.0),
            bottomColor: UIColor(red: 0.45, green: 0.15, blue: 0.30, alpha: 1.0),
            symbolName: "sunset.fill"
        )

        let entry1_1 = JournalEntry(
            id: UUID(),
            tripId: trip1Id,
            title: "Boat ride on Lake Pichola at golden hour",
            content: "As the sun began to dip behind the rugged Aravali hills, the waters of Lake Pichola turned into molten amber. The wooden boat glided past the pristine white marble pavilions of Jag Mandir, their intricate carved stone arches glowing warmly against the twilight. Flocks of cormorants settled on ancient stone ramparts. The air was cool and smelled of fresh lake breeze and jasmine incense drifting from ghats.",
            date: trip1Start,
            locationName: "Lake Pichola, Udaipur",
            latitude: 24.5764,
            longitude: 73.6800,
            mood: .peaceful,
            weather: .sunny,
            photoFilenames: [udaipurPhoto1].compactMap { $0 },
            tags: ["lake", "sunset", "heritage", "boat"],
            isFavorite: true
        )

        let entry1_2 = JournalEntry(
            id: UUID(),
            tripId: trip1Id,
            title: "Exploring City Palace courtyards",
            content: "Spent nearly four hours lost in the labyrinthine corridors and hanging gardens of City Palace. Every archway revealed vivid glass mosaic peacocks, silver doorways, and panoramic jharokha balconies overlooking the Old City. The craftsmanship from over four centuries is astounding. We paused at the Badi Mahal garden pavilion for sweet spiced tea before descending the royal ramp.",
            date: calendar.date(byAdding: .day, value: 1, to: trip1Start) ?? trip1Start,
            locationName: "City Palace Complex",
            latitude: 24.5762,
            longitude: 73.6835,
            mood: .inspired,
            weather: .cloudy,
            photoFilenames: [udaipurPhoto2].compactMap { $0 },
            tags: ["architecture", "history", "rajasthan", "art"],
            isFavorite: false
        )

        let entry1_3 = JournalEntry(
            id: UUID(),
            tripId: trip1Id,
            title: "Sunset at Monsoon Palace",
            content: "A winding switchback drive up Bansdara peak brought us to Sajjangarh, the Monsoon Palace perched 900 meters high. As evening closed in, the entire Mewar valley lay below like an emerald carpet. When the horizon ignited in hues of purple, crimson, and deep copper, the crowd went completely silent. One of the most unforgettable vistas I have ever witnessed.",
            date: calendar.date(byAdding: .day, value: 2, to: trip1Start) ?? trip1Start,
            locationName: "Sajjangarh Wildlife Sanctuary",
            latitude: 24.5897,
            longitude: 73.6366,
            mood: .euphoric,
            weather: .starry,
            photoFilenames: [udaipurPhoto3].compactMap { $0 },
            tags: ["sunset", "clouds", "mountains", "panoramic"],
            isFavorite: true
        )

        let trip1 = Trip(
            id: trip1Id,
            title: "Palaces & Lakes of Mewar",
            destination: "Udaipur",
            countryOrRegion: "Rajasthan, India",
            startDate: trip1Start,
            endDate: trip1End,
            summary: "A four-day cultural immersion through the City of Lakes, royal palaces, serene boat rides, and panoramic mountain fortresses.",
            category: .cultural,
            coverPhotoFilename: udaipurCover,
            latitude: 24.5854,
            longitude: 73.7125,
            isFavorite: true,
            entries: [entry1_1, entry1_2, entry1_3]
        )

        // MARK: - Trip 2: Monsoon Mist in the Sahyadris (Lonavala & Rajmachi)
        let trip2Id = UUID()
        let trip2Start = calendar.date(byAdding: .day, value: -28, to: now) ?? now
        let trip2End = calendar.date(byAdding: .day, value: -25, to: now) ?? now

        let sahyadrisCover = storage.generateProceduralPostcard(
            title: "Verdant Cloud Valleys",
            subtitle: "Sahyadri Ridge, Western Ghats",
            topColor: UIColor(red: 0.12, green: 0.38, blue: 0.28, alpha: 1.0),
            bottomColor: UIColor(red: 0.08, green: 0.20, blue: 0.18, alpha: 1.0),
            symbolName: "mountain.2.fill"
        )

        let sahyadrisPhoto1 = storage.generateProceduralPostcard(
            title: "Fortress in the Fog",
            subtitle: "Rajmachi Plateau",
            topColor: UIColor(red: 0.25, green: 0.45, blue: 0.38, alpha: 1.0),
            bottomColor: UIColor(red: 0.15, green: 0.25, blue: 0.22, alpha: 1.0),
            symbolName: "cloud.fog.fill"
        )

        let sahyadrisPhoto2 = storage.generateProceduralPostcard(
            title: "Chai by the Cataract",
            subtitle: "Tiger Point Stream",
            topColor: UIColor(red: 0.80, green: 0.50, blue: 0.25, alpha: 1.0),
            bottomColor: UIColor(red: 0.20, green: 0.35, blue: 0.30, alpha: 1.0),
            symbolName: "cup.and.saucer.fill"
        )

        let entry2_1 = JournalEntry(
            id: UUID(),
            tripId: trip2Id,
            title: "Trek through cloud-covered valleys",
            content: "We laced our muddy boots at sunrise. The Sahyadri cliffs were wrapped in dense, rolling monsoon fog that would part every few minutes to reveal emerald green gorges with plunging silver water chutes. The trail through the dense forest was alive with cicadas and rushing streams. Reaching the Shrivardhan fort summit felt like walking right onto an island in the sky.",
            date: trip2Start,
            locationName: "Rajmachi Fort Trail",
            latitude: 18.8285,
            longitude: 73.3980,
            mood: .adventurous,
            weather: .rainy,
            photoFilenames: [sahyadrisPhoto1].compactMap { $0 },
            tags: ["trekking", "monsoon", "fog", "fort"],
            isFavorite: true
        )

        let entry2_2 = JournalEntry(
            id: UUID(),
            tripId: trip2Id,
            title: "Hot chai and corn by the waterfall",
            content: "After three hours on the drenched trail, we took refuge under a makeshift tin shed shelter beside an overflowing mountain creek. A local villager roasted fresh sweet corn cobs over hot charcoal embers, rubbing them generously with chili, salt, and freshly sliced lime. Sipping steaming lemongrass ginger chai while rainwater poured off the roof eaves was pure bliss.",
            date: calendar.date(byAdding: .day, value: 1, to: trip2Start) ?? trip2Start,
            locationName: "Lonavala Waterfall Pass",
            latitude: 18.7557,
            longitude: 73.4091,
            mood: .cozy,
            weather: .breezy,
            photoFilenames: [sahyadrisPhoto2].compactMap { $0 },
            tags: ["chai", "comfort", "waterfall", "monsoon"],
            isFavorite: false
        )

        let trip2 = Trip(
            id: trip2Id,
            title: "Monsoon Mist in the Sahyadris",
            destination: "Lonavala & Rajmachi",
            countryOrRegion: "Maharashtra, India",
            startDate: trip2Start,
            endDate: trip2End,
            summary: "A misty monsoon expedition along the jagged crests of the Western Ghats with roaring waterfalls, mossy historic forts, and roadside chai stalls.",
            category: .mountains,
            coverPhotoFilename: sahyadrisCover,
            latitude: 18.7557,
            longitude: 73.4091,
            isFavorite: false,
            entries: [entry2_1, entry2_2]
        )

        // MARK: - Trip 3: Old Quarter & Lantern Nights (Kyoto)
        let trip3Id = UUID()
        let trip3Start = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let trip3End = calendar.date(byAdding: .day, value: -9, to: now) ?? now

        let kyotoCover = storage.generateProceduralPostcard(
            title: "Vermilion Torii Paths",
            subtitle: "Kyoto, Kansai",
            topColor: UIColor(red: 0.88, green: 0.32, blue: 0.20, alpha: 1.0),
            bottomColor: UIColor(red: 0.22, green: 0.18, blue: 0.28, alpha: 1.0),
            symbolName: "torii.gate" // Will fallback cleanly if needed, or use arch
        ) ?? storage.generateProceduralPostcard(
            title: "Vermilion Torii Paths",
            subtitle: "Kyoto, Kansai",
            topColor: UIColor(red: 0.88, green: 0.32, blue: 0.20, alpha: 1.0),
            bottomColor: UIColor(red: 0.22, green: 0.18, blue: 0.28, alpha: 1.0),
            symbolName: "building.columns"
        )

        let kyotoPhoto1 = storage.generateProceduralPostcard(
            title: "Dawn at Fushimi Inari",
            subtitle: "Mountain Shrine Path",
            topColor: UIColor(red: 0.90, green: 0.40, blue: 0.25, alpha: 1.0),
            bottomColor: UIColor(red: 0.30, green: 0.20, blue: 0.35, alpha: 1.0),
            symbolName: "sun.and.horizon.fill"
        )

        let kyotoPhoto2 = storage.generateProceduralPostcard(
            title: "Matcha by the Kamo",
            subtitle: "Gion Riverside",
            topColor: UIColor(red: 0.32, green: 0.55, blue: 0.38, alpha: 1.0),
            bottomColor: UIColor(red: 0.18, green: 0.28, blue: 0.30, alpha: 1.0),
            symbolName: "leaf.fill"
        )

        let entry3_1 = JournalEntry(
            id: UUID(),
            tripId: trip3Id,
            title: "Dawn walk through Fushimi Inari torii gates",
            content: "We arrived at the base of Inari mountain at 5:30 AM before the trains brought the crowds. The morning air was crisp and still, carrying the scent of cedar and wet moss. Walking beneath thousands of scarlet torii gates ascending into the misty sacred forest felt transcendent. Morning light filtered through the wooden pillars in geometric stripes of gold and shadow.",
            date: trip3Start,
            locationName: "Fushimi Inari Taisha",
            latitude: 34.9671,
            longitude: 135.7727,
            mood: .peaceful,
            weather: .cloudy,
            photoFilenames: [kyotoPhoto1].compactMap { $0 },
            tags: ["kyoto", "shrine", "morning", "sacred"],
            isFavorite: true
        )

        let entry3_2 = JournalEntry(
            id: UUID(),
            tripId: trip3Id,
            title: "Matcha by the Kamo River",
            content: "In the late afternoon, we picked up whisked ceremonial Uji matcha and delicate chestnut wagashi from an old tea house tucked away in Gion. We sat along the stone riverbanks of the Kamo River, dangling our feet as herons hunted in the shallows and bicycles whizzed past. Across the water, the wooden verandas of Pontocho alley were beginning to glow with warm paper lanterns.",
            date: calendar.date(byAdding: .day, value: 2, to: trip3Start) ?? trip3Start,
            locationName: "Kamo River, Sanjo",
            latitude: 35.0088,
            longitude: 135.7712,
            mood: .nostalgic,
            weather: .sunny,
            photoFilenames: [kyotoPhoto2].compactMap { $0 },
            tags: ["tea", "river", "gion", "relaxation"],
            isFavorite: false
        )

        let trip3 = Trip(
            id: trip3Id,
            title: "Old Quarter & Lantern Nights",
            destination: "Kyoto",
            countryOrRegion: "Japan",
            startDate: trip3Start,
            endDate: trip3End,
            summary: "A tranquil journey through historic temples, quiet bamboo groves, traditional tea ceremonies, and glowing riverfront alleyways.",
            category: .cityBreak,
            coverPhotoFilename: kyotoCover,
            latitude: 35.0116,
            longitude: 135.7681,
            isFavorite: true,
            entries: [entry3_1, entry3_2]
        )

        // MARK: - Trip 4: Coastal Highway & Cafes (Gokarna)
        let trip4Id = UUID()
        let trip4Start = calendar.date(byAdding: .day, value: -5, to: now) ?? now
        let trip4End = calendar.date(byAdding: .day, value: -1, to: now) ?? now

        let gokarnaCover = storage.generateProceduralPostcard(
            title: "Arabian Sea Horizon",
            subtitle: "Kudle Beach, Gokarna",
            topColor: UIColor(red: 0.18, green: 0.58, blue: 0.68, alpha: 1.0),
            bottomColor: UIColor(red: 0.10, green: 0.28, blue: 0.42, alpha: 1.0),
            symbolName: "water.waves"
        )

        let gokarnaPhoto1 = storage.generateProceduralPostcard(
            title: "Cliff Path to Om Beach",
            subtitle: "Rocky Coastline Trail",
            topColor: UIColor(red: 0.85, green: 0.55, blue: 0.25, alpha: 1.0),
            bottomColor: UIColor(red: 0.15, green: 0.45, blue: 0.55, alpha: 1.0),
            symbolName: "figure.walk"
        )

        let gokarnaPhoto2 = storage.generateProceduralPostcard(
            title: "Strumming Under the Stars",
            subtitle: "Namaste Shack, Om Beach",
            topColor: UIColor(red: 0.35, green: 0.20, blue: 0.50, alpha: 1.0),
            bottomColor: UIColor(red: 0.08, green: 0.10, blue: 0.22, alpha: 1.0),
            symbolName: "music.note"
        )

        let entry4_1 = JournalEntry(
            id: UUID(),
            tripId: trip4Id,
            title: "Cliffside trail between beaches",
            content: "Hiked the undulating red dirt trail hugging the headland cliffs between Kudle Beach and Om Beach. The midday Arabian sea below crashed into black basalt rocks, sending plumes of white foam into the air. We watched sea eagles circling on thermals above while enjoying chilled fresh coconut water from a vendor stationed at the cliff overlook.",
            date: trip4Start,
            locationName: "Kudle Headland Cliff Trail",
            latitude: 14.5360,
            longitude: 74.3160,
            mood: .adventurous,
            weather: .sunny,
            photoFilenames: [gokarnaPhoto1].compactMap { $0 },
            tags: ["cliffs", "ocean", "hike", "coastal"],
            isFavorite: true
        )

        let entry4_2 = JournalEntry(
            id: UUID(),
            tripId: trip4Id,
            title: "Starry night acoustic music by the shore",
            content: "As dusk settled, small kerosene lanterns and candle lamps lit the open-air wooden tables on the sand. A group of travelers from Portugal and Melbourne pulled out acoustic guitars and a djembe. We sat together with our feet buried in cool wet sand, listening to impromptu songs blend into the rhythmic swell of ocean breakers under an ink-black sky studded with stars.",
            date: calendar.date(byAdding: .day, value: 1, to: trip4Start) ?? trip4Start,
            locationName: "Kudle Beach Shoreline",
            latitude: 14.5420,
            longitude: 74.3180,
            mood: .grateful,
            weather: .starry,
            photoFilenames: [gokarnaPhoto2].compactMap { $0 },
            tags: ["music", "stars", "beachfire", "campfire"],
            isFavorite: false
        )

        let trip4 = Trip(
            id: trip4Id,
            title: "Coastal Highway & Cafes",
            destination: "Gokarna & Kudle Beach",
            countryOrRegion: "Karnataka, India",
            startDate: trip4Start,
            endDate: trip4End,
            summary: "A laid-back coastal escape with cliffside hikes between sandy coves, fresh sea food, yoga by the tides, and acoustic seaside evenings.",
            category: .beach,
            coverPhotoFilename: gokarnaCover,
            latitude: 14.5479,
            longitude: 74.3188,
            isFavorite: false,
            entries: [entry4_1, entry4_2]
        )

        return [trip1, trip2, trip3, trip4]
    }
}
