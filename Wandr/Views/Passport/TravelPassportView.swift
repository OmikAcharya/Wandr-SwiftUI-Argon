import SwiftUI

public struct TravelPassportView: View {
    @EnvironmentObject private var store: WandrStore
    @State private var showResetAlert: Bool = false

    public init() {}

    private var stats: TravelStatistics {
        store.statistics
    }

    private var travelerTitle: String {
        let days = stats.totalDaysTraveled
        if days < 5 {
            return "Wayfarer"
        } else if days < 12 {
            return "Voyager"
        } else if days < 25 {
            return "Globetrotter"
        } else {
            return "Master Cartographer"
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    passportBioHeader
                    destinationStampsSection
                    moodAndVibeBreakdownSection
                    dataManagementSection
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Passport")
            .alert("Restore Sample Trips?", isPresented: $showResetAlert) {
                Button("Restore", role: .destructive) {
                    store.resetToSampleData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will replace current entries with the default sample travel journeys.")
            }
        }
    }

    // MARK: - 1. Passport Bio Header
    @ViewBuilder
    private var passportBioHeader: some View {
        VStack(spacing: 16) {
            // Gold Embossed Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PASSPORT OF WANDERLUST")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .tracking(2.5)
                        .foregroundColor(WandrTheme.amberGold)

                    Text(travelerTitle.uppercased())
                        .font(.system(size: 22, weight: .heavy, design: .serif))
                        .foregroundColor(.white)
                }

                Spacer()

                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 34))
                    .foregroundColor(WandrTheme.amberGold.opacity(0.85))
            }

            Divider()
                .overlay(Color.white.opacity(0.15))

            // Stats Matrix
            HStack(spacing: 0) {
                passportStat(number: "\(stats.totalTrips)", label: "JOURNEYS")
                passportStat(number: "\(stats.totalDaysTraveled)", label: "DAYS LOGGED")
                passportStat(number: "\(stats.totalWordsWritten)", label: "WORDS")
                passportStat(number: "\(stats.totalPhotos)", label: "PHOTOS")
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.18, blue: 0.22),
                    Color(red: 0.08, green: 0.12, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(WandrTheme.amberGold.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func passportStat(number: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(number)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundColor(WandrTheme.amberGold.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 2. Destination Stamps Grid
    @ViewBuilder
    private var destinationStampsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("PASSPORT STAMPS")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(store.trips.count) Visited")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(WandrTheme.terracotta)
            }
            .padding(.horizontal, 16)

            if store.trips.isEmpty {
                Text("No stamps earned yet. Embark on your first adventure!")
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 14) {
                    ForEach(store.trips.indices, id: \.self) { index in
                        let trip = store.trips[index]
                        let tilt = (index % 2 == 0 ? -3.5 : 3.0) * Double((index % 3) + 1) * 0.4
                        inkPassportStamp(for: trip, tilt: tilt)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    private func inkPassportStamp(for trip: Trip, tilt: Double) -> some View {
        let code = destinationCode(for: trip.destination)
        let color = trip.category.accentColor

        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: trip.category.icon)
                    .font(.system(size: 11, weight: .bold))
                Text(code)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .tracking(2)
            }
            .foregroundColor(color)

            Text(trip.destination.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(color.opacity(0.85))
                .lineLimit(1)

            Divider()
                .overlay(color.opacity(0.4))
                .frame(width: 80)

            Text(trip.startDate.stampDateString)
                .font(.system(size: 8, weight: .heavy, design: .monospaced))
                .tracking(1)
                .foregroundColor(color.opacity(0.75))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    color.opacity(0.6),
                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 3])
                )
        )
        .rotationEffect(.degrees(tilt))
    }

    private func destinationCode(for destination: String) -> String {
        let letters = destination.filter { $0.isLetter }.uppercased()
        if letters.count >= 3 {
            return String(letters.prefix(3))
        }
        return (letters + "EXP").prefix(3).description
    }

    // MARK: - 3. Mood & Vibe Breakdown
    @ViewBuilder
    private var moodAndVibeBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("TRAVEL MOOD & VIBE PROFILE")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)

            VStack(spacing: 12) {
                let totalMemories = max(1, stats.totalEntries)
                ForEach(stats.moodCounts, id: \.0) { mood, count in
                    let ratio = CGFloat(count) / CGFloat(totalMemories)
                    HStack(spacing: 8) {
                        Text(mood.emoji)
                        Text(mood.label)
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: 85, alignment: .leading)

                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                                    .frame(height: 8)

                                Capsule()
                                    .fill(mood.color)
                                    .frame(width: max(8, proxy.size.width * ratio), height: 8)
                            }
                        }
                        .frame(height: 8)

                        Text("\(count)")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(width: 24, alignment: .trailing)
                    }
                }
            }
            .padding(16)
            .wandrCardStyle(cornerRadius: 16)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - 4. Settings & Data Management
    @ViewBuilder
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DATA & DEMO SETTINGS")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)

            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Reset to Sample Expeditions")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(WandrTheme.textPrimary)
                        Text("Rebuilds default travel stories, memories, and procedural postcards.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                Button {
                    showResetAlert = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Restore Sample Trips")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(WandrTheme.terracotta)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .wandrCardStyle(cornerRadius: 16)
            .padding(.horizontal, 16)
        }
    }
}
