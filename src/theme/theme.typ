///! Custom theme builder.
///!
///! `theme` accepts per-element overrides via named arguments. Keys can be
///! either low-level fields (same names as the internal `default-theme`) or
///! structured element records from \@element-text, \@element-line,
///! \@element-rect, and \@element-blank.
///!
///! Base element keys (`text`, `line`, `rect`) set inherited parent fields:
///! specific child keys (e.g. `axis-text`) take priority at render time.

#import "elements.typ": element-geom

#let _surface-parent = {
  let out = (
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
    "axis-ticks": "line",
    "panel-background": "rect",
    "plot-background": "rect",
    "strip-background": "rect",
  )
  // Each axis family gains per-axis (-x, -y) and per-side (-x-bottom, -x-top,
  // -y-left, -y-right) variants that cascade up to their family.
  for fam in ("axis-text", "axis-title", "axis-line", "axis-ticks") {
    out.insert(fam + "-x", fam)
    out.insert(fam + "-y", fam)
    out.insert(fam + "-x-bottom", fam + "-x")
    out.insert(fam + "-x-top", fam + "-x")
    out.insert(fam + "-y-left", fam + "-y")
    out.insert(fam + "-y-right", fam + "-y")
  }
  out
}

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

/// Resolve a surface's element record by walking its inheritance chain root-to-leaf and merging in order.
///
/// The cascade follows `_surface-parent` to the root, then merges each populated record back down so the most specific surface wins.
/// Returns a dict shaped like the underlying element constructor, with `kind` set to the most specific element kind in the cascade.
/// Fields not set anywhere remain `none`; the renderer is responsible for hardcoded fallbacks (e.g. colour → `theme.ink`).
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@param surface Surface key, e.g. `"axis-text-x-bottom"`, `"panel-grid"`.
/// \@returns Element record with cascaded fields.
#let resolve-element(theme, surface) = {
  let chain = ()
  let cur = surface
  while cur != none {
    chain.push(cur)
    cur = _surface-parent.at(cur, default: none)
  }
  let merged = (:)
  for key in chain.rev() {
    let rec = theme.at(key, default: none)
    if rec != none { merged = _merge-element(merged, rec) }
  }
  merged
}

/// Resolve a per-side scalar theme key with a three-step cascade: `<base>-<side>` → `<base>-<axis>` → `<base>`.
///
/// Returns `0pt` if no level of the cascade is set. Used for `tick-length` and any future scalar that mirrors the element cascade shape.
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@param base Scalar key root, e.g. `"tick-length"`.
/// \@param side Side suffix, e.g. `"x-bottom"`, `"y-right"`.
/// \@param axis Axis suffix, `"x"` or `"y"`.
/// \@returns The most specific value set, falling back to base, then `0pt`.
#let _scalar-cascade(theme, base, side, axis) = {
  let v = theme.at(base + "-" + side, default: none)
  if v != none { return v }
  let av = theme.at(base + "-" + axis, default: none)
  if av != none { return av }
  theme.at(base, default: 0pt)
}

// Empty layer-default record reused whenever the theme has no `geom` slot
// or carries a non-element-geom record (theme drift, partial user theme).
// Hoisted to module scope so per-render lookups don't re-allocate it.
#let _EMPTY-GEOM-DEFAULTS = element-geom()

/// Resolve `theme.geom` to a flat layer-defaults dict.
///
/// Returns the shape produced by \@element-geom; `none` slots leave per-geom
/// fallbacks intact. The fall-through to an empty record is deliberate —
/// keeps rendering robust when a partial user theme drops the `geom` key.
/// `ink` / `paper` / `accent` slots inherit the theme-level scalars when
/// `element-geom` left them unset, mirroring ggplot2 v4's role-oriented
/// defaults.
/// Geoms resolve once at layer setup and consult the fields they support.
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@returns Element-geom record (always present; defaults are all `none`).
#let geom-defaults(theme) = {
  let g = theme.at("geom", default: none)
  if g == none or g.at("kind", default: none) != "element-geom" {
    g = _EMPTY-GEOM-DEFAULTS
  }
  for role in ("ink", "paper", "accent") {
    if g.at(role, default: none) == none {
      g.insert(role, theme.at(role, default: none))
    }
  }
  g
}

/// Pick a `theme.geom` field, falling back when the slot is `none`.
///
/// \@internal
/// \@param defaults Element-geom record from \@geom-defaults.
/// \@param field Field name to read (e.g. `"fill"`, `"colour"`, `"linewidth"`).
/// \@param fallback Value returned when the slot is unset.
/// \@returns The slot value or the fallback.
#let geom-default(defaults, field, fallback) = {
  let v = defaults.at(field, default: none)
  if v != none { v } else { fallback }
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

// Default per-side text margin: every side `auto` so each consumption site
// supplies its own renderer fallback.
#let _empty-margin = (
  kind: "margin",
  top: auto,
  right: auto,
  bottom: auto,
  left: auto,
)

// Normalise a `margin` field on a text element to the four-side dict shape
// the renderer expects. Accepts `none`, a `margin(...)` record, or any other
// value (treated as `none`). Missing sides default to `auto`.
#let _normalise-text-margin(value) = {
  if (
    value == none
      or type(value) != dictionary
      or value.at("kind", default: none) != "margin"
  ) {
    return _empty-margin
  }
  (
    kind: "margin",
    top: value.at("top", default: auto),
    right: value.at("right", default: auto),
    bottom: value.at("bottom", default: auto),
    left: value.at("left", default: auto),
  )
}

