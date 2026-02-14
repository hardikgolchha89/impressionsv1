//
//  DesignSystem.swift
//  Impressions
//
//  Design system for the Impressions app
//  Based on Figma mockups - Feb 2026
//

import SwiftUI

// MARK: - Colors
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
    
    // App Colors
    static let appPink = Color(hex: "F4C2C2")
    static let appBlue = Color(hex: "A8D8EA")
    static let appYellow = Color(hex: "FFD93D")
    static let appGreen = Color(hex: "6BCB77")
    static let appDarkText = Color(hex: "4A3933")
    static let appGrayText = Color(hex: "8E8E8E")
    
    // Backward compatibility - keep existing color names
    static let appBackground = Color(hex: "1A1A1A")
    static let cardBackground = Color(hex: "2A2A2A")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "CCCCCC")
    static let textTertiary = Color(hex: "999999")
    static let appBorder = Color(hex: "3A3A3A")
}

// MARK: - Typography
struct AppFont {
    static func title() -> Font {
        .system(size: 20, weight: .bold)
    }
    
    // Note: body() function removed to avoid conflict with body property below
    // Use AppFont.body (property) for backward compatibility
    
    static func metadata() -> Font {
        .system(size: 13, weight: .regular)
    }
    
    static func author() -> Font {
        .system(size: 14, weight: .medium)
    }
    
    static func timestamp() -> Font {
        .system(size: 13, weight: .regular)
    }
    
    // Note: button() function removed to avoid conflict with button property below
    // Use AppFont.button (property) for backward compatibility
    
    // Backward compatibility - keep existing static properties
    // Note: 'title()' function exists above, so we don't include 'title' property to avoid conflict
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .semibold)
    static let title3 = Font.system(size: 20, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyBold = Font.system(size: 17, weight: .semibold)
    static let bodySmall = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 13, weight: .regular)
    static let caption2 = Font.system(size: 11, weight: .regular)
    static let button = Font.system(size: 17, weight: .semibold) // Backward compatibility property
    static let buttonSmall = Font.system(size: 15, weight: .medium)
}

// MARK: - Spacing
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    
    // Backward compatibility - keep old values
    static let xxs: CGFloat = 4
}

// MARK: - Corner Radius
struct CornerRadius {
    static let card: CGFloat = 16
    static let widget: CGFloat = 12
    static let button: CGFloat = 8
    static let image: CGFloat = 12
    
    // Backward compatibility - map old names to new ones
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 24
}

// MARK: - Shadows (for backward compatibility)
struct AppShadow {
    static let small = Shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    static let large = Shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
    static let extraLarge = Shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 12)
    static let cardSoft = Shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    static let cardMedium = Shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Border Styles (for backward compatibility)
struct BorderStyle {
    static let thin: CGFloat = 1
    static let medium: CGFloat = 2
    static let thick: CGFloat = 4
    static let extraThick: CGFloat = 6
    static let lightBorder = Color.white.opacity(0.2)
    static let mediumBorder = Color.white.opacity(0.4)
    static let solidBorder = Color.white
}

// MARK: - Card Colors (for backward compatibility)
enum CardColor {
    case yellow
    case pink
    case green
    case blue
    case orange
    case neutral
    
    var color: Color {
        switch self {
        case .yellow: return .appYellow
        case .pink: return .appPink
        case .green: return .appGreen
        case .blue: return .appBlue
        case .orange: return Color(hex: "FF9800")
        case .neutral: return .cardBackground
        }
    }
}

// MARK: - Prompt Categories (for backward compatibility)
enum PromptCategory: String, CaseIterable {
    case craftDetails = "Craft & Details"
    case service = "Service"
    case expectations = "Expectations"
    case social = "Social"
    
    var color: CardColor {
        switch self {
        case .craftDetails: return .yellow
        case .service: return .pink
        case .expectations: return .green
        case .social: return .blue
        }
    }
}

// MARK: - View Extensions (for backward compatibility)
extension View {
    func primaryButton(shadow: Shadow? = AppShadow.medium) -> some View {
        self
            .font(AppFont.button) // Using backward compatibility property
            .foregroundColor(.black)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.white)
            .cornerRadius(CornerRadius.large)
            .applyShadow(shadow)
    }
    
    func secondaryButton(borderWidth: CGFloat = BorderStyle.thin, shadow: Shadow? = nil) -> some View {
        self
            .font(AppFont.button) // Using backward compatibility property
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .stroke(Color.appBorder, lineWidth: borderWidth)
            )
            .applyShadow(shadow)
    }
    
    private func applyShadow(_ shadow: Shadow?) -> some View {
        Group {
            if let shadow = shadow {
                self.shadow(
                    color: shadow.color,
                    radius: shadow.radius,
                    x: shadow.x,
                    y: shadow.y
                )
            } else {
                self
            }
        }
    }
}
