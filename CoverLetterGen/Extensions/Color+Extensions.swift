import SwiftUI

extension Color {
    // Tailwind Slate Colors
    static let slate50 = Color(hex: "f8fafc")
    static let slate100 = Color(hex: "f1f5f9")
    static let slate200 = Color(hex: "e2e8f0")
    static let slate300 = Color(hex: "cbd5e1")
    static let slate400 = Color(hex: "94a3b8")
    static let slate500 = Color(hex: "64748b")
    static let slate600 = Color(hex: "475569")
    static let slate700 = Color(hex: "334155")
    static let slate800 = Color(hex: "1e293b")
    static let slate900 = Color(hex: "0f172a") // Tweaked darker for bg
    
    static let primaryBlue = Color(hex: "3b82f6") // tailwind blue-500
    
    // Semantic Colors
    static let backgroundLight = slate50
    static let backgroundDark = Color(hex: "0b1120")
    static let cardLight = Color.white
    static let cardDark = slate800
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
