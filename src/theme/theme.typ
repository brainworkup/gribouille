///! Custom theme builder.
///!
///! `theme` accepts per-element overrides via named arguments. Keys can be
///! either low-level fields (same names as the internal `default-theme`) or
///! structured element records from \@element-text, \@element-line,
///! \@element-rect, and \@element-blank.
///!
///! Base element keys (`text`, `line`, `rect`) set inherited parent fields:
///! specific child keys (e.g. `axis-text`) take priority at render time.

#let _surface-parent = (
  "axis-text": "text",
  "axis-title": "text",
  "legend-text": "text",
  "legend-title": "text",
  "strip-text": "text",
  "plot-title": "text",
  "plot-subtitle": "text",
  "plot-caption": "text",
  "panel-grid": "line",
  "axis-line": "line",
  "panel-background": "rect",
  "strip-background": "rect",
)

#let _merge-element(base, top) = {
  let out = base
  for (k, v) in top.pairs() {
    if k == "kind" { continue }
    if v == none { continue }
    out.insert(k, v)
  }
  if top.at("kind", default: none) != none {
    out.insert("kind", top.kind)
  }
  out
}

/// Resolve a surface's element record by merging surface → parent → empty.
///
/// Returns a dict shaped like the underlying element constructor, with `kind`
/// set to the most specific element kind in the cascade. Fields not set
/// anywhere remain `none`; the renderer is responsible for hardcoded
/// fallbacks (e.g. colour → `theme.ink`).
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@param surface Surface key, e.g. `"axis-text"`, `"panel-grid"`.
/// \@returns Element record with cascaded fields.
#let resolve-element(theme, surface) = {
  let parent-key = _surface-parent.at(surface, default: none)
  let surface-record = theme.at(surface, default: none)
  let parent-record = if parent-key != none {
    theme.at(parent-key, default: none)
  } else { none }

  let merged = if parent-record != none { parent-record } else { (:) }
  if surface-record != none {
    merged = _merge-element(merged, surface-record)
  }
  merged
}

/// Whether a text surface is configured to evaluate strings as Typst markup.
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@param surface Text surface key, e.g. `"axis-text"`.
/// \@returns Boolean.
#let is-typst(theme, surface) = {
  let el = resolve-element(theme, surface)
  el.at("kind", default: none) == "element-typst"
}

/// Resolve a text surface into a flat dict ready for `text(...)` arguments.
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@param surface Text surface key, e.g. `"axis-text"`.
/// \@returns Dict with `size`, `fill`, `weight`, `family`, `angle`, `typst`.
#let _text-style(theme, surface) = {
  let el = resolve-element(theme, surface)
  let colour = el.at("colour", default: none)
  let weight = el.at("weight", default: none)
  (
    size: el.at("size", default: 9pt),
    fill: if colour != none { colour } else { theme.ink },
    weight: if weight != none { weight } else { "regular" },
    family: el.at("family", default: none),
    angle: el.at("angle", default: 0deg),
    typst: el.at("kind", default: none) == "element-typst",
  )
}

/// Resolve a line surface into a stroke dict, or `none` for `element-blank`.
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@param surface Line surface key, e.g. `"panel-grid"`.
/// \@param fallback-colour Colour used when neither surface nor parent set one.
/// \@returns Stroke dict `(paint, thickness)`, or `none` to skip drawing.
#let _line-stroke(theme, surface, fallback-colour: none) = {
  let el = resolve-element(theme, surface)
  if el.at("kind", default: none) == "element-blank" { return none }
  let colour = el.at("colour", default: none)
  let thickness = el.at("thickness", default: none)
  if thickness == 0pt { return none }
  let paint = if colour != none {
    colour
  } else if fallback-colour != none {
    fallback-colour
  } else { theme.ink }
  (
    paint: paint,
    thickness: if thickness != none { thickness } else { 0.5pt },
  )
}

/// Resolve a rect surface into a fill colour, or `none` for `element-blank`.
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@param surface Rect surface key, e.g. `"panel-background"`.
/// \@param fallback Fill used when neither surface nor parent sets one.
/// \@returns Colour, or `none` to skip drawing.
#let _rect-fill(theme, surface, fallback: none) = {
  let el = resolve-element(theme, surface)
  if el.at("kind", default: none) == "element-blank" { return none }
  let fill = el.at("fill", default: none)
  if fill != none { return fill }
  fallback
}

#let _apply-element(out, key, value) = {
  if value == none { return out }
  // Element records (text / line / rect / blank / typst) and bare scalars
  // both pass through verbatim. The renderer queries records via
  // `resolve-element`.
  out.insert(key, value)
  out
}

#let _apply-overrides(out, fields) = {
  for (k, v) in fields.named().pairs() {
    out = _apply-element(out, k, v)
  }
  out
}

/// Build a custom theme from per-element overrides.
///
/// Pass named arguments like `axis-title: element-text(size: 12pt)` or `panel-grid: element-blank()`.
/// Each surface is stored as an element record; the renderer reads them via `resolve-element` with cascade `surface → parent → defaults`.
///
/// Surfaces:
///
/// - Base elements: `text`, `line`, `rect`. Set inherited parents that descendants fall back to.
/// - Text surfaces: `axis-text`, `axis-title`, `legend-text`, `legend-title`, `strip-text`, `plot-title`, `plot-subtitle`, `plot-caption`. Each accepts `element-text()` or `element-typst()`.
/// - Line surfaces: `panel-grid`, `axis-line`. Each accepts `element-line()` or `element-blank()`.
/// - Rect surfaces: `panel-background`, `strip-background`. Each accepts `element-rect()` or `element-blank()`.
///
/// Bare scalars: `ink`, `paper`, `accent`, `tick-length`, `tick-labels`.
///
/// \@category Themes
/// \@stability stable
/// \@since 0.0.1
///
/// \@param ..fields Named per-element overrides; see the description above for the full catalogue of structured and flat keys.
///
/// \@returns Theme dictionary consumed by \@plot.
///
/// \@examples Custom panel and grid colours via structured element records.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(
///     text: element-text(colour: rgb("#2c3e50")),
///     panel-background: element-rect(fill: rgb("#f7f0e7")),
///     panel-grid: element-line(colour: rgb("#d9cfbf")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Hide elements entirely with \@element-blank, useful for very
/// minimalist figures.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   theme: theme(
///     panel-grid: element-blank(),
///     axis-line: element-blank(),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-minimal, \@theme-classic, \@theme-void, \@element-text, \@element-line, \@element-rect, \@element-blank
#let theme(..fields) = {
  let out = (kind: "theme", name: "custom")
  _apply-overrides(out, fields)
}
