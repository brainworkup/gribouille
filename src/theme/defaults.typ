// Default theme values consumed by the renderer.
// Each surface is stored as an element record (element-text / element-line /
// element-rect / element-blank). The renderer queries records via
// `resolve-element` in `theme.typ`; user themes override individual records or
// pass spot-overrides via the master `text` / `line` / `rect` keys.

#import "elements.typ": element-line, element-rect, element-text

// Read document colours injected by the typst-render Quarto extension via
// --input flags. Falls back to black/white when rendering standalone.
#let _tr-ink = {
  let v = sys.inputs.at("typst-render-foreground", default: "")
  if v == "" { black } else { rgb(v) }
}
#let _tr-paper = {
  let v = sys.inputs.at("typst-render-background", default: "")
  if v == "" { white } else { rgb(v) }
}

#let default-theme = (
  kind: "theme",
  name: "grey",

  // Base colours
  ink: _tr-ink,
  paper: _tr-paper,
  accent: rgb("#3366FF"),

  // Inherited base records (cascade parents for descendant surfaces)
  text: element-text(size: 9pt, weight: "regular"),
  line: element-line(thickness: 0.5pt),
  rect: element-rect(),

  // Per-surface text records
  axis-text: element-text(size: 8pt),
  axis-title: element-text(size: 9pt),
  legend-text: element-text(size: 8pt),
  legend-title: element-text(size: 8pt),
  strip-text: element-text(size: 8pt),
  plot-title: element-text(size: 12pt, weight: "bold"),
  plot-subtitle: element-text(size: 9pt),
  plot-caption: element-text(size: 8pt),

  // Per-surface line records
  panel-grid: element-line(thickness: 0.5pt),
  axis-line: element-line(thickness: 0.5pt),

  // Per-surface rect records
  panel-background: element-rect(),
  strip-background: element-rect(),

  // Bare scalars
  tick-length: 0.1,
  tick-labels: true,
)

#let merge-theme(user) = {
  if user == none { return default-theme }
  let merged = default-theme
  for (k, v) in user.pairs() {
    merged.insert(k, v)
  }
  merged
}

// Resolve a colour by walking the inheritance chain.
// Returns the first non-none value from key, then each parent key in order,
// then falls back to black.
#let resolve-colour(theme, key, ..parents) = {
  let v = theme.at(key, default: none)
  if v != none { return v }
  for p in parents.pos() {
    let pv = theme.at(p, default: none)
    if pv != none { return pv }
  }
  black
}

// Resolve a non-colour field (size, weight, family, angle) by walking the
// inheritance chain. Returns the first non-none value, then the default.
#let resolve-field(theme, key, ..parents, fallback: none) = {
  let v = theme.at(key, default: none)
  if v != none { return v }
  for p in parents.pos() {
    let pv = theme.at(p, default: none)
    if pv != none { return pv }
  }
  fallback
}
