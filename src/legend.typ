// Guide extraction and legend drawing.
//
// Per-aesthetic candidates are built first, then grouped: candidates that
// describe the same underlying scale (same column, type, levels/domain,
// labels and title) collapse into a single guide whose key glyph carries
// every merged aesthetic. Renders to the right of the panel.

#import "deps.typ": cetz
#import "utils/pretty.typ": pretty
#import "utils/colour.typ": resolve-continuous-colour
#import "utils/palette.typ": spec-palette
#import "utils/level-resolve.typ": resolve-level
#import "theme/defaults.typ": resolve-colour, resolve-field
#import "guide/draw-key.typ": default-key-for, draw-glyph
#import "scale/train.typ": mapping-ref-col
#import "utils/typst-markup.typ": resolve-prose
#import "utils/aes-resolve.typ": resolve-label

// Aesthetic emission order. `x` and `y` train but never produce a guide; the
// rest are emitted in this fixed order so merged guides land at the position
// of their earliest member.
#let _aesthetic-order = (
  "colour",
  "fill",
  "size",
  "alpha",
  "linewidth",
  "shape",
  "linetype",
)

#let _guide-title(t, spec, aes-name) = {
  if (
    t.at("spec", default: none) != none
      and t.spec.at("name", default: none) != none
  ) {
    t.spec.name
  } else if spec.mapping != none {
    mapping-ref-col(spec.mapping.at(aes-name, default: aes-name))
  } else {
    aes-name
  }
}

#let _grid-shape(n, nrow, ncol) = {
  if ncol != none {
    let cols = calc.max(1, ncol)
    let rows = calc.max(1, calc.ceil(n / cols))
    (rows: rows, cols: cols)
  } else if nrow != none {
    let rows = calc.max(1, nrow)
    let cols = calc.max(1, calc.ceil(n / rows))
    (rows: rows, cols: cols)
  } else {
    (rows: n, cols: 1)
  }
}

// Geom-driven fallback priority: when no aesthetic-driven rule applies,
// points dominate paths dominate lines dominate rects, so the swatch
// reflects the most distinctive mark drawn for the merged group.
#let _key-priority(key) = {
  if key == "point" { return 4 }
  if key == "path" { return 3 }
  if key == "line" { return 2 }
  if key == "rect" { return 1 }
  0
}

// Geoms that genuinely consume `fill`. Other geoms inherit it through plot
// mapping but don't draw anything filled, so they should not steer the legend
// glyph. Pure stroke geoms still consume `colour`.
#let _geom-uses-fill(geom) = (
  "col",
  "bar",
  "histogram",
  "rect",
  "tile",
  "area",
  "ribbon",
  "polygon",
  "boxplot",
  "crossbar",
  "smooth",
  "point",
  "label",
).contains(geom)

// Aesthetics that only render meaningfully on certain geoms. `none` means no
// structural restriction (the layer contributes if it maps the aesthetic).
#let _geom-uses-aesthetic(geom, aes-name) = {
  if aes-name == "fill" { return _geom-uses-fill(geom) }
  if aes-name == "shape" { return geom == "point" or geom == "jitter" }
  if aes-name == "linetype" or aes-name == "linewidth" {
    return not (
      "col",
      "bar",
      "histogram",
      "rect",
      "tile",
      "area",
      "ribbon",
      "polygon",
      "label",
    ).contains(geom)
  }
  true
}

#let _layer-pins(layer, aes-name) = {
  let v = layer.params.at(aes-name, default: auto)
  v != auto and v != none
}

#let _resolve-merged-mapping(layer, plot-mapping) = {
  let mapping = layer.at("mapping", default: none)
  let inherits = layer.at("inherit-aes", default: true)
  if inherits and plot-mapping != none {
    let m = plot-mapping
    if mapping != none {
      for (k, v) in mapping.pairs() {
        if v != none { m.insert(k, v) }
      }
    }
    return m
  }
  if mapping != none { return mapping }
  plot-mapping
}

