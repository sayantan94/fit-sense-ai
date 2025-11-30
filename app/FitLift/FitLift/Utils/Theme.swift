//
//  Theme.swift
//  FitLift
//
//  Created by Sayantan <sayantanbhow@gmail.com>
//

import SwiftUI

enum Theme {
    // Main colors
    static let background = Color(hex: "0a0a0f")
    static let cardBackground = Color.white.opacity(0.05)
    static let cardBackgroundGradient = LinearGradient(
        colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Accent color
    static let accent = Color(hex: "4ecdc4")

    // Workout type colors
    static let push = Color(hex: "ff6b6b")
    static let pull = Color(hex: "4ecdc4")
    static let shoulders = Color(hex: "ffe66d")
    static let legs = Color(hex: "a66cff")

    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.5)
    static let textTertiary = Color.white.opacity(0.35)

    // Border
    static let cardBorder = Color.white.opacity(0.06)
    static let divider = Color.white.opacity(0.05)

    // Tab bar
    static let tabBarBackground = Color(hex: "141419").opacity(0.95)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}