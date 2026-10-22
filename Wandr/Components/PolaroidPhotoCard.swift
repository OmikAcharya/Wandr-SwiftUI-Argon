import SwiftUI

public struct PolaroidPhotoCard: View {
    public let filename: String?
    public var caption: String = ""
    public var date: Date? = nil
    public var tiltAngle: Double = 0

    @Environment(\.colorScheme) private var colorScheme

    public init(
        filename: String?,
        caption: String = "",
        date: Date? = nil,
        tiltAngle: Double = 0
    ) {
        self.filename = filename
        self.caption = caption
        self.date = date
        self.tiltAngle = tiltAngle
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Photo viewport
            AsyncDiskImage(filename: filename, placeholderSymbol: "photo.fill", contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .aspectRatio(1.0, contentMode: .fit)
                .clipped()
                .overlay(
                    Rectangle()
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )

            // Bottom Caption Bar
            VStack(spacing: 3) {
                if !caption.isEmpty {
                    Text(caption)
                        .font(.system(.caption, design: .serif))
                        .fontWeight(.medium)
                        .foregroundColor(textColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                if let date = date {
                    Text(date.shortMonthDay)
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(textColor.opacity(0.65))
                }
            }
            .frame(height: caption.isEmpty && date == nil ? 14 : 32)
        }
        .padding(10)
        .padding(.bottom, 6)
        .background(frameColor)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.12),
            radius: 8,
            x: 0,
            y: 4
        )
        .rotationEffect(.degrees(tiltAngle))
    }

    private var frameColor: Color {
        colorScheme == .dark
            ? Color(red: 0.18, green: 0.18, blue: 0.20)
            : Color(red: 0.98, green: 0.97, blue: 0.95)
    }

    private var textColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.9)
            : Color(red: 0.22, green: 0.20, blue: 0.18)
    }
}
