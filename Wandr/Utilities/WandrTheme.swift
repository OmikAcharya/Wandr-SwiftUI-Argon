import SwiftUI
import UIKit

public enum WandrTheme {
    // Primary Editorial Palette
    public static let terracotta = Color(red: 0.82, green: 0.38, blue: 0.27)
    public static let deepForest = Color(red: 0.14, green: 0.26, blue: 0.22)
    public static let amberGold = Color(red: 0.89, green: 0.64, blue: 0.23)
    public static let oceanTeal = Color(red: 0.18, green: 0.49, blue: 0.55)

    // Semantic Adaptive Surfaces
    public static var warmPaper: Color {
        Color(UIColor.systemGroupedBackground)
    }

    public static var cardSurface: Color {
        Color(UIColor.secondarySystemGroupedBackground)
    }

    public static var cardSurfaceTertiary: Color {
        Color(UIColor.tertiarySystemGroupedBackground)
    }

    public static var textPrimary: Color {
        Color(UIColor.label)
    }

    public static var textSecondary: Color {
        Color(UIColor.secondaryLabel)
    }

    public static var divider: Color {
        Color(UIColor.separator)
    }

    // Gradient Presets
    public static let warmSunsetGradient = LinearGradient(
        colors: [Color(red: 0.88, green: 0.42, blue: 0.25), Color(red: 0.82, green: 0.28, blue: 0.32)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let oceanBreezeGradient = LinearGradient(
        colors: [Color(red: 0.18, green: 0.49, blue: 0.55), Color(red: 0.10, green: 0.32, blue: 0.45)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let forestHazeGradient = LinearGradient(
        colors: [Color(red: 0.14, green: 0.32, blue: 0.25), Color(red: 0.08, green: 0.20, blue: 0.16)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Wandr Card Style View Modifier
public struct WandrCardModifier: ViewModifier {
    public var cornerRadius: CGFloat = 18
    @Environment(\.colorScheme) private var colorScheme

    public init(cornerRadius: CGFloat = 18) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .background(WandrTheme.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        colorScheme == .dark
                            ? Color.white.opacity(0.12)
                            : Color.black.opacity(0.06),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.35)
                    : Color.black.opacity(0.06),
                radius: 10,
                x: 0,
                y: 4
            )
    }
}

public extension View {
    func wandrCardStyle(cornerRadius: CGFloat = 18) -> some View {
        modifier(WandrCardModifier(cornerRadius: cornerRadius))
    }
}
