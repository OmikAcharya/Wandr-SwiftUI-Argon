import SwiftUI
import MapKit

public struct TripDetailView: View {
    public let tripId: UUID

    @EnvironmentObject private var store: WandrStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: DetailSegment = .timeline
    @State private var isShowingAddEntrySheet: Bool = false
    @State private var isShowingEditTripSheet: Bool = false
    @State private var isShowingLightbox: Bool = false
    @State private var selectedPhotoIndex: Int = 0
    @State private var showDeleteAlert: Bool = false

    public enum DetailSegment: String, CaseIterable, Identifiable {
        case timeline = "Timeline"
        case scrapbook = "Photos"
        case map = "Map & Route"

        public var id: String { rawValue }
    }

    public init(tripId: UUID) {
        self.tripId = tripId
    }

    private var trip: Trip? {
        store.getTrip(by: tripId)
    }

    public var body: some View {
        Group {
            if let trip = trip {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        heroHeaderSection(for: trip)
                        segmentedPickerSection
                        activeTabContent(for: trip)
                    }
                    .padding(.bottom, 40)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        toolbarMenu(for: trip)
                    }
                }
                .sheet(isPresented: $isShowingAddEntrySheet) {
                    AddEditEntrySheet(trip: trip)
                }
                .sheet(isPresented: $isShowingEditTripSheet) {
                    AddEditTripSheet(tripToEdit: trip)
                }
                .fullScreenCover(isPresented: $isShowingLightbox) {
                    PhotoLightboxView(photos: trip.allPhotoFilenames, initialIndex: selectedPhotoIndex)
                }
                .alert("Delete Trip?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        store.deleteTrip(id: trip.id)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to delete '\(trip.title)'? All \(trip.entries.count) memories and attached photos will be permanently removed.")
                }
            } else {
                Text("Trip not found")
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Hero Header
    @ViewBuilder
    private func heroHeaderSection(for trip: Trip) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncDiskImage(filename: trip.coverPhotoFilename, placeholderSymbol: "mountain.2.fill")
                .frame(height: 260)
                .frame(maxWidth: .infinity)
                .clipped()

            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.3), Color.black.opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                // Category badge
                HStack(spacing: 5) {
                    Image(systemName: trip.category.icon)
                        .font(.system(size: 11, weight: .bold))
                    Text(trip.category.title)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(trip.category.accentColor)
                .clipShape(Capsule())

                // Title
                Text(trip.title)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 1)

                // Destination and dates
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                    Text("\(trip.destination), \(trip.countryOrRegion)")
                        .font(.system(size: 13, weight: .medium))

                    Text("•")

                    Text(trip.startDate.formattedRange(to: trip.endDate))
                        .font(.system(size: 13, weight: .regular))
                }
                .foregroundColor(.white.opacity(0.92))

                // Summary
                if !trip.summary.isEmpty {
                    Text(trip.summary)
                        .font(.system(size: 13, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(height: 260)
    }

    // MARK: - Segmented Picker
    @ViewBuilder
    private var segmentedPickerSection: some View {
        Picker("View Mode", selection: $selectedTab) {
            ForEach(DetailSegment.allCases) { segment in
                Text(segment.rawValue).tag(segment)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    // MARK: - Active Tab Content
    @ViewBuilder
    private func activeTabContent(for trip: Trip) -> some View {
        switch selectedTab {
        case .timeline:
            journalTimelineTab(for: trip)
        case .scrapbook:
            scrapbookTab(for: trip)
        case .map:
            tripMapTab(for: trip)
        }
    }

    // MARK: - Tab 1: Timeline
    @ViewBuilder
    private func journalTimelineTab(for trip: Trip) -> some View {
        VStack(spacing: 16) {
            // Write a New Memory CTA Button
            Button {
                isShowingAddEntrySheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 15, weight: .bold))
                    Text("Write a New Memory")
                        .font(.system(size: 15, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(WandrTheme.terracotta)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: WandrTheme.terracotta.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)

            if trip.entries.isEmpty {
                emptyTimelineView
            } else {
                VStack(spacing: 0) {
                    let sorted = trip.sortedEntries
                    ForEach(sorted.indices, id: \.self) { idx in
                        let entry = sorted[idx]
                        NavigationLink {
                            EntryDetailView(tripId: trip.id, entryId: entry.id)
                        } label: {
                            EntryTimelineRow(
                                entry: entry,
                                isLast: idx == sorted.count - 1,
                                onPhotoTap: { photo in
                                    if let pIndex = trip.allPhotoFilenames.firstIndex(of: photo) {
                                        selectedPhotoIndex = pIndex
                                        isShowingLightbox = true
                                    }
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    private var emptyTimelineView: some View {
        VStack(spacing: 10) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 40))
                .foregroundColor(WandrTheme.terracotta.opacity(0.6))
                .padding(.top, 20)
            Text("No memories recorded yet")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(WandrTheme.textPrimary)
            Text("Capture your first thought, photo, or roadside discovery.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Tab 2: Scrapbook
    @ViewBuilder
    private func scrapbookTab(for trip: Trip) -> some View {
        let photos = trip.allPhotoFilenames
        if photos.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "photo.stack")
                    .font(.system(size: 40))
                    .foregroundColor(WandrTheme.oceanTeal.opacity(0.6))
                    .padding(.top, 24)
                Text("No photos in this trip yet")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                Text("Add memories with photos to see them displayed here as Polaroid keepsakes.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
        } else {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 16) {
                ForEach(photos.indices, id: \.self) { index in
                    let tilt = (index % 2 == 0 ? -1.5 : 1.5) * Double((index % 3) + 1) * 0.6
                    Button {
                        selectedPhotoIndex = index
                        isShowingLightbox = true
                    } label: {
                        PolaroidPhotoCard(
                            filename: photos[index],
                            caption: "Memory #\(index + 1)",
                            tiltAngle: tilt
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Tab 3: Trip Map
    @ViewBuilder
    private func tripMapTab(for trip: Trip) -> some View {
        let validEntries = trip.sortedEntries.filter { $0.coordinate != nil }
        let routeCoords: [CLLocationCoordinate2D] = validEntries.compactMap { $0.coordinate }

        VStack(alignment: .leading, spacing: 12) {
            Map(
                position: .constant(
                    .region(
                        MKCoordinateRegion(
                            center: trip.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
                        )
                    )
                )
            ) {
                Annotation(trip.destination, coordinate: trip.coordinate) {
                    VStack(spacing: 0) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(WandrTheme.amberGold)
                            .background(Circle().fill(.white).padding(2))
                            .shadow(radius: 3)
                        Text(trip.destination)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(WandrTheme.textPrimary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }

                ForEach(validEntries) { entry in
                    if let coord = entry.coordinate {
                        Annotation(entry.title, coordinate: coord) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(entry.mood.color)
                                .background(Circle().fill(.white).padding(2))
                        }
                    }
                }

                if routeCoords.count >= 2 {
                    MapPolyline(coordinates: routeCoords)
                        .stroke(WandrTheme.terracotta, style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                }
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )

            HStack {
                HStack(spacing: 4) {
                    Circle().fill(WandrTheme.amberGold).frame(width: 8, height: 8)
                    Text("Trip Hub").font(.system(size: 11))
                }
                HStack(spacing: 4) {
                    Circle().fill(WandrTheme.terracotta).frame(width: 8, height: 8)
                    Text("Memory Pins").font(.system(size: 11))
                }
                Spacer()
                Text("\(validEntries.count) Geotagged Locations")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Toolbar Menu
    @ViewBuilder
    private func toolbarMenu(for trip: Trip) -> some View {
        Menu {
            Button {
                isShowingAddEntrySheet = true
            } label: {
                Label("Add Memory", systemImage: "plus.circle")
            }

            Button {
                isShowingEditTripSheet = true
            } label: {
                Label("Edit Trip", systemImage: "pencil")
            }

            Button {
                store.toggleTripFavorite(id: trip.id)
            } label: {
                Label(
                    trip.isFavorite ? "Unfavorite Trip" : "Favorite Trip",
                    systemImage: trip.isFavorite ? "heart.slash" : "heart"
                )
            }

            Divider()

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete Trip", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 18))
                .foregroundColor(WandrTheme.terracotta)
        }
    }
}
