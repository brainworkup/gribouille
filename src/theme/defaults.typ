// Default theme values consumed by the renderer.
// Each surface is stored as an element record (element-text / element-line /
// element-rect / element-blank). The renderer queries records via
// `resolve-element` in `theme.typ`; user themes override individual records or
// pass spot-overrides via the master `text` / `line` / `rect` keys.

#import "elements.typ": (
  element-geom, element-line, element-rect, element-text, margin,
)
#import "theme.typ": default-stroke-thickness

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
  line: element-line(stroke: default-stroke-thickness),
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
  panel-grid: element-line(stroke: default-stroke-thickness),
  axis-line: element-line(stroke: default-stroke-thickness),
  axis-ticks: element-line(stroke: default-stroke-thickness),
  legend-ticks: element-line(stroke: 0.3pt),

  // Per-surface rect records
  panel-background: element-rect(),
  plot-background: element-rect(),
  strip-background: element-rect(),
  legend-background: element-rect(),
  legend-bar: element-rect(stroke: 0.2pt),

  // Layer-default aesthetics shared across supporting geoms. All-`none`
  // entries leave the per-geom hardcoded fallback in place; users override
  // selectively via `theme(geom: element-geom(fill: ..., linewidth: ...))`.
  geom: element-geom(),

  // Plot canvas margin (each side: a Typst length or `auto` for the
  // renderer's dynamic default).
  plot-margin: margin(),

  tick-length: 0.1cm,
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

// Resolve a theme colour key, falling back to black when unset.
#let resolve-colour(theme, key) = {
  let v = theme.at(key, default: none)
  if v == none { black } else { v }
}

