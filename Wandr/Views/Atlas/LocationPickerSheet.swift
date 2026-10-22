import SwiftUI
import MapKit

public struct LocationPickerSheet: View {
    public var onSelectLocation: (String, String, CLLocationCoordinate2D) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var searchService = LocationSearchService()

    @State private var selectedCoordinate: CLLocationCoordinate2D
    @State private var selectedName: String
    @State private var selectedRegion: String
    @State private var cameraPosition: MapCameraPosition
    @State private var showPresets: Bool = true

    public init(
        initialCoordinate: CLLocationCoordinate2D? = nil,
        initialName: String = "",
        initialRegion: String = "",
        onSelectLocation: @escaping (String, String, CLLocationCoordinate2D) -> Void
    ) {
        let coord = initialCoordinate ?? CLLocationCoordinate2D(latitude: 24.5854, longitude: 73.7125)
        self._selectedCoordinate = State(initialValue: coord)
        self._selectedName = State(initialValue: initialName.isEmpty ? "Udaipur" : initialName)
        self._selectedRegion = State(initialValue: initialRegion.isEmpty ? "Rajasthan, India" : initialRegion)
        self._cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                )
            )
        )
        self.onSelectLocation = onSelectLocation
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                mapSection
                topSearchOverlay
            }
            .safeAreaInset(edge: .bottom) {
                bottomConfirmationCard
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        confirmAndDismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(WandrTheme.terracotta)
                }
            }
        }
    }

    // MARK: - Map Section
    @ViewBuilder
    private var mapSection: some View {
        MapReader { proxy in
            Map(position: $cameraPosition) {
                Annotation(selectedName, coordinate: selectedCoordinate) {
                    pinMarker
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .onTapGesture { screenPoint in
                if let coord = proxy.convert(screenPoint, from: .local) {
                    updateCoordinate(coord)
                }
            }
        }
    }

    @ViewBuilder
    private var pinMarker: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(WandrTheme.terracotta)
                .background(Circle().fill(.white).padding(2))
                .shadow(radius: 4)

            Image(systemName: "triangle.fill")
                .font(.system(size: 10))
                .foregroundColor(WandrTheme.terracotta)
                .rotationEffect(.degrees(180))
                .offset(y: -4)
        }
    }

    // MARK: - Top Search Overlay
    @ViewBuilder
    private var topSearchOverlay: some View {
        VStack(spacing: 8) {
            searchFieldView

            if !searchService.completions.isEmpty {
                autocompleteSuggestionsList
            } else if searchService.query.isEmpty && showPresets {
                presetSuggestionsBar
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    @ViewBuilder
    private var searchFieldView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search city, landmark, or address...", text: $searchService.query)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()

            if !searchService.query.isEmpty {
                Button {
                    searchService.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }

    @ViewBuilder
    private var autocompleteSuggestionsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(searchService.completions, id: \.self) { completion in
                    Button {
                        selectCompletion(completion)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(completion.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(WandrTheme.textPrimary)
                            Text(completion.subtitle)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                    }
                    Divider()
                }
            }
        }
        .frame(maxHeight: 220)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    @ViewBuilder
    private var presetSuggestionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LocationSearchService.popularDestinations, id: \.name) { preset in
                    Button {
                        selectPreset(name: preset.name, region: preset.region, lat: preset.lat, lon: preset.lon)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 10))
                            Text(preset.name)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(.ultraThinMaterial)
                        .foregroundColor(WandrTheme.textPrimary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Bottom Confirmation Card
    @ViewBuilder
    private var bottomConfirmationCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.system(size: 18))
                    .foregroundColor(WandrTheme.terracotta)
                    .frame(width: 38, height: 38)
                    .background(WandrTheme.terracotta.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(WandrTheme.textPrimary)
                        .lineLimit(1)
                    Text(selectedRegion)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }

            Button {
                confirmAndDismiss()
            } label: {
                Text("Select This Destination")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(WandrTheme.terracotta)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(16)
        .background(WandrTheme.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -2)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Actions
    private func updateCoordinate(_ coord: CLLocationCoordinate2D) {
        selectedCoordinate = coord
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            )
        }
        Task {
            let res = await searchService.reverseGeocode(coordinate: coord)
            selectedName = res.name
            selectedRegion = res.region
        }
    }

    private func selectCompletion(_ completion: MKLocalSearchCompletion) {
        searchService.query = ""
        Task {
            if let result = await searchService.resolveLocation(for: completion) {
                selectedName = result.name
                selectedRegion = result.region
                selectedCoordinate = result.coordinate
                withAnimation {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: result.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        )
                    )
                }
            }
        }
    }

    private func selectPreset(name: String, region: String, lat: Double, lon: Double) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        selectedName = name
        selectedRegion = region
        selectedCoordinate = coord
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            )
        }
    }

    private func confirmAndDismiss() {
        onSelectLocation(selectedName, selectedRegion, selectedCoordinate)
        dismiss()
    }
}