// Layers that contribute to the guide for `aes-name`: those whose merged
// mapping consumes the aesthetic, that match the structural eligibility for
// the geom, and that do not pin the aesthetic locally.
#let _mapped-contributors(spec, aes-name) = {
  let layers = spec.at("layers", default: ())
  let plot-mapping = spec.at("mapping", default: none)
  let out = ()
  for layer in layers {
    let merged = _resolve-merged-mapping(layer, plot-mapping)
    if merged == none { continue }
    if merged.at(aes-name, default: none) == none { continue }
    let geom = layer.at("geom", default: "")
    if not _geom-uses-aesthetic(geom, aes-name) { continue }
    if _layer-pins(layer, aes-name) { continue }
    out.push(layer)
  }
  out
}

// Resolve the column name driving an aesthetic: read from any contributor's
// merged mapping; they all agree because the scale was trained from them.
#let _column-for(spec, aes-name) = {
  let plot-mapping = spec.at("mapping", default: none)
  for layer in spec.at("layers", default: ()) {
    let merged = _resolve-merged-mapping(layer, plot-mapping)
    if merged == none { continue }
    let raw = merged.at(aes-name, default: none)
    if raw != none { return mapping-ref-col(raw) }
  }
  none
}

// True when both candidates describe the same underlying scale and so should
// collapse into a single merged guide. See plan §1 for the predicate.
#let _can-merge(a, b) = {
  if a.column != b.column { return false }
  if a.column == none { return false }
  if a.t.type != b.t.type { return false }
  if a.title != b.title { return false }
  if a.nrow != b.nrow { return false }
  if a.ncol != b.ncol { return false }
  if a.reverse != b.reverse { return false }
  if a.t.type == "discrete" {
    if a.levels != b.levels { return false }
    if a.labels != b.labels { return false }
    return true
  }
  if a.domain != b.domain { return false }
  if a.trans != b.trans { return false }
  if a.temporal != b.temporal { return false }
  true
}

// Pass-A precedence: aesthetic-driven first, geom fallback last. See plan §2.
#let _key-kind-for-group(members) = {
  let aesthetics = members.map(c => c.aes)
  let has = aes-name => aesthetics.contains(aes-name)

  let prefers-path = members.any(c => c.contributors.any(layer => {
    let key-override = layer.at("key", default: auto)
    key-override != auto and key-override != none and key-override.key == "path"
  }))

  if has("shape") { return "point" }
  if has("linetype") {
    return if prefers-path { "path" } else { "line" }
  }
  if has("linewidth") {
    return if prefers-path { "path" } else { "line" }
  }
  if has("size") { return "point" }

  let best = "rect"
  let best-prio = 0
  for c in members {
    for layer in c.contributors {
      let geom = layer.at("geom", default: "")
      let key-override = layer.at("key", default: auto)
      let candidate = if key-override != auto and key-override != none {
        key-override.key
      } else {
        default-key-for(geom)
      }
      let prio = _key-priority(candidate)
      if prio > best-prio {
        best = candidate
        best-prio = prio
      }
    }
  }
  best
}

#let _candidate(spec, trained, overrides, aes-name) = {
  let t = trained.at(aes-name, default: none)
  if t == none { return none }
  if t.type == "identity" { return none }
  let override = overrides.at(aes-name, default: none)
  if override != none and override.at("suppress", default: false) {
    return none
  }
  let contributors = _mapped-contributors(spec, aes-name)
  if contributors.len() == 0 { return none }

  let title = _guide-title(t, spec, aes-name)
  if override != none and override.at("title", default: none) != none {
    title = override.title
  }
  let nrow = if override != none { override.at("nrow", default: none) } else {
    none
  }
  let ncol = if override != none { override.at("ncol", default: none) } else {
    none
  }
  let reverse = if override != none {
    override.at("reverse", default: false)
  } else { false }

  let cand = (
    aes: aes-name,
    t: t,
    title: title,
    nrow: nrow,
    ncol: ncol,
    reverse: reverse,
    contributors: contributors,
    column: _column-for(spec, aes-name),
    typst-mark: t.at("typst-mark", default: false),
  )

  if t.type == "discrete" {
    let levels = t.domain
    let user-limits = (
      t.at("spec", default: none) != none
        and t.spec.at("limits", default: none) != none
    )
    if not user-limits { levels = levels.sorted() }
    let labels = if (
      t.at("spec", default: none) != none
    ) { t.spec.at("labels", default: auto) } else { auto }
    cand.insert("levels", levels)
    cand.insert("labels", labels)
  } else {
    cand.insert("domain", t.domain)
    cand.insert("trans", t.at("trans", default: "identity"))
    cand.insert("temporal", t.at("temporal", default: none))
  }
  cand
}

