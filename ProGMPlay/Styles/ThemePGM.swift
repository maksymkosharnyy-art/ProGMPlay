import SwiftUI

struct ThemePGM {
    static let deepPurple = Color(hex: "#1A1025")
    static let midnightOnyx = Color(hex: "#0F0F1A")
    static let royalAmethyst = Color(hex: "#3A1C5A")
    static let metallicGold = Color(hex: "#D4AF37")
    static let navyBlue = Color(hex: "#1A1A3A")
    static let darkCell = Color(hex: "#2C2C54")
    static let lightCell = Color(hex: "#474787")
    
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "#FFE066"), metallicGold, Color(hex: "#997A00")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static func primaryBackground(for theme: String) -> LinearGradient {
        switch theme {
        case "Royal Amethyst":
            return LinearGradient(colors: [royalAmethyst, deepPurple], startPoint: .top, endPoint: .bottom)
        case "Midnight Onyx":
            return LinearGradient(colors: [midnightOnyx, Color(hex: "#05050A")], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [deepPurple, navyBlue], startPoint: .top, endPoint: .bottom)
        }
    }
    
    static let cardBackground = LinearGradient(
        colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Board Themes
    
    static func boardLight(for theme: String) -> Color {
        switch theme {
        case "Royal Amethyst": return Color(hex: "#EAD9FF")
        case "Midnight Onyx": return Color(hex: "#B0B0C0")
        default: return Color(hex: "#F0EED2") // Classic Gold (Cream)
        }
    }
    
    static func boardDark(for theme: String) -> Color {
        switch theme {
        case "Royal Amethyst": return Color(hex: "#6A3C9A")
        case "Midnight Onyx": return Color(hex: "#3D3D52")
        default: return Color(hex: "#4A785C") // Classic Gold (Green)
        }
    }
    
    static func accentColor(for theme: String) -> Color {
        switch theme {
        case "Royal Amethyst": return Color(hex: "#9B5DE5")
        case "Midnight Onyx": return Color(hex: "#707070")
        default: return metallicGold
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
