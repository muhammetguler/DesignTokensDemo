// Tools/codegen.py tarafından üretildi. Elle düzenlemeyin.

import SwiftUI

public enum DesignTokens {

    public struct Token: Identifiable, Hashable {
        public let name: String   // "surface/primary"
        public let key: String    // "surfacePrimary"
        public let lightHex: String
        public let darkHex: String
        public var id: String { key }
        public var color: Color { Color(key, bundle: .main) }
    }

    /// `accent/brand`
    public static let accentBrand = Color("accentBrand", bundle: .main)
    /// `badge/soldout`
    public static let badgeSoldout = Color("badgeSoldout", bundle: .main)
    /// `border/default`
    public static let borderDefault = Color("borderDefault", bundle: .main)
    /// `status/success`
    public static let statusSuccess = Color("statusSuccess", bundle: .main)
    /// `surface/overlay`
    public static let surfaceOverlay = Color("surfaceOverlay", bundle: .main)
    /// `surface/primary`
    public static let surfacePrimary = Color("surfacePrimary", bundle: .main)
    /// `surface/secondary`
    public static let surfaceSecondary = Color("surfaceSecondary", bundle: .main)
    /// `text/on-accent`
    public static let textOnAccent = Color("textOnAccent", bundle: .main)
    /// `text/on-badge`
    public static let textOnBadge = Color("textOnBadge", bundle: .main)
    /// `text/primary`
    public static let textPrimary = Color("textPrimary", bundle: .main)
    /// `text/secondary`
    public static let textSecondary = Color("textSecondary", bundle: .main)

    public static let all: [Token] = [
        Token(name: "accent/brand", key: "accentBrand", lightHex: "#FFD200", darkHex: "#FFD200"),
        Token(name: "badge/soldout", key: "badgeSoldout", lightHex: "#E30A17", darkHex: "#FF4D57"),
        Token(name: "border/default", key: "borderDefault", lightHex: "#EBEBEB", darkHex: "#262626"),
        Token(name: "status/success", key: "statusSuccess", lightHex: "#1A9E4B", darkHex: "#3DBE6A"),
        Token(name: "surface/overlay", key: "surfaceOverlay", lightHex: "#00000080", darkHex: "#00000080"),
        Token(name: "surface/primary", key: "surfacePrimary", lightHex: "#FFFFFF", darkHex: "#1A1A1A"),
        Token(name: "surface/secondary", key: "surfaceSecondary", lightHex: "#F5F5F5", darkHex: "#262626"),
        Token(name: "text/on-accent", key: "textOnAccent", lightHex: "#1A1A1A", darkHex: "#1A1A1A"),
        Token(name: "text/on-badge", key: "textOnBadge", lightHex: "#FFFFFF", darkHex: "#FFFFFF"),
        Token(name: "text/primary", key: "textPrimary", lightHex: "#1A1A1A", darkHex: "#FFFFFF"),
        Token(name: "text/secondary", key: "textSecondary", lightHex: "#737373", darkHex: "#EBEBEB"),
    ]
}
