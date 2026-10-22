import SwiftUI
import PhotosUI
import CoreLocation

public struct AddEditEntrySheet: View {
    public let trip: Trip
    public let entryToEdit: JournalEntry?

    @EnvironmentObject private var store: WandrStore
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var content: String
    @State private var date: Date
    @State private var locationName: String
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var mood: MoodTag
    @State private var weather: WeatherTag
    @State private var photoFilenames: [String]
    @State private var tagsString: String

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isShowingLocationPicker: Bool = false
    @State private var showValidationError: Bool = false

    public init(trip: Trip, entryToEdit: JournalEntry? = nil) {
        self.trip = trip
        self.entryToEdit = entryToEdit
        let initialEntry = entryToEdit
        _title = State(initialValue: initialEntry?.title ?? "")
        _content = State(initialValue: initialEntry?.content ?? "")
        _date = State(initialValue: initialEntry?.date ?? max(trip.startDate, min(Date(), trip.endDate)))
        _locationName = State(initialValue: initialEntry?.locationName ?? trip.destination)
        _latitude = State(initialValue: initialEntry?.latitude ?? trip.latitude)
        _longitude = State(initialValue: initialEntry?.longitude ?? trip.longitude)
        _mood = State(initialValue: initialEntry?.mood ?? .peaceful)
        _weather = State(initialValue: initialEntry?.weather ?? .sunny)
        _photoFilenames = State(initialValue: initialEntry?.photoFilenames ?? [])
        _tagsString = State(initialValue: initialEntry?.tags.joined(separator: ", ") ?? "")
    }

    private var currentWordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }

    public var body: some View {
        NavigationStack {
            Form {
                photosSection
                titleSection
                dateTimeSection
                locationSection
                moodAndWeatherSection
                journalContentSection
                tagsSection
            }
            .navigationTitle(entryToEdit == nil ? "New Memory" : "Edit Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(WandrTheme.terracotta)
                }
            }
            .sheet(isPresented: $isShowingLocationPicker) {
                LocationPickerSheet(
                    initialCoordinate: CLLocationCoordinate2D(
                        latitude: latitude ?? trip.latitude,
                        longitude: longitude ?? trip.longitude
                    ),
                    initialName: locationName,
                    initialRegion: trip.countryOrRegion
                ) { name, _, coord in
                    locationName = name
                    latitude = coord.latitude
                    longitude = coord.longitude
                }
            }
            .alert("Missing Title", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please give your travel memory a title before saving.")
            }
        }
    }

    // MARK: - Photos Section
    @ViewBuilder
    private var photosSection: some View {
        Section("Photos (\(photoFilenames.count)/10)") {
            VStack(alignment: .leading, spacing: 12) {
                if !photoFilenames.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(photoFilenames, id: \.self) { photo in
                                ZStack(alignment: .topTrailing) {
                                    AsyncDiskImage(filename: photo, placeholderSymbol: "photo", contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                    Button {
                                        removePhoto(photo)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.black.opacity(0.6)))
                                    }
                                    .offset(x: 4, y: -4)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: max(1, 10 - photoFilenames.count),
                    matching: .images
                ) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text(photoFilenames.isEmpty ? "Add Photos to Memory" : "Add More Photos")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(WandrTheme.terracotta)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .onChange(of: selectedItems) { _, newItems in
                    loadSelectedPhotos(newItems)
                }
            }
        }
    }

    // MARK: - Title Section
    @ViewBuilder
    private var titleSection: some View {
        Section("Memory Title") {
            TextField("What caught your eye?", text: $title)
                .font(.system(size: 16, weight: .medium))
        }
    }

    // MARK: - Date & Time
    @ViewBuilder
    private var dateTimeSection: some View {
        Section("Date & Time") {
            DatePicker("Captured On", selection: $date)
        }
    }

    // MARK: - Location Section
    @ViewBuilder
    private var locationSection: some View {
        Section("Location") {
            TextField("Spot name (e.g. Cafe Florian)", text: $locationName)

            HStack {
                Button {
                    latitude = trip.latitude
                    longitude = trip.longitude
                    if locationName.isEmpty {
                        locationName = trip.destination
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Use Trip Pin")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(WandrTheme.deepForest)
                }

                Spacer()

                Button {
                    isShowingLocationPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Pick Custom Pin")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(WandrTheme.terracotta)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Mood & Weather
    @ViewBuilder
    private var moodAndWeatherSection: some View {
        Section("Mood") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MoodTag.allCases) { m in
                        Button {
                            mood = m
                        } label: {
                            HStack(spacing: 4) {
                                Text(m.emoji)
                                Text(m.label)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(mood == m ? m.color : Color(UIColor.tertiarySystemGroupedBackground))
                            .foregroundColor(mood == m ? .white : WandrTheme.textPrimary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }

        Section("Weather") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(WeatherTag.allCases) { w in
                        Button {
                            weather = w
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: w.symbol)
                                    .font(.system(size: 11))
                                Text(w.label)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(weather == w ? WandrTheme.oceanTeal : Color(UIColor.tertiarySystemGroupedBackground))
                            .foregroundColor(weather == w ? .white : WandrTheme.textPrimary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Journal Content Section
    @ViewBuilder
    private var journalContentSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $content)
                    .frame(minHeight: 180)
                    .font(.system(size: 15, design: .serif))
                    .lineSpacing(4)

                HStack {
                    Spacer()
                    Text("\(currentWordCount) \(currentWordCount == 1 ? "word" : "words")")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("Travel Diary")
        }
    }

    // MARK: - Tags Section
    @ViewBuilder
    private var tagsSection: some View {
        Section("Tags") {
            TextField("Add tags separated by commas (e.g. sunset, food, hike)", text: $tagsString)
                .font(.system(size: 13))
        }
    }

    // MARK: - Helpers
    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    if let saved = ImageStorageService.shared.saveImage(uiImage) {
                        await MainActor.run {
                            self.photoFilenames.append(saved)
                        }
                    }
                }
            }
            await MainActor.run {
                self.selectedItems = []
            }
        }
    }

    private func removePhoto(_ filename: String) {
        photoFilenames.removeAll { $0 == filename }
        ImageStorageService.shared.deleteImage(filename: filename)
    }

    private func saveEntry() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            showValidationError = true
            return
        }

        let parsedTags = tagsString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if var entry = entryToEdit {
            entry.title = trimmedTitle
            entry.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.date = date
            entry.locationName = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.latitude = latitude
            entry.longitude = longitude
            entry.mood = mood
            entry.weather = weather
            entry.photoFilenames = photoFilenames
            entry.tags = parsedTags
            store.updateEntry(entry, in: trip.id)
        } else {
            let newEntry = JournalEntry(
                id: UUID(),
                tripId: trip.id,
                title: trimmedTitle,
                content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                date: date,
                locationName: locationName.trimmingCharacters(in: .whitespacesAndNewlines),
                latitude: latitude,
                longitude: longitude,
                mood: mood,
                weather: weather,
                photoFilenames: photoFilenames,
                tags: parsedTags,
                isFavorite: false,
                createdAt: Date()
            )
            store.addEntry(newEntry, to: trip.id)
        }
        dismiss()
    }
}
