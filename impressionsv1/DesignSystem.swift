//
//  DesignSystem.swift
//  impressionsv1
//
//  Design tokens — colors, typography, spacing, shadows, borders.
//  Source of truth for all visual decisions in the app.
//

import SwiftUI

// MARK: - Color Palette

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
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }

    // ── Backgrounds & Neutrals ─────────────────────────────────────────────
    /// Warm off-white — all screen backgrounds  rgba(253,246,232,1)
    static let appCream       = Color(red: 253/255, green: 246/255, blue: 232/255)
    /// Charcoal — primary text, headings  rgba(50,50,50,1)
    static let appCharcoal    = Color(red:  50/255, green:  50/255, blue:  50/255)

    // ── 6 Primary Accents ─────────────────────────────────────────────────
    /// Olive  rgba(122,161,35,1)
    static let appOlive       = Color(red: 122/255, green: 161/255, blue:  35/255)
    static let appOliveLight  = Color(red: 222/255, green: 231/255, blue: 200/255)

    /// Amber  rgba(251,195,0,1)
    static let appAmber       = Color(red: 251/255, green: 195/255, blue:   0/255)
    static let appAmberLight  = Color(red: 255/255, green: 247/255, blue: 233/255)

    /// Blue  rgba(0,167,251,1)
    static let appBlue        = Color(red:   0/255, green: 167/255, blue: 251/255)
    static let appBlueLight   = Color(red: 218/255, green: 240/255, blue: 250/255)

    /// Pink  rgba(245,130,170,1)
    static let appPink        = Color(red: 245/255, green: 130/255, blue: 170/255)
    static let appPinkLight   = Color(red: 252/255, green: 225/255, blue: 238/255)

    /// Teal  rgba(20,178,153,1)
    static let appTeal        = Color(red:  20/255, green: 178/255, blue: 153/255)
    static let appTealLight   = Color(red: 204/255, green: 242/255, blue: 235/255)

    /// Purple  rgba(138,82,200,1)
    static let appPurple      = Color(red: 138/255, green:  82/255, blue: 200/255)
    static let appPurpleLight = Color(red: 237/255, green: 225/255, blue: 255/255)

    // ── Status / CTA ──────────────────────────────────────────────────────
    /// Deep red — own-content badge, CTA  rgba(164,51,51,1)
    static let appCrimson     = Color(red: 164/255, green:  51/255, blue:  51/255)

    // ── Neutral UI surfaces ────────────────────────────────────────────────
    static let appGreige      = Color(hex: "C8C0B0")   // inactive / placeholder
    static let appOffWhite    = Color(hex: "F7F4EE")   // inputs, chips

    // ── Backward-compat aliases ────────────────────────────────────────────
    static let appBrown       = appCharcoal             // was warm-brown, now charcoal per spec
    static let appForestGreen = appOlive
    static let appBackground  = appCream
    static let cardBackground = appOffWhite
    static let textPrimary    = appCharcoal
    static let textSecondary  = Color(hex: "7A6A5A")
    static let textTertiary   = Color(hex: "9E9080")
    static let appBorder      = Color(hex: "D8D0C4")
    static let appDarkText    = appCharcoal
    static let appGrayText    = Color(hex: "9E9080")
    static let appYellow      = appAmber
    static let appGreen       = appOlive
}

// MARK: - Typography

struct AppFont {
    // ── HK Grotesk ────────────────────────────────────────────────────────
    private static let hkLight     = "HKGrotesk-Light"
    private static let hkRegular   = "HKGrotesk-Regular"
    private static let hkMedium    = "HKGrotesk-Medium"
    private static let hkSemiBold  = "HKGrotesk-SemiBold"
    private static let hkBold      = "HKGrotesk-Bold"
    private static let hkExtraBold = "HKGrotesk-ExtraBold"

    // ── Caveat ────────────────────────────────────────────────────────────
    private static let caveatMedium = "Caveat-Medium"

    // ── Named scale (from design spec) ────────────────────────────────────
    /// 28pt ExtraBold — app title / hero
    static let display    = Font.custom(hkExtraBold,  size: 28)
    /// 22pt ExtraBold — H1 section title
    static let h1         = Font.custom(hkExtraBold,  size: 22)
    /// 20pt ExtraBold — H2 sub-section
    static let h2         = Font.custom(hkExtraBold,  size: 20)
    /// 16pt Bold — H3 card heading
    static let h3         = Font.custom(hkBold,       size: 16)
    /// 14pt Bold — body large: labels, buttons
    static let bodyLarge  = Font.custom(hkBold,       size: 14)
    /// 12pt Medium — body regular: primary text
    static let body       = Font.custom(hkMedium,     size: 12)
    /// 11pt Regular — body small: secondary / supporting text  rgba(0,0,0,0.45)
    static let bodySmall  = Font.custom(hkRegular,    size: 11)
    /// 9pt SemiBold — captions: section headers, tags  rgba(0,0,0,0.35)
    static let caption    = Font.custom(hkSemiBold,   size: 9)
    /// 9pt Medium — micro labels  rgba(0,0,0,0.40)
    static let micro      = Font.custom(hkMedium,     size: 9)

    // ── Caveat ────────────────────────────────────────────────────────────
    /// 16pt Caveat-Medium — order menu items on amber widget
    static let orderItem  = Font.custom(caveatMedium, size: 16)
    /// 19pt Caveat-Medium — larger order item display
    static let orderItemLg = Font.custom(caveatMedium, size: 19)

