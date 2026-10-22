import SwiftUI
import PhotosUI
import CoreLocation

public struct AddEditTripSheet: View {
    public let tripToEdit: Trip?

    @EnvironmentObject private var store: WandrStore
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var destination: String
    @State private var countryOrRegion: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var category: TripCategory
    @State private var summary: String
    @State private var latitude: Double
    @State private var longitude: Double
    @State private var coverPhotoFilename: String?

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var isShowingLocationPicker: Bool = false
    @State private var showValidationError: Bool = false

    public init(tripToEdit: Trip? = nil) {
        self.tripToEdit = tripToEdit
        let initialTrip = tripToEdit
        _title = State(initialValue: initialTrip?.title ?? "")
        _destination = State(initialValue: initialTrip?.destination ?? "")
        _countryOrRegion = State(initialValue: initialTrip?.countryOrRegion ?? "")
        _startDate = State(initialValue: initialTrip?.startDate ?? Date())
        _endDate = State(initialValue: initialTrip?.endDate ?? Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date())
        _category = State(initialValue: initialTrip?.category ?? .roadTrip)
        _summary = State(initialValue: initialTrip?.summary ?? "")
        _latitude = State(initialValue: initialTrip?.latitude ?? 24.5854)
        _longitude = State(initialValue: initialTrip?.longitude ?? 73.7125)
        _coverPhotoFilename = State(initialValue: initialTrip?.coverPhotoFilename)
    }

    public var body: some View {
        NavigationStack {
            Form {
                coverPhotoSection
                basicDetailsSection
                locationSection
                datesSection
                categorySection
                summarySection
            }
            .navigationTitle(tripToEdit == nil ? "New Trip" : "Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTrip()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(WandrTheme.terracotta)
                }
            }
            .sheet(isPresented: $isShowingLocationPicker) {
                LocationPickerSheet(
                    initialCoordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    initialName: destination,
                    initialRegion: countryOrRegion
                ) { name, region, coord in
                    destination = name
                    countryOrRegion = region
                    latitude = coord.latitude
                    longitude = coord.longitude
                }
            }
            .alert("Missing Details", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter both a title and a destination for your trip.")
            }
        }
    }

    // MARK: - Cover Photo Section
    @ViewBuilder
    private var coverPhotoSection: some View {
        Section {
            VStack(spacing: 12) {
                if let filename = coverPhotoFilename {
                    AsyncDiskImage(filename: filename, placeholderSymbol: "photo", contentMode: .fill)
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text(coverPhotoFilename == nil ? "Add Cover Photo" : "Change Cover Photo")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(WandrTheme.terracotta)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    loadSelectedPhoto(newItem)
                }
            }
        } header: {
            Text("Cover Photo")
        }
    }

    // MARK: - Basic Details
    @ViewBuilder
    private var basicDetailsSection: some View {
        Section("Trip Information") {
            TextField("Trip Title (e.g. Summer in Tuscany)", text: $title)
                .font(.system(size: 16, weight: .medium))

            TextField("Destination (e.g. Florence)", text: $destination)

            TextField("Country or Region (e.g. Italy)", text: $countryOrRegion)
        }
    }

    // MARK: - Location Section
    @ViewBuilder
    private var locationSection: some View {
        Section("Geotag & Map Pin") {
            Button {
                isShowingLocationPicker = true
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundColor(WandrTheme.terracotta)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pick Location on Map / Search")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(WandrTheme.textPrimary)
                        Text(String(format: "Coordinates: %.4f, %.4f", latitude, longitude))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Dates Section
    @ViewBuilder
    private var datesSection: some View {
        Section("Dates") {
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .onChange(of: startDate) { _, newStart in
                    if endDate < newStart {
                        endDate = newStart
                    }
                }

            DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
        }
    }

    // MARK: - Category Section
    @ViewBuilder
    private var categorySection: some View {
        Section("Category") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                ForEach(TripCategory.allCases) { cat in
                    Button {
                        category = cat
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 11))
                            Text(cat.title)
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .background(
                            category == cat
                                ? cat.accentColor
                                : Color(UIColor.tertiarySystemGroupedBackground)
                        )
                        .foregroundColor(category == cat ? .white : WandrTheme.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Summary Section
    @ViewBuilder
    private var summarySection: some View {
        Section("Notes & Summary") {
            TextField("What made this trip special?", text: $summary, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    // MARK: - Helpers
    private func loadSelectedPhoto(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                let filename = ImageStorageService.shared.saveImage(uiImage)
                await MainActor.run {
                    self.coverPhotoFilename = filename
                }
            }
        }
    }

    private func saveTrip() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDest = destination.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty && !trimmedDest.isEmpty else {
            showValidationError = true
            return
        }

        if var trip = tripToEdit {
            trip.title = trimmedTitle
            trip.destination = trimmedDest
            trip.countryOrRegion = countryOrRegion.trimmingCharacters(in: .whitespacesAndNewlines)
            trip.startDate = startDate
            trip.endDate = endDate
            trip.category = category
            trip.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
            trip.coverPhotoFilename = coverPhotoFilename
            trip.latitude = latitude
            trip.longitude = longitude
            store.updateTrip(trip)
        } else {
            let newTrip = Trip(
                id: UUID(),
                title: trimmedTitle,
                destination: trimmedDest,
                countryOrRegion: countryOrRegion.trimmingCharacters(in: .whitespacesAndNewlines),
                startDate: startDate,
                endDate: endDate,
                summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category,
                coverPhotoFilename: coverPhotoFilename,
                latitude: latitude,
                longitude: longitude,
                isFavorite: false,
                entries: []
            )
            store.addTrip(newTrip)
        }
        dismiss()
    }
}
