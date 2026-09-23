# DesignTokensDemo

Figma renk değişkenlerinden iOS renk katmanını üreten örnek proje.

```
Figma Variables
  -> Tools/figma-export/export.js   (plugin, alias'ları çözer)
  -> Tools/tokens.json              (tek kaynak, repoda)
  -> Tools/codegen.py               (CI'da çalışır)
  -> DesignTokensDemo/Generated/    (Colors.xcassets + DesignTokens.swift + Themes.json)
```

## Kullanım

```bash
python3 Tools/codegen.py           # üret
python3 Tools/codegen.py --check   # güncel mi (CI)
open DesignTokensDemo.xcodeproj    # Xcode 16+
```

## Neyin nereye gittiği

| Mod | Nereye | Ne zaman değişir |
|---|---|---|
| Light | Colors.xcassets (Any Appearance) | Derleme zamanı, sürüm gerekir |
| Dark | Colors.xcassets (Dark Appearance) | Derleme zamanı, sürüm gerekir |
| Diğer (30 Ağustos vb.) | Themes.json | Çalışma zamanı, sürüm gerekmez |

`Generated/` klasörü commit'lenir. Elle düzenlenmez; `tokens.json` değiştirilir.
