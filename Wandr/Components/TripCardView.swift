import SwiftUI

public struct TripCardView: View {
    public let trip: Trip
    public var onToggleFavorite: (() -> Void)? = nil

    public init(trip: Trip, onToggleFavorite: (() -> Void)? = nil) {
        self.trip = trip
        self.onToggleFavorite = onToggleFavorite
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            heroImageSection
            footerInfoSection
        }
        .wandrCardStyle(cornerRadius: 18)
    }

    // MARK: - Hero Image Section
    @ViewBuilder
    private var heroImageSection: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncDiskImage(filename: trip.heroPhotoFilename, placeholderSymbol: "mountain.2.fill")
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()

            // Gradient for text legibility
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.4), Color.black.opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Top Badges (Category & Favorite)
            VStack {
                HStack {
                    categoryBadge
                    Spacer()
                    favoriteButton
                }
                .padding(12)
                Spacer()
            }

            // Title & Destination Text on Hero
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.title)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 1)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11))
                    Text("\(trip.destination), \(trip.countryOrRegion)")
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundColor(.white.opacity(0.92))
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
        .frame(height: 200)
    }

    // MARK: - Badges
    @ViewBuilder
    private var categoryBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: trip.category.icon)
                .font(.system(size: 11, weight: .bold))
            Text(trip.category.title)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(trip.category.accentColor.opacity(0.92))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var favoriteButton: some View {
        Button {
            onToggleFavorite?()
        } label: {
            Image(systemName: trip.isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(trip.isFavorite ? Color(red: 0.95, green: 0.28, blue: 0.35) : .white)
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Footer Info Section
    @ViewBuilder
    private var footerInfoSection: some View {
        HStack(alignment: .center) {
            // Date and duration
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(WandrTheme.terracotta)
                Text(trip.startDate.formattedRange(to: trip.endDate))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(WandrTheme.textSecondary)
            }

            Spacer()

            // Duration Pill
            Text("\(trip.durationInDays) \(trip.durationInDays == 1 ? "Day" : "Days")")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(WandrTheme.deepForest)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(WandrTheme.deepForest.opacity(0.12))
                .clipShape(Capsule())

            // Memory and photo count
            Text("\(trip.entries.count) Memories • \(trip.allPhotoFilenames.count) Photos")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(WandrTheme.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
