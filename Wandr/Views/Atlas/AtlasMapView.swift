import SwiftUI
import MapKit

public struct AtlasMapView: View {
    @EnvironmentObject private var store: WandrStore

    @State private var mapMode: MapMode = .trips
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 22.0, longitude: 79.0),
            span: MKCoordinateSpan(latitudeDelta: 20.0, longitudeDelta: 20.0)
        )
    )
    @State private var selectedTripId: UUID? = nil
    @State private var selectedTripForNavigation: Trip? = nil

    public enum MapMode: String, CaseIterable, Identifiable {
        case trips = "Trips"
        case memories = "All Memories"

        public var id: String { rawValue }
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                mapCanvas
                topFloatingFilterPill
                bottomTripCarousel
            }
            .navigationTitle("Atlas")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedTripForNavigation) { trip in
                TripDetailView(tripId: trip.id)
            }
        }
    }

    // MARK: - Map Canvas
    @ViewBuilder
    private var mapCanvas: some View {
        Map(position: $cameraPosition) {
            if mapMode == .trips {
                ForEach(store.trips) { trip in
                    Annotation(trip.destination, coordinate: trip.coordinate) {
                        tripPinAnnotation(trip)
                            .onTapGesture {
                                selectTrip(trip)
                            }
                    }
                }
            } else {
                ForEach(store.allEntriesChronological, id: \.entry.id) { pair in
                    if let coord = pair.entry.coordinate {
                        Annotation(pair.entry.title, coordinate: coord) {
                            memoryPinAnnotation(entry: pair.entry, trip: pair.trip)
                                .onTapGesture {
                                    selectTrip(pair.trip)
                                }
                        }
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Custom Pin Annotations
    @ViewBuilder
    private func tripPinAnnotation(_ trip: Trip) -> some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(trip.category.accentColor)
                    .frame(width: 46, height: 46)

                AsyncDiskImage(filename: trip.heroPhotoFilename, placeholderSymbol: "mappin", contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)

            Text(trip.destination)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(WandrTheme.textPrimary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(radius: 2)
        }
        .scaleEffect(selectedTripId == trip.id ? 1.15 : 1.0)
        .animation(.spring(response: 0.3), value: selectedTripId)
    }

    @ViewBuilder
    private func memoryPinAnnotation(entry: JournalEntry, trip: Trip) -> some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(entry.mood.color)
                    .frame(width: 40, height: 40)

                AsyncDiskImage(
                    filename: entry.photoFilenames.first ?? trip.heroPhotoFilename,
                    placeholderSymbol: "photo",
                    contentMode: .fill
                )
                .frame(width: 34, height: 34)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: 2)

            Text(entry.title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(WandrTheme.textPrimary)
                .lineLimit(1)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
    }

    // MARK: - Top Floating Filter Pill
    @ViewBuilder
    private var topFloatingFilterPill: some View {
        VStack {
            Picker("Map Mode", selection: $mapMode) {
                ForEach(MapMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(4)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 40)
            .padding(.top, 12)

            Spacer()
        }
    }

    // MARK: - Bottom Horizontal Trip Carousel
    @ViewBuilder
    private var bottomTripCarousel: some View {
        if !store.trips.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.trips) { trip in
                        compactTripCard(trip)
                            .onTapGesture {
                                selectTrip(trip)
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    @ViewBuilder
    private func compactTripCard(_ trip: Trip) -> some View {
        HStack(spacing: 12) {
            AsyncDiskImage(filename: trip.heroPhotoFilename, placeholderSymbol: "mountain.2.fill", contentMode: .fill)
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(trip.title)
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(WandrTheme.textPrimary)
                    .lineLimit(1)

                Text("\(trip.destination), \(trip.countryOrRegion)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text("\(trip.entries.count) Memories")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(WandrTheme.terracotta)

                    Spacer()

                    Button {
                        selectedTripForNavigation = trip
                    } label: {
                        HStack(spacing: 2) {
                            Text("Open Journal")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(WandrTheme.deepForest)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }
        }
        .padding(10)
        .frame(width: 280)
        .background(WandrTheme.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    selectedTripId == trip.id ? WandrTheme.terracotta : Color.black.opacity(0.06),
                    lineWidth: selectedTripId == trip.id ? 2 : 1
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
    }

    private func selectTrip(_ trip: Trip) {
        selectedTripId = trip.id
        withAnimation(.easeInOut(duration: 0.8)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: trip.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
                )
            )
        }
    }
}
