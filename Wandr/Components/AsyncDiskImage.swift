import SwiftUI

public struct AsyncDiskImage: View {
    public let filename: String?
    public var placeholderSymbol: String = "photo"
    public var contentMode: ContentMode = .fill

    @State private var uiImage: UIImage?

    public init(
        filename: String?,
        placeholderSymbol: String = "photo",
        contentMode: ContentMode = .fill
    ) {
        self.filename = filename
        self.placeholderSymbol = placeholderSymbol
        self.contentMode = contentMode
    }

    public var body: some View {
        ZStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholderView
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: filename) { _, _ in
            loadImage()
        }
    }

    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.88, green: 0.84, blue: 0.80),
                    Color(red: 0.78, green: 0.72, blue: 0.68)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: placeholderSymbol)
                .font(.system(size: 28, weight: .light))
                .foregroundColor(Color.black.opacity(0.3))
        }
    }

    private func loadImage() {
        guard let name = filename, !name.isEmpty else {
            self.uiImage = nil
            return
        }
        if let cached = ImageStorageService.shared.loadImage(filename: name) {
            self.uiImage = cached
        }
    }
}