/// Resolve a text surface into a flat dict ready for `text(...)` arguments.
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@param surface Text surface key, e.g. `"axis-text"`.
/// \@returns Dict with `size`, `fill`, `weight`, `typst`, `margin`.
#let _text-style(theme, surface) = {
  let el = resolve-element(theme, surface)
  let colour = el.at("colour", default: none)
  let weight = el.at("weight", default: none)
  (
    size: el.at("size", default: 9pt),
    fill: if colour != none { colour } else { theme.ink },
    weight: if weight != none { weight } else { "regular" },
    typst: el.at("kind", default: none) == "element-typst",
    margin: _normalise-text-margin(el.at("margin", default: none)),
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
/// Pass named arguments like `axis-title: element-text(size: 12pt)` or `panel-grid: element-blank()`. Each surface is stored as an element record; the renderer reads them via `resolve-element` with cascade `surface → parent → defaults`.
///
/// Every surface listed below can be set via `theme(<name>: ...)`. Defaults come from the active theme (typically \@theme-grey).
///
/// **Inherited parents** — set once and every descendant in the same family falls back to them.
///
/// - `text` — \@element-text or \@element-typst. Default: `element-text(size: 9pt)`. Parent for every text surface below.
///
/// - `line` — \@element-line. Default: `element-line(thickness: 0.5pt)`. Parent for `panel-grid` and `axis-line`.
///
/// - `rect` — \@element-rect. Default: `element-rect()`. Parent for `panel-background` and `strip-background`.
///
/// **Text surfaces** — accept \@element-text or \@element-typst. Pass `margin: margin(...)` on either constructor to widen or tighten the gap between the surface and its neighbours; em values track the surface font size.
///
/// `axis-text` and `axis-title` each expose per-axis variants (`-x`, `-y`) and per-side leaves (`-x-bottom`, `-x-top`, `-y-left`, `-y-right`) that cascade up to the family. Setting any variant overrides only the matching side; unset variants inherit from their parent.
///
/// - `axis-text` — tick labels on both axes. Default: `element-text(size: 8pt)`.
///
/// - `axis-title` — axis titles via `labs(x: ..., y: ...)`. Default: `element-text(size: 9pt)`.
///
/// - `legend-text` — legend entry labels. Default: `element-text(size: 8pt)`.
///
/// - `legend-title` — legend headings. Default: `element-text(size: 8pt)`.
///
/// - `strip-text` — facet strip labels. Default: `element-text(size: 8pt)`.
///
/// - `plot-title` — plot title via `labs(title: ...)`. Default: `element-text(size: 12pt, weight: "bold")`.
///
/// - `plot-subtitle` — plot subtitle via `labs(subtitle: ...)`. Default: `element-text(size: 9pt)`.
///
/// - `plot-caption` — plot caption via `labs(caption: ...)`. Default: `element-text(size: 8pt)`.
///
/// **Line surfaces** — accept \@element-line or \@element-blank (use `element-blank()` to hide).
///
/// `axis-line` and `axis-ticks` follow the same per-axis (`-x`, `-y`) and per-side (`-x-bottom`, `-x-top`, `-y-left`, `-y-right`) cascade as the text surfaces.
///
/// - `panel-grid` — major gridlines inside the panel. Default: `element-line(thickness: 0.5pt)`.
///
/// - `axis-line` — the x and y axis spines. Default: `element-line(thickness: 0.5pt)`.
///
/// - `axis-ticks` — tick marks on every axis; inherits from `line` rather than `axis-line`. Default: `element-line(thickness: 0.5pt)`.
///
/// **Rect surfaces** — accept \@element-rect or \@element-blank.
///
/// - `panel-background` — panel fill behind the geoms. Default: `element-rect()`.
///
/// - `plot-background` — outermost canvas behind the title, panel, legend, and caption. Default: `element-rect()` (transparent — no rect drawn unless `fill` is set).
///
/// - `strip-background` — facet strip fill behind the strip text. Default: `element-rect()`.
///
/// **Colours and scalars**.
///
/// - `ink` (colour) — foreground colour used wherever no other colour applies. Default: `black`.
///
/// - `paper` (colour) — fallback fill for `panel-background` and `strip-background` when their own `fill` is unset. Default: `white`. \@theme-minimal and \@theme-void additionally copy an explicit `paper` into `plot-background.fill` so a single `paper:` argument paints the canvas.
///
/// - `accent` (colour) — highlight colour for layer defaults (e.g. \@geom-smooth's stroke). Default: `rgb("#3366FF")`.
///
/// - `tick-labels` (boolean) — toggle every axis tick label at once. Default: `true`.
///
/// - `tick-length` (length) — tick mark length (any Typst length). Default: `0.1cm`. Side variants `tick-length-x`, `tick-length-y`, `tick-length-x-bottom`, `tick-length-x-top`, `tick-length-y-left`, `tick-length-y-right` cascade up to `tick-length` when unset.
///
/// - `plot-margin` (\@margin record) — padding around the plot canvas. Use `margin(left: 2cm)` to override one side and let the others fall through to the renderer's default. Default: `margin()` (every side `auto`).
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
/// \@examples Tweak the scalar fields: bigger ticks, no tick labels, and a
/// wider left margin so a long axis title fits.
/// ```
/// #let d = range(0, 10).map(i => (x: i, y: i * 0.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   labs: labs(y: "Cumulative response (per protocol)"),
///   theme: theme(
///     tick-length: 0.25cm,
///     tick-labels: false,
///     plot-margin: margin(left: 2cm),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@theme-grey, \@theme-minimal, \@theme-classic, \@theme-void, \@element-text, \@element-line, \@element-rect, \@element-blank, \@margin
#let theme(..fields) = {
  let out = (kind: "theme", name: "custom")
  _apply-overrides(out, fields)
}
