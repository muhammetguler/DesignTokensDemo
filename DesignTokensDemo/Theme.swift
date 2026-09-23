import SwiftUI

/// Çalışma zamanı tema override'ı.
/// Şu an uygulamanın içinden (Themes.json) okunuyor; üretimde aynı yapı
/// CDN / kendi backend'iniz / Remote Config üzerinden gelir.
struct ThemeOverride: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let overrides: [String: String]
}

@MainActor
final class ThemeStore: ObservableObject {
    @Published var active: ThemeOverride?
    let available: [ThemeOverride]

    init() {
        available = Self.loadBundled()
    }

    private static func loadBundled() -> [ThemeOverride] {
        guard
            let url = Bundle.main.url(forResource: "Themes", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let themes = try? JSONDecoder().decode([ThemeOverride].self, from: data)
        else {
            return []   // tema okunamazsa uygulama varsayılanla çalışmaya devam eder
        }
        return themes
    }

    /// Token'ın rengini verir. Aktif tema o token'ı override ediyorsa onu,
    /// etmiyorsa asset catalog'daki (light/dark duyarlı) rengi döndürür.
    func color(_ key: String) -> Color {
        if let hex = active?.overrides[key], let color = Color(hex: hex) {
            return color
        }
        return Color(key, bundle: .main)
    }

    func color(_ token: DesignTokens.Token) -> Color {
        color(token.key)
    }

    /// Ekranda göstermek için geçerli hex değeri.
    func hex(_ token: DesignTokens.Token, dark: Bool) -> String {
        active?.overrides[token.key] ?? (dark ? token.darkHex : token.lightHex)
    }
}

extension Color {
    /// #RGB, #RRGGBB ve #RRGGBBAA destekler.
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespaces)
        if h.hasPrefix("#") { h.removeFirst() }
        if h.count == 3 { h = h.map { "\($0)\($0)" }.joined() }
        if h.count == 6 { h += "FF" }
        guard h.count == 8, let value = UInt32(h, radix: 16) else { return nil }
        self.init(
            .sRGB,
            red: Double((value >> 24) & 0xFF) / 255,
            green: Double((value >> 16) & 0xFF) / 255,
            blue: Double((value >> 8) & 0xFF) / 255,
            opacity: Double(value & 0xFF) / 255
        )
    }
}
