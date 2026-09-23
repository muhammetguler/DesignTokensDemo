import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themes: ThemeStore
    @State private var scheme: ColorScheme = .light

    private var grouped: [(String, [DesignTokens.Token])] {
        Dictionary(grouping: DesignTokens.all) { $0.name.split(separator: "/").first.map(String.init) ?? "diğer" }
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value.sorted { $0.name < $1.name }) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ProductCardPreview()
                        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                        .listRowBackground(themes.color("surfaceSecondary"))
                }

                ForEach(grouped, id: \.0) { group, tokens in
                    Section(group) {
                        ForEach(tokens) { token in
                            SwatchRow(token: token, dark: scheme == .dark)
                        }
                    }
                }
            }
            .navigationTitle("Design Tokens")
            .safeAreaInset(edge: .bottom) { controls }
        }
        .environment(\.colorScheme, scheme)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            Picker("Görünüm", selection: $scheme) {
                Text("Light").tag(ColorScheme.light)
                Text("Dark").tag(ColorScheme.dark)
            }
            .pickerStyle(.segmented)

            if !themes.available.isEmpty {
                Picker("Tema", selection: $themes.active) {
                    Text("Varsayılan").tag(ThemeOverride?.none)
                    ForEach(themes.available) { theme in
                        Text(theme.name).tag(ThemeOverride?.some(theme))
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
        .background(.bar)
    }
}

private struct SwatchRow: View {
    @EnvironmentObject private var themes: ThemeStore
    let token: DesignTokens.Token
    let dark: Bool

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(themes.color(token))
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.primary.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(token.name).font(.callout)
                Text(token.key).font(.caption2).foregroundStyle(.secondary)
            }

            Spacer()

            Text(themes.hex(token, dark: dark))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}

/// Figma'daki ProductCard'ın token'larla kurulmuş hali.
private struct ProductCardPreview: View {
    @EnvironmentObject private var themes: ThemeStore

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            card(soldOut: false)
            card(soldOut: true)
        }
        .frame(maxWidth: .infinity)
    }

    private func card(soldOut: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(themes.color("surfaceSecondary"))
                .frame(height: 80)

            Text("Kablosuz Kulaklık")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(themes.color("textPrimary"))

            Text("1.299,00 TL")
                .font(.caption)
                .foregroundStyle(themes.color("textSecondary"))

            if soldOut {
                Text("Tükendi")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(themes.color("textOnBadge"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themes.color("badgeSoldout"), in: .rect(cornerRadius: 6))
            } else {
                Text("Sepete Ekle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(themes.color("textOnAccent"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(themes.color("accentBrand"), in: .rect(cornerRadius: 8))
            }
        }
        .padding(12)
        .background(themes.color("surfacePrimary"), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(themes.color("borderDefault"))
        )
    }
}

#Preview {
    ContentView().environmentObject(ThemeStore())
}
