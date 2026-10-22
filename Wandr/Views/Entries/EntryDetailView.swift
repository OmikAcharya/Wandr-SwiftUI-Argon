import SwiftUI
import MapKit

public struct EntryDetailView: View {
    public let tripId: UUID
    public let entryId: UUID

    @EnvironmentObject private var store: WandrStore
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingEditSheet: Bool = false
    @State private var isShowingLightbox: Bool = false
    @State private var selectedPhotoIndex: Int = 0
    @State private var showDeleteAlert: Bool = false

    public init(tripId: UUID, entryId: UUID) {
        self.tripId = tripId
        self.entryId = entryId
    }

    private var trip: Trip? {
        store.getTrip(by: tripId)
    }

    private var entry: JournalEntry? {
        trip?.entries.first { $0.id == entryId }
    }

    public var body: some View {
        Group {
            if let entry = entry, let trip = trip {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if !entry.photoFilenames.isEmpty {
                            photoCarouselSection(for: entry)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            metadataRow(for: entry)
                            titleSection(for: entry)
                            moodAndWeatherPills(for: entry)
                            bodyContentSection(for: entry)

                            if !entry.tags.isEmpty {
                                tagsSection(for: entry)
                            }

                            if let coord = entry.coordinate {
                                miniMapCard(coordinate: coord, locationName: entry.locationName)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        toolbarButtons(entry: entry, trip: trip)
                    }
                }
                .sheet(isPresented: $isShowingEditSheet) {
                    AddEditEntrySheet(trip: trip, entryToEdit: entry)
                }
                .fullScreenCover(isPresented: $isShowingLightbox) {
                    PhotoLightboxView(photos: entry.photoFilenames, initialIndex: selectedPhotoIndex)
                }
                .alert("Delete Memory?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        store.deleteEntry(entryId: entry.id, from: trip.id)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This travel memory and its saved photos will be permanently deleted.")
                }
            } else {
                Text("Memory not found")
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Photo Carousel
    @ViewBuilder
    private func photoCarouselSection(for entry: JournalEntry) -> some View {
        TabView(selection: $selectedPhotoIndex) {
            ForEach(entry.photoFilenames.indices, id: \.self) { idx in
                Button {
                    selectedPhotoIndex = idx
                    isShowingLightbox = true
                } label: {
                    AsyncDiskImage(filename: entry.photoFilenames[idx], placeholderSymbol: "photo.fill", contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                        .clipped()
                }
                .buttonStyle(.plain)
                .tag(idx)
            }
        }
        .frame(height: 280)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .background(Color.black.opacity(0.05))
    }

    // MARK: - Metadata Row
    @ViewBuilder
    private func metadataRow(for entry: JournalEntry) -> some View {
        HStack(spacing: 12) {
            Text(entry.date.stampDateString)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(WandrTheme.terracotta)

            Text("•")
                .foregroundColor(.secondary)

            Text("\(entry.readingTimeMinutes) MIN READ")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundColor(.secondary)

            if !entry.locationName.isEmpty {
                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                    Text(entry.locationName)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundColor(WandrTheme.oceanTeal)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(WandrTheme.oceanTeal.opacity(0.12))
                .clipShape(Capsule())
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Title
    @ViewBuilder
    private func titleSection(for entry: JournalEntry) -> some View {
        Text(entry.title)
            .font(.system(size: 28, weight: .bold, design: .serif))
            .foregroundColor(WandrTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Mood & Weather Pills
    @ViewBuilder
    private func moodAndWeatherPills(for entry: JournalEntry) -> some View {
        HStack(spacing: 10) {
            HStack(spacing: 4) {
                Text(entry.mood.emoji)
                Text(entry.mood.label)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(entry.mood.color.opacity(0.16))
            .foregroundColor(entry.mood.color)
            .clipShape(Capsule())

            HStack(spacing: 4) {
                Image(systemName: entry.weather.symbol)
                    .font(.system(size: 12))
                Text(entry.weather.label)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(WandrTheme.oceanTeal.opacity(0.14))
            .foregroundColor(WandrTheme.oceanTeal)
            .clipShape(Capsule())

            Spacer()
        }
    }

    // MARK: - Body Content
    @ViewBuilder
    private func bodyContentSection(for entry: JournalEntry) -> some View {
        Text(entry.content)
            .font(.system(.body, design: .serif))
            .lineSpacing(7)
            .foregroundColor(WandrTheme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Tags Section
    @ViewBuilder
    private func tagsSection(for entry: JournalEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TAGS")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(entry.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(WandrTheme.deepForest)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(WandrTheme.deepForest.opacity(0.10))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.top, 10)
    }

    // MARK: - Mini Map Card
    @ViewBuilder
    private func miniMapCard(coordinate: CLLocationCoordinate2D, locationName: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LOCATION PIN")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(.secondary)

            Map(
                position: .constant(
                    .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                        )
                    )
                ),
                interactionModes: []
            ) {
                Annotation(locationName, coordinate: coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(WandrTheme.terracotta)
                        .background(Circle().fill(.white).padding(2))
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
        .padding(.top, 10)
    }

    // MARK: - Toolbar Buttons
    @ViewBuilder
    private func toolbarButtons(entry: JournalEntry, trip: Trip) -> some View {
        Button {
            store.toggleEntryFavorite(entryId: entry.id, in: trip.id)
        } label: {
            Image(systemName: entry.isFavorite ? "heart.fill" : "heart")
                .foregroundColor(entry.isFavorite ? Color(red: 0.95, green: 0.28, blue: 0.35) : WandrTheme.terracotta)
        }

        Button {
            isShowingEditSheet = true
        } label: {
            Image(systemName: "pencil")
                .foregroundColor(WandrTheme.terracotta)
        }

        Button(role: .destructive) {
            showDeleteAlert = true
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
    }
}