#let guides-for(spec, trained) = {
  let overrides = spec.at("guides", default: (:))

  let candidates = ()
  for aes-name in _aesthetic-order {
    let cand = _candidate(spec, trained, overrides, aes-name)
    if cand != none { candidates.push(cand) }
  }

  let groups = ()
  for cand in candidates {
    let placed = false
    let i = 0
    while i < groups.len() and not placed {
      let grp = groups.at(i)
      if _can-merge(cand, grp.members.first()) {
        grp.members.push(cand)
        groups.at(i) = grp
        placed = true
      }
      i += 1
    }
    if not placed { groups.push((members: (cand,))) }
  }

  let guides = ()
  for grp in groups {
    let members = grp.members
    let first = members.first()
    let aesthetics = members.map(c => c.aes)
    let key-kind = _key-kind-for-group(members)

    let typst-mark = members.any(m => m.at("typst-mark", default: false))
    if first.t.type == "discrete" {
      let levels = first.levels
      if first.reverse { levels = levels.rev() }
      guides.push((
        kind: "swatch",
        aesthetics: aesthetics,
        title: first.title,
        levels: levels,
        labels: first.labels,
        nrow: first.nrow,
        ncol: first.ncol,
        key: key-kind,
        typst-mark: typst-mark,
      ))
    } else if aesthetics.contains("colour") or aesthetics.contains("fill") {
      // A colour/fill continuous member governs rendering; any size/alpha
      // members in the same group are intentionally dropped from the bar
      // because compositing them on a smooth gradient is awkward and rare.
      let user-labels = if (
        first.t.at("spec", default: none) != none
      ) { first.t.spec.at("labels", default: auto) } else { auto }
      guides.push((
        kind: "colourbar",
        aesthetics: aesthetics,
        title: first.title,
        domain: first.domain,
        labels: user-labels,
        typst-mark: typst-mark,
      ))
    } else {
      let breaks = pretty(first.domain.first(), first.domain.last(), n: 5)
      let user-labels = if (
        first.t.at("spec", default: none) != none
      ) { first.t.spec.at("labels", default: auto) } else { auto }
      guides.push((
        kind: "size-ladder",
        aesthetics: aesthetics,
        title: first.title,
        domain: first.domain,
        breaks: breaks,
        labels: user-labels,
        key: key-kind,
        typst-mark: typst-mark,
      ))
    }
  }
  guides
}

#let _format-break(n) = {
  if type(n) == int { return str(n) }
  if calc.abs(n - calc.round(n)) < 1e-9 { return str(calc.round(n)) }
  str(calc.round(n, digits: 3))
}

// Compose an aesthetic bundle for one level/value across every member of the
// merged group. Returns a dict consumable by `draw-glyph`.
#let _bundle-for(value, aesthetics, ctx, ink) = {
  let bundle = (:)
  for aes-name in aesthetics {
    let trained = ctx.trained.at(aes-name, default: none)
    if trained == none { continue }
    let v = resolve-level(
      aes-name,
      trained,
      value,
      palette: ctx.palette,
      ink: ink,
    )
    if v == none { continue }
    bundle.insert(aes-name, v)
  }
  bundle
}

#let _title-chars(g) = if g.title == none { 0 } else { g.title.len() }

