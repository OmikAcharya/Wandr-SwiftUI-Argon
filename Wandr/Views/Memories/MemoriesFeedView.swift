import SwiftUI

public struct MemoriesFeedView: View {
    @EnvironmentObject private var store: WandrStore

    @State private var spotlightId: UUID? = nil
    @State private var selectedMood: MoodTag? = nil
    @State private var selectedWeather: WeatherTag? = nil
    @State private var filterPhotosOnly: Bool = false
    @State private var filterFavoritesOnly: Bool = false

    public init() {}

    private var allPairs: [(trip: Trip, entry: JournalEntry)] {
        store.allEntriesChronological
    }

    private var activeSpotlight: (trip: Trip, entry: JournalEntry)? {
        if let id = spotlightId, let found = allPairs.first(where: { $0.entry.id == id }) {
            return found
        }
        return allPairs.first(where: { $0.entry.isFavorite || !$0.entry.photoFilenames.isEmpty }) ?? allPairs.first
    }

    private var filteredMemories: [(trip: Trip, entry: JournalEntry)] {
        var list = allPairs

        if filterFavoritesOnly {
            list = list.filter { $0.entry.isFavorite }
        }

        if filterPhotosOnly {
            list = list.filter { !$0.entry.photoFilenames.isEmpty }
        }

        if let mood = selectedMood {
            list = list.filter { $0.entry.mood == mood }
        }

        if let weather = selectedWeather {
            list = list.filter { $0.entry.weather == weather }
        }

        return list
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let spotlight = activeSpotlight {
                        spotlightHeroCard(spotlight)
                    }

                    filterPillBar
                    scrapbookStream
                }
                .padding(.bottom, 36)
            }
            .navigationTitle("Look Back")
        }
    }

    // MARK: - Spotlight Hero Card
    @ViewBuilder
    private func spotlightHeroCard(_ pair: (trip: Trip, entry: JournalEntry)) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .foregroundColor(WandrTheme.amberGold)
                    Text("MEMORY SPOTLIGHT")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundColor(WandrTheme.amberGold)
                }

                Spacer()

                Button {
                    shuffleSpotlight()
                } label: {
                    HStack(spacing: 4) {
                        Text("Shuffle")
                            .font(.system(size: 11, weight: .bold))
                        Text("🎲")
                    }
                    .foregroundColor(WandrTheme.terracotta)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(WandrTheme.terracotta.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            NavigationLink {
                EntryDetailView(tripId: pair.trip.id, entryId: pair.entry.id)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    if let photo = pair.entry.photoFilenames.first ?? pair.trip.heroPhotoFilename {
                        AsyncDiskImage(filename: photo, placeholderSymbol: "sparkles", contentMode: .fill)
                            .frame(height: 170)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(pair.entry.title)
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(WandrTheme.textPrimary)

                        Text("From \(pair.trip.title) • \(pair.entry.date.journalDateString)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Text("\"\(pair.entry.content)\"")
                            .font(.system(size: 13, weight: .regular, design: .serif))
                            .italic()
                            .lineSpacing(3)
                            .foregroundColor(WandrTheme.textPrimary.opacity(0.85))
                            .lineLimit(3)
                            .padding(.top, 2)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .wandrCardStyle(cornerRadius: 18)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Filter Pill Bar
    @ViewBuilder
    private var filterPillBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All Pill
                Button {
                    resetFilters()
                } label: {
                    Text("All")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(isDefaultFilter ? WandrTheme.terracotta : WandrTheme.cardSurface)
                        .foregroundColor(isDefaultFilter ? .white : WandrTheme.textPrimary)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1))
                }
                .buttonStyle(.plain)

                // Favorites Only
                Button {
                    filterFavoritesOnly.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                        Text("Favorites")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(filterFavoritesOnly ? Color(red: 0.95, green: 0.28, blue: 0.35) : WandrTheme.cardSurface)
                    .foregroundColor(filterFavoritesOnly ? .white : WandrTheme.textPrimary)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1))
                }
                .buttonStyle(.plain)

                // Photos Only
                Button {
                    filterPhotosOnly.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 10))
                        Text("Photos Only")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(filterPhotosOnly ? WandrTheme.oceanTeal : WandrTheme.cardSurface)
                    .foregroundColor(filterPhotosOnly ? .white : WandrTheme.textPrimary)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1))
                }
                .buttonStyle(.plain)

                // Mood Filters
                ForEach(MoodTag.allCases) { mood in
                    Button {
                        selectedMood = (selectedMood == mood) ? nil : mood
                    } label: {
                        HStack(spacing: 4) {
                            Text(mood.emoji)
                            Text(mood.label)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(selectedMood == mood ? mood.color : WandrTheme.cardSurface)
                        .foregroundColor(selectedMood == mood ? .white : WandrTheme.textPrimary)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var isDefaultFilter: Bool {
        !filterFavoritesOnly && !filterPhotosOnly && selectedMood == nil && selectedWeather == nil
    }

    // MARK: - Scrapbook Stream
    @ViewBuilder
    private var scrapbookStream: some View {
        let memories = filteredMemories
        if memories.isEmpty {
            emptyScrapbookView
        } else {
            LazyVStack(spacing: 20) {
                ForEach(memories.indices, id: \.self) { index in
                    let pair = memories[index]
                    scrapbookCard(pair: pair, index: index)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func scrapbookCard(pair: (trip: Trip, entry: JournalEntry), index: Int) -> some View {
        NavigationLink {
            EntryDetailView(tripId: pair.trip.id, entryId: pair.entry.id)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                // Trip Breadcrumb
                HStack(spacing: 6) {
                    Image(systemName: "suitcase.fill")
                        .font(.system(size: 10))
                        .foregroundColor(WandrTheme.terracotta)
                    Text(pair.trip.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(WandrTheme.terracotta)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(pair.entry.locationName)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Spacer()

                    Text(pair.entry.date.shortMonthDay)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                // Polaroid Frame (if entry has photos)
                if let photo = pair.entry.photoFilenames.first {
                    let tilt = (index % 2 == 0 ? -1.2 : 1.2) * 0.8
                    PolaroidPhotoCard(
                        filename: photo,
                        caption: pair.entry.title,
                        date: pair.entry.date,
                        tiltAngle: tilt
                    )
                    .frame(maxWidth: .infinity)
                }

                // Title and Serif Quote
                VStack(alignment: .leading, spacing: 6) {
                    Text(pair.entry.title)
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(WandrTheme.textPrimary)

                    Text("\"\(pair.entry.content)\"")
                        .font(.system(size: 14, design: .serif))
                        .italic()
                        .lineSpacing(5)
                        .foregroundColor(WandrTheme.textPrimary.opacity(0.88))
                        .lineLimit(4)
                }

                // Stamps row (mood, weather, words)
                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Text(pair.entry.mood.emoji)
                        Text(pair.entry.mood.label)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(pair.entry.mood.color.opacity(0.14))
                    .foregroundColor(pair.entry.mood.color)
                    .clipShape(Capsule())

                    HStack(spacing: 3) {
                        Image(systemName: pair.entry.weather.symbol)
                            .font(.system(size: 10))
                        Text(pair.entry.weather.label)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(WandrTheme.oceanTeal.opacity(0.12))
                    .foregroundColor(WandrTheme.oceanTeal)
                    .clipShape(Capsule())

                    Spacer()

                    if pair.entry.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.95, green: 0.28, blue: 0.35))
                    }

                    Text("\(pair.entry.wordCount) words")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .wandrCardStyle(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var emptyScrapbookView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 42))
                .foregroundColor(WandrTheme.oceanTeal.opacity(0.6))
                .padding(.top, 30)
            Text("No memories found")
                .font(.system(size: 16, weight: .bold, design: .serif))
            Text("Try clearing active filters to see all travel scrapbook entries.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Button("Reset Filters") {
                resetFilters()
            }
            .foregroundColor(WandrTheme.terracotta)
            .font(.system(size: 13, weight: .semibold))
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private func shuffleSpotlight() {
        let pool = allPairs
        guard !pool.isEmpty else { return }
        let current = spotlightId
        let filtered = pool.filter { $0.entry.id != current }
        let next = filtered.randomElement() ?? pool.randomElement()
        withAnimation(.spring()) {
            spotlightId = next?.entry.id
        }
    }

    private func resetFilters() {
        filterFavoritesOnly = false
        filterPhotosOnly = false
        selectedMood = nil
        selectedWeather = nil
    }
}
