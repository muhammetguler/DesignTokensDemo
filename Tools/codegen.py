#!/usr/bin/env python3
"""
tokens.json -> Colors.xcassets + DesignTokens.swift + Themes.json

Light ve Dark modlar xcassets'e (derleme zamanı) gider.
Diğer modlar Themes.json'a (çalışma zamanı teması) gider.

Kullanım:  python3 Tools/codegen.py [--check]
  --check : dosyaları yazmaz, güncel olup olmadığını kontrol eder (CI için)
"""

import json
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Tools" / "tokens.json"
GEN = ROOT / "DesignTokensDemo" / "Generated"
ASSETS = GEN / "Colors.xcassets"
SWIFT_OUT = GEN / "DesignTokens.swift"
THEMES_OUT = GEN / "Themes.json"

LIGHT = "Light"
DARK = "Dark"
HEADER = "// Tools/codegen.py tarafından üretildi. Elle düzenlemeyin.\n"


TR = str.maketrans("çğıöşüÇĞİÖŞÜ", "cgiosuCGIOSU")


def slugify(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", value.translate(TR).lower()).strip("-")


def camel(name: str) -> str:
    parts = re.split(r"[/\-_]", name)
    return parts[0] + "".join(p[:1].upper() + p[1:] for p in parts[1:])


def parse_hex(value: str):
    """#RGB, #RRGGBB veya #RRGGBBAA -> (r, g, b, a) 0-255 / 0-1"""
    h = value.strip().lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    if len(h) == 6:
        h += "FF"
    if len(h) != 8:
        raise ValueError(f"Geçersiz renk: {value}")
    r, g, b, a = (int(h[i:i + 2], 16) for i in (0, 2, 4, 6))
    return r, g, b, a / 255


def components(value: str) -> dict:
    r, g, b, a = parse_hex(value)
    return {
        "color-space": "srgb",
        "components": {
            "red": f"0x{r:02X}",
            "green": f"0x{g:02X}",
            "blue": f"0x{b:02X}",
            "alpha": f"{a:.3f}",
        },
    }


def colorset(light: str, dark: str | None) -> dict:
    entries = [{"idiom": "universal", "color": components(light)}]
    if dark and dark != light:
        entries.append({
            "idiom": "universal",
            "appearances": [{"appearance": "luminosity", "value": "dark"}],
            "color": components(dark),
        })
    return {"colors": entries, "info": {"author": "codegen", "version": 1}}


def build() -> dict[Path, str]:
    """Üretilecek tüm dosyaları {yol: içerik} olarak döndürür."""
    data = json.loads(SRC.read_text(encoding="utf-8"))
    colors: dict = data["colors"]
    modes: list[str] = data.get("modes", [LIGHT])

    if LIGHT not in modes:
        raise SystemExit(f"'{LIGHT}' modu tokens.json içinde yok.")

    files: dict[Path, str] = {}
    dumps = lambda o: json.dumps(o, indent=2, ensure_ascii=False) + "\n"

    # --- Colors.xcassets ---
    files[ASSETS / "Contents.json"] = dumps({"info": {"author": "codegen", "version": 1}})
    for name, values in sorted(colors.items()):
        key = camel(name)
        files[ASSETS / f"{key}.colorset" / "Contents.json"] = dumps(
            colorset(values[LIGHT], values.get(DARK))
        )

    # --- Themes.json: Light dışındaki ek modlar ---
    themes = []
    for mode in modes:
        if mode in (LIGHT, DARK):
            continue
        overrides = {
            camel(n): v[mode]
            for n, v in sorted(colors.items())
            if mode in v and v[mode] != v[LIGHT]
        }
        if overrides:
            slug = slugify(mode)
            themes.append({"id": slug, "name": mode, "overrides": overrides})
    files[THEMES_OUT] = dumps(themes)

    # --- DesignTokens.swift ---
    lines = [
        HEADER,
        "import SwiftUI\n",
        "public enum DesignTokens {",
        "",
        "    public struct Token: Identifiable, Hashable {",
        "        public let name: String   // \"surface/primary\"",
        "        public let key: String    // \"surfacePrimary\"",
        "        public let lightHex: String",
        "        public let darkHex: String",
        "        public var id: String { key }",
        "        public var color: Color { Color(key, bundle: .main) }",
        "    }",
        "",
    ]
    for name, values in sorted(colors.items()):
        key = camel(name)
        lines.append(f"    /// `{name}`")
        lines.append(f"    public static let {key} = Color(\"{key}\", bundle: .main)")
    lines.append("")
    lines.append("    public static let all: [Token] = [")
    for name, values in sorted(colors.items()):
        key = camel(name)
        light = values[LIGHT].upper()
        dark = values.get(DARK, values[LIGHT]).upper()
        lines.append(
            f'        Token(name: "{name}", key: "{key}", '
            f'lightHex: "{light}", darkHex: "{dark}"),'
        )
    lines.append("    ]")
    lines.append("}")
    files[SWIFT_OUT] = "\n".join(lines) + "\n"
    return files


def main() -> None:
    check = "--check" in sys.argv
    files = build()

    if check:
        stale = [
            p for p, c in files.items()
            if not p.exists() or p.read_text(encoding="utf-8") != c
        ]
        extra = [
            p for p in ASSETS.rglob("Contents.json") if p not in files
        ] if ASSETS.exists() else []
        if stale or extra:
            for p in stale + extra:
                print(f"güncel değil: {p.relative_to(ROOT)}")
            raise SystemExit(1)
        print("Üretilen dosyalar güncel.")
        return

    if ASSETS.exists():
        shutil.rmtree(ASSETS)  # silinen token'lar artakalmasın
    for path, content in files.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
    print(f"{len(files)} dosya yazıldı -> {GEN.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
