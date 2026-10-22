import UIKit

public final class ImageStorageService {
    public static let shared = ImageStorageService()

    private let imagesDirectory: URL
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = documents.appendingPathComponent("WandrImages", isDirectory: true)
        self.imagesDirectory = dir

        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
    }

    // MARK: - Save Image
    public func saveImage(_ image: UIImage, quality: CGFloat = 0.82) -> String? {
        let processedImage = resizeIfNeeded(image, maxDimension: 1800)
        guard let data = processedImage.jpegData(compressionQuality: quality) else {
            return nil
        }

        let filename = "\(UUID().uuidString).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL, options: .atomic)
            cache.setObject(processedImage, forKey: filename as NSString)
            return filename
        } catch {
            print("Failed to save image to disk: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Load Image
    public func loadImage(filename: String) -> UIImage? {
        if let cached = cache.object(forKey: filename as NSString) {
            return cached
        }

        let fileURL = imagesDirectory.appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let image = UIImage(contentsOfFile: fileURL.path) else {
            return nil
        }

        cache.setObject(image, forKey: filename as NSString)
        return image
    }

    // MARK: - Delete Image
    public func deleteImage(filename: String) {
        cache.removeObject(forKey: filename as NSString)
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Procedural Postcard Generator
    public func generateProceduralPostcard(
        title: String,
        subtitle: String,
        topColor: UIColor,
        bottomColor: UIColor,
        symbolName: String
    ) -> String? {
        let size = CGSize(width: 1200, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let cgContext = context.cgContext

            // 1. Draw smooth gradient background
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
            let locations: [CGFloat] = [0.0, 1.0]

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }

            // 2. Draw subtle decorative travel stamp circles
            cgContext.saveGState()
            cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.18).cgColor)
            cgContext.setLineWidth(3)

            // Postal Stamp Circle 1 (Top right)
            let circle1Rect = CGRect(x: size.width - 260, y: 50, width: 190, height: 190)
            cgContext.strokeEllipse(in: circle1Rect)
            let circle1Inner = CGRect(x: size.width - 245, y: 65, width: 160, height: 160)
            cgContext.strokeEllipse(in: circle1Inner)

            // Postal Stamp Circle 2 (Middle left)
            let circle2Rect = CGRect(x: 60, y: 180, width: 140, height: 140)
            cgContext.setLineDash(phase: 0, lengths: [6, 4])
            cgContext.strokeEllipse(in: circle2Rect)
            cgContext.restoreGState()

            // 3. Draw subtle atmospheric vignette
            let vignetteRect = CGRect(x: 0, y: size.height - 350, width: size.width, height: 350)
            let vignetteColors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.65).cgColor] as CFArray
            if let vignetteGrad = CGGradient(colorsSpace: colorSpace, colors: vignetteColors, locations: [0.0, 1.0]) {
                cgContext.drawLinearGradient(
                    vignetteGrad,
                    start: CGPoint(x: 0, y: size.height - 350),
                    end: CGPoint(x: 0, y: size.height),
                    options: []
                )
            }

            // 4. Draw SF Symbol silhouette in center
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 180, weight: .light)
            if let baseSymbol = UIImage(systemName: symbolName, withConfiguration: symbolConfig)?
                .withTintColor(UIColor.white.withAlphaComponent(0.28), renderingMode: .alwaysOriginal) {
                let symbolRect = CGRect(
                    x: (size.width - baseSymbol.size.width) / 2.0,
                    y: (size.height - baseSymbol.size.height) / 2.0 - 40,
                    width: baseSymbol.size.width,
                    height: baseSymbol.size.height
                )
                baseSymbol.draw(in: symbolRect)
            }

            // 5. Crisp typography at bottom-left
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left

            let titleFont: UIFont
            if let serifDescriptor = UIFont.systemFont(ofSize: 52, weight: .bold).fontDescriptor.withDesign(.serif) {
                titleFont = UIFont(descriptor: serifDescriptor, size: 52)
            } else {
                titleFont = UIFont.systemFont(ofSize: 52, weight: .bold)
            }

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]

            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 26, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85),
                .paragraphStyle: paragraphStyle
            ]

            let textMarginLeft: CGFloat = 64
            let textBottomMargin: CGFloat = 64

            let titleText = title as NSString
            let subtitleText = subtitle.uppercased() as NSString

            let subSize = subtitleText.size(withAttributes: subtitleAttrs)
            let titleSize = titleText.size(withAttributes: titleAttrs)

            let subY = size.height - textBottomMargin - subSize.height
            let titleY = subY - titleSize.height - 8

            titleText.draw(at: CGPoint(x: textMarginLeft, y: titleY), withAttributes: titleAttrs)
            subtitleText.draw(at: CGPoint(x: textMarginLeft, y: subY), withAttributes: subtitleAttrs)
        }

        return saveImage(image, quality: 0.85)
    }

    // MARK: - Helper Image Resizer
    private func resizeIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let width = image.size.width
        let height = image.size.height
        let largest = max(width, height)

        guard largest > maxDimension else { return image }

        let ratio = maxDimension / largest
        let newSize = CGSize(width: width * ratio, height: height * ratio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
