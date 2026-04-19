// Default theme values consumed by the renderer.
// User themes override individual fields; missing fields fall back here.

#let default-theme = (
  kind: "theme",
  name: "grey",

  // Base colours (ggplot2 v4: ink / paper / accent)
  ink: black,
  paper: white,
  accent: rgb("#3366FF"),

  // Panel / grid / axis structural fields
  // none = element-blank (don't draw)
  panel-fill: rgb("#f2f2f2"),
  grid-colour: white,
  grid-thickness: 0.5pt,
  axis-colour: black,
  axis-thickness: 0.5pt,
  tick-length: 0.1,
  tick-labels: true,

  // Line base (set via theme(line: element-line(...)))
  line-colour: none,
  line-thickness: none,

  // Rect base (set via theme(rect: element-rect(...)))
  rect-fill: none,

  // Text base (set via theme(text: element-text(...)))
  text-colour: none,
  text-size: 9pt,
  text-weight: "regular",
  text-family: none,

  // axis-text
  axis-text-size: 8pt,
  axis-text-colour: none,
  axis-text-weight: none,
  axis-text-family: none,
  axis-text-angle: none,

  // axis-title
  axis-title-size: 9pt,
  axis-title-colour: none,
  axis-title-weight: none,
  axis-title-family: none,

  // legend
  legend-text-size: 8pt,
  legend-text-colour: none,
  legend-text-weight: none,
  legend-title-size: 8pt,
  legend-title-colour: none,
  legend-title-weight: none,

  // strip (facet labels)
  strip-fill: none,
  strip-text-size: 8pt,
  strip-text-colour: none,
  strip-text-weight: none,
  strip-text-family: none,

  // plot labels
  plot-title-size: 12pt,
  plot-title-colour: none,
  plot-title-weight: "bold",
  plot-subtitle-size: 9pt,
  plot-subtitle-colour: none,
  plot-caption-size: 8pt,
  plot-caption-colour: none,
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
