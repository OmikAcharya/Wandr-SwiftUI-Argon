import SwiftUI

public struct PhotoLightboxView: View {
    public let photos: [String]
    @State private var currentIndex: Int
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    public init(photos: [String], initialIndex: Int = 0) {
        self.photos = photos
        self._currentIndex = State(initialValue: max(0, min(initialIndex, photos.count - 1)))
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if photos.isEmpty {
                emptyStateView
            } else {
                pagedCarouselView
                topControlsOverlay
            }
        }
        .statusBar(hidden: true)
    }

    // MARK: - Carousel
    @ViewBuilder
    private var pagedCarouselView: some View {
        TabView(selection: $currentIndex) {
            ForEach(photos.indices, id: \.self) { index in
                zoomableImage(filename: photos[index])
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .onChange(of: currentIndex) { _, _ in
            scale = 1.0
            lastScale = 1.0
        }
    }

    // MARK: - Zoomable Image
    @ViewBuilder
    private func zoomableImage(filename: String) -> some View {
        AsyncDiskImage(filename: filename, placeholderSymbol: "photo.fill", contentMode: .fit)
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastScale
                        lastScale = value
                        scale = min(max(scale * delta, 1.0), 4.0)
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                        if scale < 1.0 {
                            withAnimation(.spring()) {
                                scale = 1.0
                            }
                        }
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
                    scale = scale > 1.2 ? 1.0 : 2.5
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Top Controls Overlay
    @ViewBuilder
    private var topControlsOverlay: some View {
        VStack {
            HStack {
                // Photo Counter
                Text("\(currentIndex + 1) of \(photos.count)")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Capsule())

                Spacer()

                // Close Button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.5))
            Text("No photos available")
                .foregroundColor(.white.opacity(0.8))
            Button("Dismiss") {
                dismiss()
            }
            .foregroundColor(.white)
            .padding(.top, 8)
        }
    }
}
