///! Custom theme builder.
///!
///! `theme` accepts per-element overrides via named arguments. Keys can be
///! either low-level fields (same names as the internal `default-theme`) or
///! structured element records from @element-text, @element-line,
///! @element-rect, and @element-blank.
///!
///! Base element keys (`text`, `line`, `rect`) set inherited parent fields:
///! specific child keys (e.g. `axis-text`) take priority at render time.

#let _apply-text(out, prefix, value) = {
  if value.size != none { out.insert(prefix + "-size", value.size) }
  if value.colour != none { out.insert(prefix + "-colour", value.colour) }
  if value.weight != none { out.insert(prefix + "-weight", value.weight) }
  if value.angle != none { out.insert(prefix + "-angle", value.angle) }
  if value.family != none { out.insert(prefix + "-family", value.family) }
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

  if key == "axis-text" and el-kind == "element-text" {
    return _apply-text(out, "axis-text", value)
  }
  if key == "axis-title" and el-kind == "element-text" {
    return _apply-text(out, "axis-title", value)
  }
  if key == "legend-text" and el-kind == "element-text" {
    return _apply-text(out, "legend-text", value)
  }
  if key == "legend-title" and el-kind == "element-text" {
    return _apply-text(out, "legend-title", value)
  }
  if key == "strip-text" and el-kind == "element-text" {
    return _apply-text(out, "strip-text", value)
  }
  if key == "plot-title" and el-kind == "element-text" {
    return _apply-text(out, "plot-title", value)
  }
  if key == "plot-subtitle" and el-kind == "element-text" {
    return _apply-text(out, "plot-subtitle", value)
  }
  if key == "plot-caption" and el-kind == "element-text" {
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

/// Build a custom theme from per-element overrides.
///
/// Pass named arguments like `axis-title: element-text(size: 12pt)` or
/// low-level keys like `panel-fill: rgb("#f7f0e7")`. Structured element
/// records are translated into the flat theme fields consumed internally.
///
/// Base element keys (`text`, `line`, `rect`) set inherited parent values
/// for all descendant elements. Specific keys always take priority at render time.
///
/// @category Themes
/// @stability stable
/// @since 0.0.1
///
/// @param ..fields Named per-element overrides. Keys may be structured
///   (`text`, `line`, `rect`, `axis-title`, `panel-grid`, ...)
///   or flat (`axis-title-size`, `panel-fill`, ...).
///
/// @returns Theme dictionary consumed by @plot.
///
/// @examples Custom panel and grid colours via structured element records.
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
/// @examples Hide elements entirely with @element-blank, useful for very
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
/// @see @theme-grey, @theme-minimal, @theme-classic, @theme-void, @element-text, @element-line, @element-rect, @element-blank
#let theme(..fields) = {
  let out = (kind: "theme", name: "custom")
  for (k, v) in fields.named().pairs() {
    out = _apply-element(out, k, v)
  }
  out
}