#let estimate-width(guides) = {
  if guides.len() == 0 { return 0.0 }
  let max-width = 0.0
  for g in guides {
    if g.kind == "swatch" {
      let title-chars = _title-chars(g)
      let level-chars = 0
      for level in g.levels {
        level-chars = calc.max(level-chars, level.len())
      }
      let shape = _grid-shape(g.levels.len(), g.nrow, g.ncol)
      let col-w = calc.min(2.5, 0.6 + level-chars * 0.18)
      let title-w = calc.min(2.5, 0.6 + title-chars * 0.18)
      let col-gap = calc.max(0.15, 0.1 * col-w)
      let grid-w = col-w * shape.cols + col-gap * (shape.cols - 1)
      max-width = calc.max(max-width, calc.max(title-w, grid-w))
    } else if g.kind == "size-ladder" {
      let title-chars = _title-chars(g)
      let label-chars = 0
      for b in g.breaks {
        label-chars = calc.max(label-chars, _format-break(b).len())
      }
      let col-w = calc.min(2.5, 0.6 + label-chars * 0.18)
      let title-w = calc.min(2.5, 0.6 + title-chars * 0.18)
      max-width = calc.max(max-width, calc.max(title-w, col-w))
    } else if g.kind == "colourbar" {
      let (lo, hi) = g.domain
      let breaks = pretty(lo, hi, n: 5)
      let max-chars = _title-chars(g)
      for b in breaks {
        max-chars = calc.max(max-chars, _format-break(b).len())
      }
      max-width = calc.max(max-width, 0.45 + 0.2 + max-chars * 0.18)
    }
  }
  max-width
}

#let _swatch-height(guide) = {
  let title-h = 0.45
  let line-h = 0.4
  let shape = _grid-shape(guide.levels.len(), guide.nrow, guide.ncol)
  title-h + line-h * shape.rows + 0.2
}

#let _size-ladder-height(guide) = {
  let title-h = 0.45
  let line-h = 0.45
  title-h + line-h * guide.breaks.len() + 0.2
}

#let _colourbar-height() = {
  let title-h = 0.45
  let bar-h = 3.0
  title-h + bar-h + 0.3
}

#let _draw-title(ox, cursor, theme, title) = {
  let title-colour = resolve-colour(
    theme,
    "legend-title-colour",
    "text-colour",
    "ink",
  )
  let title-weight = resolve-field(
    theme,
    "legend-title-weight",
    "text-weight",
    fallback: "medium",
  )
  let title-size = theme.at("legend-title-size", default: 8pt)
  cetz.draw.content(
    (ox, cursor),
    text(
      size: title-size,
      fill: title-colour,
      weight: title-weight,
    )[#resolve-prose(title, eval-strings: theme.legend-title-typst)],
    anchor: "north-west",
  )
}

#let _draw-swatch(guide, ctx, ox, cursor, theme) = {
  let title-h = 0.45
  let line-h = 0.4
  let glyph-size = 0.12
  let ink = resolve-colour(theme, "ink")
  let text-colour = resolve-colour(
    theme,
    "legend-text-colour",
    "text-colour",
    "ink",
  )
  let text-size = theme.at("legend-text-size", default: 8pt)

  _draw-title(ox, cursor, theme, guide.title)
  let top = cursor - title-h
  let shape = _grid-shape(guide.levels.len(), guide.nrow, guide.ncol)
  let level-chars = 0
  for level in guide.levels {
    level-chars = calc.max(level-chars, level.len())
  }
  let col-w = calc.min(2.5, 0.6 + level-chars * 0.18)
  let col-gap = calc.max(0.15, 0.1 * col-w)
  let key-kind = guide.at("key", default: "rect")
  let labels = guide.at("labels", default: auto)
  for (i, level) in guide.levels.enumerate() {
    let col = calc.quo(i, shape.rows)
    let row = calc.rem(i, shape.rows)
    let cx = ox + col * (col-w + col-gap)
    let cy = top - row * line-h
    let bundle = _bundle-for(level, guide.aesthetics, ctx, ink)
    draw-glyph(
      key-kind,
      cx + glyph-size,
      cy - glyph-size,
      glyph-size,
      bundle,
      ink: ink,
    )
    let label-text = resolve-prose(
      resolve-label(
        labels,
        level,
        i,
        level,
        typst-mark: guide.at("typst-mark", default: false),
      ),
      eval-strings: theme.legend-text-typst,
    )
    cetz.draw.content(
      (cx + glyph-size * 2 + 0.15, cy - glyph-size),
      text(size: text-size, fill: text-colour)[#label-text],
      anchor: "west",
    )
  }
}