    // ── Legacy / compat helpers used across the app ────────────────────────
    static func title() -> Font       { h1 }
    static func metadata() -> Font    { Font.custom(hkRegular,  size: 13) }
    static func author() -> Font      { Font.custom(hkMedium,   size: 14) }
    static func timestamp() -> Font   { Font.custom(hkRegular,  size: 13) }

    static let title2      = h2
    static let title3      = h3
    static let largeTitle  = Font.custom(hkExtraBold, size: 34)
    static let bodyBold    = Font.custom(hkSemiBold,  size: 17)
    static let button      = Font.custom(hkSemiBold,  size: 17)
    static let buttonSmall = Font.custom(hkMedium,    size: 15)
    static let caption2    = Font.custom(hkRegular,   size: 11)
}

// MARK: - Spacing

struct Spacing {
    static let xxs: CGFloat = 4
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 20
    static let xxl: CGFloat = 24
}

// MARK: - Corner Radius

struct CornerRadius {
    static let card:   CGFloat = 16
    static let widget: CGFloat = 12
    static let button: CGFloat = 14
    static let image:  CGFloat = 12
    // Backward compat
    static let small:  CGFloat = 8
    static let medium: CGFloat = 12
    static let large:  CGFloat = 16
    static let xlarge: CGFloat = 24
}

// MARK: - Shadows

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

struct AppShadow {
    /// Micro  0 1px 3px rgba(0,0,0,0.06)
    static let micro  = Shadow(color: .black.opacity(0.06), radius: 3,  x: 0, y: 1)
    /// Small  0 2px 8px rgba(0,0,0,0.10)
    static let small  = Shadow(color: .black.opacity(0.10), radius: 8,  x: 0, y: 2)
    /// Medium 0 3px 12px rgba(0,0,0,0.14)
    static let medium = Shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 3)
    /// Large  0 4px 20px rgba(0,0,0,0.20)
    static let large  = Shadow(color: .black.opacity(0.20), radius: 20, x: 0, y: 4)
    /// Modal  0 8px 40px rgba(0,0,0,0.25)
    static let modal  = Shadow(color: .black.opacity(0.25), radius: 40, x: 0, y: 8)
    // Backward compat
    static let cardSoft   = small
    static let cardMedium = medium
    static let extraLarge = large

    /// Color-tinted widget shadow at ~26% opacity
    static func tinted(_ color: Color) -> Shadow {
        Shadow(color: color.opacity(0.26), radius: 10, x: 0, y: 3)
    }
}

// MARK: - Border Styles

struct BorderStyle {
    static let thin:       CGFloat = 0.5
    static let regular:    CGFloat = 1.0
    static let medium:     CGFloat = 1.5
    static let thick:      CGFloat = 2.0
    static let extraThick: CGFloat = 4.0

    static let card         = Color.black.opacity(0.07)
    static let input        = Color.black.opacity(0.10)
    static let lightBorder  = Color.white.opacity(0.20)
    static let mediumBorder = Color.white.opacity(0.40)
    static let solidBorder  = Color.white
}

// MARK: - Card Colors (backward compat)

enum CardColor {
    case yellow, pink, green, blue, teal, purple, orange, neutral

    var color: Color {
        switch self {
        case .yellow:  return .appAmber
        case .pink:    return .appPink
        case .green:   return .appOlive
        case .blue:    return .appBlue
        case .teal:    return .appTeal
        case .purple:  return .appPurple
        case .orange:  return Color(hex: "FF9800")
        case .neutral: return .cardBackground
        }
    }
}

// MARK: - Prompt Category (backward compat)

enum PromptCategory: String, CaseIterable {
    case craftDetails  = "Craft & Details"
    case service       = "Service"
    case expectations  = "Expectations"
    case social        = "Social"

    var color: CardColor {
        switch self {
        case .craftDetails:  return .purple
        case .service:       return .pink
        case .expectations:  return .blue
        case .social:        return .teal
        }
    }
    // Note: .scheme is defined in PromptSelectionView.swift (owns CategoryScheme struct)
}

// MARK: - View Extensions

extension View {
    /// Crimson filled — primary CTA
    func primaryButton(shadow: Shadow? = nil) -> some View {
        self
            .font(AppFont.button)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.appCrimson)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.button, style: .continuous))
            .applyShadow(shadow ?? AppShadow.small)
    }

    /// Greige filled — disabled / inactive CTA
    func inactiveButton() -> some View {
        self
            .font(AppFont.button)
            .foregroundColor(Color(hex: "A09888"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(hex: "EEEBE5"))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.button, style: .continuous))
    }

    /// Outlined — secondary action
    func secondaryButton(borderWidth: CGFloat = BorderStyle.regular, shadow: Shadow? = nil) -> some View {
        self
            .font(AppFont.button)
            .foregroundColor(.appCrimson)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.appOffWhite)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.button, style: .continuous)
                    .strokeBorder(Color.appGreige, lineWidth: borderWidth)
            )
            .applyShadow(shadow)
    }

    func applyShadow(_ shadow: Shadow?) -> some View {
        Group {
            if let s = shadow {
                self.shadow(color: s.color, radius: s.radius, x: s.x, y: s.y)
            } else {
                self
            }
        }
    }
}
