import SwiftUI

public struct EntryTimelineRow: View {
    public let entry: JournalEntry
    public var isLast: Bool = false
    public var onPhotoTap: ((String) -> Void)? = nil

    public init(
        entry: JournalEntry,
        isLast: Bool = false,
        onPhotoTap: ((String) -> Void)? = nil
    ) {
        self.entry = entry
        self.isLast = isLast
        self.onPhotoTap = onPhotoTap
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 14) {
            timelineNodeSection
            diaryCardSection
        }
    }

    // MARK: - Left Timeline Node Section
    @ViewBuilder
    private var timelineNodeSection: some View {
        VStack(spacing: 0) {
            // Circular / rounded date badge
            VStack(spacing: 1) {
                Text(entry.date.shortMonthDay.components(separatedBy: " ").first ?? "")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(WandrTheme.terracotta)
                Text(entry.date.shortMonthDay.components(separatedBy: " ").last ?? "")
                    .font(.system(size: 14, weight: .heavy, design: .serif))
                    .foregroundColor(WandrTheme.textPrimary)
            }
            .frame(width: 44, height: 44)
            .background(WandrTheme.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(WandrTheme.terracotta.opacity(0.4), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

            // Continuous vertical connector line
            if !isLast {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [WandrTheme.terracotta.opacity(0.4), WandrTheme.terracotta.opacity(0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2)
                    .frame(minHeight: 40)
                    .padding(.top, 4)
            }
        }
        .frame(width: 44)
    }

    // MARK: - Right Diary Card Section
    @ViewBuilder
    private var diaryCardSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerRow
            locationAndReadTimeRow
            contentPreview
            photoStrip
        }
        .padding(14)
        .wandrCardStyle(cornerRadius: 16)
    }

    @ViewBuilder
    private var headerRow: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(entry.title)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(WandrTheme.textPrimary)
                .lineLimit(1)

            Spacer()

            // Mood Emoji Pill
            HStack(spacing: 3) {
                Text(entry.mood.emoji)
                    .font(.system(size: 11))
                Text(entry.mood.label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(entry.mood.color.opacity(0.15))
            .foregroundColor(entry.mood.color)
            .clipShape(Capsule())

            // Weather Icon
            Image(systemName: entry.weather.symbol)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(WandrTheme.oceanTeal)
        }
    }

    @ViewBuilder
    private var locationAndReadTimeRow: some View {
        HStack(spacing: 8) {
            if !entry.locationName.isEmpty {
                HStack(spacing: 3) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(WandrTheme.terracotta)
                    Text(entry.locationName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(WandrTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text("\(entry.readingTimeMinutes) min read")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(WandrTheme.textSecondary)
        }
    }

    @ViewBuilder
    private var contentPreview: some View {
        Text(entry.content)
            .font(.system(size: 13, weight: .regular, design: .serif))
            .lineSpacing(3)
            .lineLimit(3)
            .foregroundColor(WandrTheme.textPrimary.opacity(0.9))
    }

    @ViewBuilder
    private var photoStrip: some View {
        if !entry.photoFilenames.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(entry.photoFilenames, id: \.self) { photo in
                        Button {
                            onPhotoTap?(photo)
                        } label: {
                            AsyncDiskImage(filename: photo, placeholderSymbol: "photo", contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}