#let _draw-size-ladder(guide, ctx, ox, cursor, theme) = {
  let title-h = 0.45
  let line-h = 0.45
  let glyph-size = 0.16
  let ink = resolve-colour(theme, "ink")
  let text-colour = resolve-colour(
    theme,
    "legend-text-colour",
    "text-colour",
    "ink",
  )
  let text-size = theme.at("legend-text-size", default: 8pt)

  _draw-title(ox, cursor, theme, guide.title)
  let top = cursor - title-h
  let key-kind = guide.at("key", default: "point")
  for (i, value) in guide.breaks.enumerate() {
    let cy = top - i * line-h
    let bundle = _bundle-for(value, guide.aesthetics, ctx, ink)
    draw-glyph(
      key-kind,
      ox + glyph-size,
      cy - glyph-size,
      glyph-size,
      bundle,
      ink: ink,
    )
    let labels = guide.at("labels", default: auto)
    let break-text = resolve-prose(
      resolve-label(
        labels,
        value,
        i,
        _format-break(value),
        typst-mark: guide.at("typst-mark", default: false),
      ),
      eval-strings: theme.legend-text-typst,
    )
    cetz.draw.content(
      (ox + glyph-size * 2 + 0.15, cy - glyph-size),
      text(size: text-size, fill: text-colour)[#break-text],
      anchor: "west",
    )
  }
}

#let _resolve-bar-colour(trained, value, palette, ink) = {
  if trained == none or value == none { return ink }
  let pal = spec-palette(trained, palette)
  resolve-continuous-colour(trained, value, pal, ink)
}

#let _draw-colourbar(guide, ctx, ox, cursor, theme) = {
  let title-h = 0.45
  let bar-w = 0.35
  let bar-h = 3.0
  let tick-gap = 0.08
  let bar-aes = if guide.aesthetics.contains("colour") {
    "colour"
  } else { "fill" }
  let trained = ctx.trained.at(bar-aes)
  let ink = resolve-colour(theme, "ink")
  let text-colour = resolve-colour(
    theme,
    "legend-text-colour",
    "text-colour",
    "ink",
  )
  let text-size = theme.at("legend-text-size", default: 8pt)
  let (lo, hi) = guide.domain

  _draw-title(ox, cursor, theme, guide.title)
  let bar-top = cursor - title-h
  let bar-bottom = bar-top - bar-h
  let steps = 40
  let step-h = bar-h / steps
  for i in range(steps) {
    let t = (i + 0.5) / steps
    let value = lo + t * (hi - lo)
    let colour = _resolve-bar-colour(trained, value, ctx.palette, ink)
    let y-lo = bar-bottom + i * step-h
    let y-hi = y-lo + step-h
    cetz.draw.rect(
      (ox, y-lo),
      (ox + bar-w, y-hi),
      fill: colour,
      stroke: none,
    )
  }
  cetz.draw.rect(
    (ox, bar-bottom),
    (ox + bar-w, bar-top),
    fill: none,
    stroke: (paint: luma(53%), thickness: 0.2pt),
  )
  let breaks = pretty(lo, hi, n: 5)
  let labels = guide.at("labels", default: auto)
  let typst-mark = guide.at("typst-mark", default: false)
  for (i, b) in breaks.enumerate() {
    if hi == lo { continue }
    let t = (b - lo) / (hi - lo)
    if t < 0 or t > 1 { continue }
    let cy = bar-bottom + t * bar-h
    cetz.draw.line(
      (ox + bar-w, cy),
      (ox + bar-w + 0.1, cy),
      stroke: (paint: luma(33%), thickness: 0.3pt),
    )
    let tick-text = resolve-prose(
      resolve-label(
        labels,
        b,
        i,
        _format-break(b),
        typst-mark: typst-mark,
      ),
      eval-strings: theme.legend-text-typst,
    )
    cetz.draw.content(
      (ox + bar-w + tick-gap + 0.1, cy),
      text(size: text-size, fill: text-colour)[#tick-text],
      anchor: "west",
    )
  }
}

#let draw(guides, ctx, origin, height, theme) = {
  if guides.len() == 0 { return }
  let (ox, oy) = origin
  let cursor = oy + height
  for g in guides {
    if g.kind == "swatch" {
      _draw-swatch(g, ctx, ox, cursor, theme)
      cursor -= _swatch-height(g)
    } else if g.kind == "size-ladder" {
      _draw-size-ladder(g, ctx, ox, cursor, theme)
      cursor -= _size-ladder-height(g)
    } else if g.kind == "colourbar" {
      _draw-colourbar(g, ctx, ox, cursor, theme)
      cursor -= _colourbar-height()
    }
  }
}
