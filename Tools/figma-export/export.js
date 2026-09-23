// Figma plugin (development): renk değişkenlerini Tools/tokens.json
// şemasında dışa aktarır. Önceki sürümden farkı:
//   - alias'ları (başka değişkene referans) gerçek renge kadar çözer
//   - alpha'yı korur (#RRGGBBAA)
//   - her koleksiyonun modlarını birleştirip tek mod listesi üretir
//
// manifest.json içinde "main": "export.js" olmalı.

(async () => {
  const cols = await figma.variables.getLocalVariableCollectionsAsync();

  // modeId -> mod adı
  const modeName = {};
  for (const col of cols) {
    for (const m of col.modes) modeName[m.modeId] = m.name;
  }

  const toHex = (c) => {
    const p = (x) => Math.round(x * 255).toString(16).padStart(2, "0").toUpperCase();
    const a = c.a === undefined ? 1 : c.a;
    return "#" + p(c.r) + p(c.g) + p(c.b) + (a < 1 ? p(a) : "");
  };

  // Alias zincirini takip eder. modeId eşleşmezse koleksiyonun ilk moduna düşer.
  async function resolve(variable, modeId, depth = 0) {
    if (depth > 10) return null; // döngü koruması
    let value = variable.valuesByMode[modeId];
    if (value === undefined) {
      const first = Object.keys(variable.valuesByMode)[0];
      value = variable.valuesByMode[first];
    }
    if (value && value.type === "VARIABLE_ALIAS") {
      const target = await figma.variables.getVariableByIdAsync(value.id);
      if (!target) return null;
      return resolve(target, modeId, depth + 1);
    }
    return value && typeof value === "object" && "r" in value ? toHex(value) : null;
  }

  const colors = {};
  const modes = new Set();

  for (const col of cols) {
    for (const id of col.variableIds) {
      const v = await figma.variables.getVariableByIdAsync(id);
      if (!v || v.resolvedType !== "COLOR") continue;

      const entry = {};
      for (const m of col.modes) {
        const hex = await resolve(v, m.modeId);
        if (hex) {
          entry[m.name] = hex;
          modes.add(m.name);
        }
      }
      // Tek modlu koleksiyonlar (primitives) genelde dışa aktarılmaz;
      // sadece birden fazla modu olanları ya da yayınlanan değişkenleri alın.
      if (col.modes.length > 1 || !v.hiddenFromPublishing) {
        colors[v.name] = entry;
      }
    }
  }

  const output = { modes: [...modes], colors };
  const json = JSON.stringify(output, null, 2);

  figma.showUI(
    `<textarea id="t" style="width:100%;height:88%;font:12px monospace">${
      json.replace(/</g, "&lt;")
    }</textarea>
     <button onclick="document.getElementById('t').select();document.execCommand('copy')">
       Kopyala
     </button>`,
    { width: 520, height: 600 }
  );
})().catch((e) => figma.closePlugin("Hata: " + e.message));
