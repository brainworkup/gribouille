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
#let is-typst(theme, surface) = {
  let el = resolve-element(theme, surface)
  el.at("kind", default: none) == "element-typst"
}

#let _apply-text(out, prefix, value) = {
  if value.size != none { out.insert(prefix + "-size", value.size) }
  if value.colour != none { out.insert(prefix + "-colour", value.colour) }
  if value.weight != none { out.insert(prefix + "-weight", value.weight) }
  if value.angle != none { out.insert(prefix + "-angle", value.angle) }
  if value.family != none { out.insert(prefix + "-family", value.family) }
  if value.at("kind", default: none) == "element-typst" {
    out.insert(prefix + "-typst", true)
  }
  out
}

#let _apply-element(out, key, value) = {
  if value == none { return out }
  let el-kind = if type(value) == dictionary {
    value.at("kind", default: none)
  } else { none }

  // ── Base element keys ──────────────────────────────────────────────────────

  if key == "text" and el-kind == "element-text" {
    if value.size != none { out.insert("text-size", value.size) }
    if value.colour != none { out.insert("text-colour", value.colour) }
    if value.weight != none { out.insert("text-weight", value.weight) }
    if value.family != none { out.insert("text-family", value.family) }
    return out
  }

  if key == "line" and el-kind == "element-line" {
    if value.colour != none { out.insert("line-colour", value.colour) }
    if value.thickness != none { out.insert("line-thickness", value.thickness) }
    return out
  }

  if key == "rect" and el-kind == "element-rect" {
    if value.fill != none { out.insert("rect-fill", value.fill) }
    return out
  }

  // ── Specific text element keys ─────────────────────────────────────────────

  let _is-text-element = el-kind == "element-text" or el-kind == "element-typst"

  if key == "axis-text" and _is-text-element {
    return _apply-text(out, "axis-text", value)
  }
  if key == "axis-title" and _is-text-element {
    return _apply-text(out, "axis-title", value)
  }
  if key == "legend-text" and _is-text-element {
    return _apply-text(out, "legend-text", value)
  }
  if key == "legend-title" and _is-text-element {
    return _apply-text(out, "legend-title", value)
  }
  if key == "strip-text" and _is-text-element {
    return _apply-text(out, "strip-text", value)
  }
  if key == "plot-title" and _is-text-element {
    return _apply-text(out, "plot-title", value)
  }
  if key == "plot-subtitle" and _is-text-element {
    return _apply-text(out, "plot-subtitle", value)
  }
  if key == "plot-caption" and _is-text-element {
    return _apply-text(out, "plot-caption", value)
  }

  // ── Rect element keys ──────────────────────────────────────────────────────

  if key == "panel-background" and el-kind == "element-rect" {
    if value.fill != none { out.insert("panel-fill", value.fill) }
    if value.stroke != none { out.insert("panel-stroke", value.stroke) }
    return out
  }

  // ── Line element keys ──────────────────────────────────────────────────────

  if key == "panel-grid" and el-kind == "element-line" {
    if value.colour != none { out.insert("grid-colour", value.colour) }
    if value.thickness != none { out.insert("grid-thickness", value.thickness) }
    return out
  }
  if key == "panel-grid" and el-kind == "element-blank" {
    out.insert("grid-colour", none)
    return out
  }
  if key == "axis-line" and el-kind == "element-line" {
    if value.colour != none { out.insert("axis-colour", value.colour) }
    if value.thickness != none { out.insert("axis-thickness", value.thickness) }
    return out
  }
  if key == "axis-line" and el-kind == "element-blank" {
    out.insert("axis-colour", none)
    return out
  }

  // ── Low-level passthrough ──────────────────────────────────────────────────
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
/// Pass named arguments like `axis-title: element-text(size: 12pt)` or low-level keys like `panel-fill: rgb("#f7f0e7")`.
/// Structured element records are translated into the flat theme fields consumed internally.
///
/// Base element keys (`text`, `line`, `rect`) set inherited parent values for all descendant elements.
/// Specific keys always take priority at render time.
///
/// Structured element keys translate \@element-text, \@element-line, \@element-rect, \@element-blank, and \@element-typst records into the flat fields the renderer consumes:
///
/// - Base elements: `text`, `line`, `rect`. These set inherited parents that descendants fall back to.
/// - Text elements: `axis-text`, `axis-title`, `legend-text`, `legend-title`, `strip-text`, `plot-title`, `plot-subtitle`, `plot-caption`. Each accepts `element-text()` or `element-typst()`.
/// - Rect elements: `panel-background`.
/// - Line elements: `panel-grid`, `axis-line`. Both also accept `element-blank()` to hide them entirely.
///
/// Flat fields override individual values directly and mirror the keys of the internal default theme:
///
/// - Base colours: `ink`, `paper`, `accent`.
/// - Panel, grid, axis: `panel-fill`, `grid-colour`, `grid-thickness`, `axis-colour`, `axis-thickness`, `tick-length`, `tick-labels`.
/// - Line base: `line-colour`, `line-thickness`.
/// - Rect base: `rect-fill`.
/// - Text base: `text-colour`, `text-size`, `text-weight`, `text-family`.
/// - Axis text: `axis-text-size`, `axis-text-colour`, `axis-text-weight`, `axis-text-family`, `axis-text-angle`.
/// - Axis title: `axis-title-size`, `axis-title-colour`, `axis-title-weight`, `axis-title-family`.
/// - Legend text: `legend-text-size`, `legend-text-colour`, `legend-text-weight`.
/// - Legend title: `legend-title-size`, `legend-title-colour`, `legend-title-weight`.
/// - Strip (facet labels): `strip-fill`, `strip-text-size`, `strip-text-colour`, `strip-text-weight`, `strip-text-family`.
/// - Plot title: `plot-title-size`, `plot-title-colour`, `plot-title-weight`.
/// - Plot subtitle: `plot-subtitle-size`, `plot-subtitle-colour`.
/// - Plot caption: `plot-caption-size`, `plot-caption-colour`.
/// - Typst-markup passthrough (boolean, normally set via `element-typst()`): `axis-text-typst`, `axis-title-typst`, `legend-text-typst`, `legend-title-typst`, `strip-text-typst`, `plot-title-typst`, `plot-subtitle-typst`, `plot-caption-typst`.
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
