// Guide extraction and legend drawing.
//
// Per-aesthetic candidates are built first, then grouped: candidates that
// describe the same underlying scale (same column, type, levels/domain,
// labels and title) collapse into a single guide whose key glyph carries
// every merged aesthetic. Renders to the right of the panel.

#import "deps.typ": cetz
#import "utils/pretty.typ": pretty
#import "utils/format.typ": format-break
#import "utils/colour.typ": resolve-continuous-colour
#import "utils/palette.typ": spec-palette
#import "utils/level-resolve.typ": resolve-level
#import "theme/defaults.typ": resolve-colour
#import "theme/theme.typ": _text-style
#import "guide/draw-key.typ": default-key-for, draw-glyph
#import "scale/train.typ": mapping-ref-col
#import "utils/typst-markup.typ": resolve-prose
#import "utils/margin.typ": length-to-cm
#import "utils/aes-resolve.typ": merge-mapping, resolve-label
#import "utils/margin.typ": resolve-margin-side-cm

// Aesthetic emission order. `x` and `y` train but never produce a guide; the
// rest are emitted in this fixed order so merged guides land at the position
// of their earliest member.
#let _aesthetic-order = (
  "colour",
  "fill",
  "size",
  "alpha",
  "linewidth",
  "stroke",
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
  if aes-name == "stroke" { return geom == "point" or geom == "jitter" }
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


// Layers that contribute to the guide for `aes-name`: those whose merged
// mapping consumes the aesthetic, that match the structural eligibility for
// the geom, and that do not pin the aesthetic locally.
#let _mapped-contributors(spec, aes-name) = {
  let layers = spec.at("layers", default: ())
  let plot-mapping = spec.at("mapping", default: none)
  let out = ()
  for layer in layers {
    let merged = merge-mapping(layer, plot-mapping)
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
    let merged = merge-mapping(layer, plot-mapping)
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
  if a.transform != b.transform { return false }
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
  if has("stroke") { return "point" }

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
    cand.insert("transform", t.at("transform", default: "identity"))
    cand.insert("temporal", t.at("temporal", default: none))
  }
  cand
}

// Extract user-labels, binned-flag, and n-breaks from a trained scale's spec.
// Returns sane defaults when the spec is absent (auto-defaulted scales).
#let _bin-info(t, default-n: 5) = {
  let spec = t.at("spec", default: none)
  if spec == none {
    return (labels: auto, binned: false, n-breaks: default-n)
  }
  (
    labels: spec.at("labels", default: auto),
    binned: spec.at("binned", default: false),
    n-breaks: spec.at("n-breaks", default: default-n),
  )
}

#let _title-chars(g) = if g.title == none { 0 } else { g.title.len() }

// Approximate per-character horizontal extent in canvas units.
#let _char-width = 0.18

// Approximate label extent capped so the legend column does not outgrow the
// available space.
#let _label-width(chars) = calc.min(2.5, 0.6 + chars * _char-width)

// Per-column widths, gap, cumulative left-offsets, and total grid width for a
// column-major swatch layout. Each column sizes to its own widest label so a
// single oversized level doesn't pad every other column unnecessarily.
#let _swatch-layout(levels, shape) = {
  let widths = range(shape.cols).map(col => {
    let chars = 0
    for row in range(shape.rows) {
      let i = col * shape.rows + row
      if i >= levels.len() { break }
      chars = calc.max(chars, levels.at(i).len())
    }
    _label-width(chars)
  })
  let gap = calc.max(0.15, 0.1 * calc.max(..widths))
  let offsets = ()
  let acc = 0.0
  for w in widths {
    offsets.push(acc)
    acc += w + gap
  }
  (widths: widths, gap: gap, offsets: offsets, total: acc - gap)
}

// Default footprint (cm) for `guide-custom` when the user did not supply an
// explicit length. Two columns wide so it sits next to the standard legends
// without forcing the page to grow.
#let _CUSTOM-DEFAULT-WIDTH = 3.0
#let _CUSTOM-DEFAULT-HEIGHT = 2.0

// Resolve a `guide-custom` width or height field to a cm float. Accepts a
// length or `auto`; anything else panics so user typos surface loudly.
#let _custom-dim-cm(value, fallback) = {
  if value == auto { return fallback }
  if type(value) == length { return length-to-cm(value, 0) }
  panic(
    "guide-custom width/height must be a length or `auto`; got " + repr(value),
  )
}

// Per-guide width estimate. Stored on each guide so `estimate-width` is O(1).
#let _guide-width(g) = {
  if g.kind == "swatch" {
    let shape = _grid-shape(g.levels.len(), g.nrow, g.ncol)
    let layout = _swatch-layout(g.levels, shape)
    return calc.max(_label-width(_title-chars(g)), layout.total)
  }
  if g.kind == "size-ladder" {
    let label-chars = 0
    for b in g.breaks {
      label-chars = calc.max(label-chars, format-break(b).len())
    }
    return calc.max(_label-width(_title-chars(g)), _label-width(label-chars))
  }
  if g.kind == "colourbar" {
    let breaks = if g.at("breaks", default: none) != none {
      g.breaks
    } else {
      let (lo, hi) = g.domain
      pretty(lo, hi, n: 5)
    }
    let max-chars = _title-chars(g)
    for b in breaks {
      max-chars = calc.max(max-chars, format-break(b).len())
    }
    return 0.65 + max-chars * _char-width
  }
  if g.kind == "custom" { return g.cm-width }
  0.0
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
    let g = if first.t.type == "discrete" {
      let levels = first.levels
      if first.reverse { levels = levels.rev() }
      (
        kind: "swatch",
        aesthetics: aesthetics,
        title: first.title,
        levels: levels,
        labels: first.labels,
        nrow: first.nrow,
        ncol: first.ncol,
        key: key-kind,
        typst-mark: typst-mark,
      )
    } else if aesthetics.contains("colour") or aesthetics.contains("fill") {
      // A colour/fill continuous member governs rendering; any size/alpha
      // members in the same group are intentionally dropped from the bar
      // because compositing them on a smooth gradient is awkward and rare.
      // Stepped scales (binned: true) emit n-breaks discrete patches with
      // ticks at the bin boundaries; smooth scales fall back to pretty().
      let info = _bin-info(first.t)
      let lo = first.domain.first()
      let hi = first.domain.last()
      let breaks = if info.binned {
        range(info.n-breaks + 1).map(i => lo + i * (hi - lo) / info.n-breaks)
      } else { pretty(lo, hi, n: 5) }
      (
        kind: "colourbar",
        aesthetics: aesthetics,
        title: first.title,
        domain: first.domain,
        breaks: breaks,
        labels: info.labels,
        typst-mark: typst-mark,
        binned: info.binned,
        n-breaks: info.n-breaks,
      )
    } else {
      // Numeric ladder for size/alpha/linewidth/stroke. Binned scales emit
      // one glyph per bin at the midpoint; smooth scales fall back to pretty().
      let info = _bin-info(first.t)
      let lo = first.domain.first()
      let hi = first.domain.last()
      let breaks = if info.binned {
        range(info.n-breaks).map(i => (
          lo + (i + 0.5) * (hi - lo) / info.n-breaks
        ))
      } else { pretty(lo, hi, n: 5) }
      (
        kind: "size-ladder",
        aesthetics: aesthetics,
        title: first.title,
        domain: first.domain,
        breaks: breaks,
        labels: info.labels,
        key: key-kind,
        typst-mark: typst-mark,
        binned: info.binned,
        n-breaks: info.n-breaks,
      )
    }
    g.insert("width", _guide-width(g))
    guides.push(g)
  }

  // Free-form `guide-custom` slots have no scale, so the merge loop above
  // never sees them; surface them here in the order they appear in
  // `spec.guides`. Cm dimensions are resolved up-front so the dispatch and
  // measurement helpers stay O(1).
  for g in overrides.values() {
    if type(g) != dictionary { continue }
    if g.at("kind", default: none) != "guide-custom" { continue }
    let cm-w = _custom-dim-cm(g.width, _CUSTOM-DEFAULT-WIDTH)
    let cm-h = _custom-dim-cm(g.height, _CUSTOM-DEFAULT-HEIGHT)
    let custom = (
      kind: "custom",
      content: g.content,
      cm-width: cm-w,
      cm-height: cm-h,
      title: g.title,
    )
    custom.insert("width", _guide-width(custom))
    guides.push(custom)
  }
  guides
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

#let estimate-width(guides) = {
  if guides.len() == 0 { return 0.0 }
  let max-width = 0.0
  for g in guides {
    let w = g.at("width", default: 0.0)
    if w > max-width { max-width = w }
  }
  max-width
}

// Vertical gap between the legend title and the first guide entry, resolved
// against the `legend-title` surface so em values track its font size.
#let _legend-title-h(theme) = {
  let s = _text-style(theme, "legend-title")
  resolve-margin-side-cm(
    s.margin.bottom,
    1.6em,
    size-pt: s.size / 1pt,
  )
}

#let _swatch-height(guide, title-h) = {
  let line-h = 0.4
  let shape = _grid-shape(guide.levels.len(), guide.nrow, guide.ncol)
  title-h + line-h * shape.rows + 0.2
}

#let _size-ladder-height(guide, title-h) = {
  let line-h = 0.45
  title-h + line-h * guide.breaks.len() + 0.2
}

#let _colourbar-height(title-h) = {
  let bar-h = 3.0
  title-h + bar-h + 0.3
}

#let _custom-height(guide, title-h) = {
  let prefix = if guide.title != none { title-h } else { 0.0 }
  prefix + guide.cm-height + 0.2
}

#let _draw-title(ox, cursor, theme, title) = {
  let s = _text-style(theme, "legend-title")
  cetz.draw.content(
    (ox, cursor),
    text(
      size: s.size,
      fill: s.fill,
      weight: s.weight,
    )[#resolve-prose(title, eval-strings: s.typst)],
    anchor: "north-west",
  )
}

#let _draw-swatch(guide, ctx, ox, cursor, theme, title-h) = {
  let line-h = 0.4
  let glyph-size = 0.12
  let ink = resolve-colour(theme, "ink")
  let _legend-text = _text-style(theme, "legend-text")
  let text-colour = _legend-text.fill
  let text-size = _legend-text.size

  _draw-title(ox, cursor, theme, guide.title)
  let top = cursor - title-h
  let shape = _grid-shape(guide.levels.len(), guide.nrow, guide.ncol)
  let layout = _swatch-layout(guide.levels, shape)
  let key-kind = guide.at("key", default: "rect")
  let labels = guide.at("labels", default: auto)
  for (i, level) in guide.levels.enumerate() {
    let col = calc.quo(i, shape.rows)
    let row = calc.rem(i, shape.rows)
    let cx = ox + layout.offsets.at(col)
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
      eval-strings: _legend-text.typst,
    )
    cetz.draw.content(
      (cx + glyph-size * 2 + 0.15, cy - glyph-size),
      text(size: text-size, fill: text-colour)[#label-text],
      anchor: "west",
    )
  }
}

#let _draw-size-ladder(guide, ctx, ox, cursor, theme, title-h) = {
  let line-h = 0.45
  let glyph-size = 0.16
  let ink = resolve-colour(theme, "ink")
  let _legend-text = _text-style(theme, "legend-text")
  let text-colour = _legend-text.fill
  let text-size = _legend-text.size

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
        format-break(value),
        typst-mark: guide.at("typst-mark", default: false),
      ),
      eval-strings: _legend-text.typst,
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

#let _draw-colourbar(guide, ctx, ox, cursor, theme, title-h) = {
  let bar-w = 0.35
  let bar-h = 3.0
  let tick-gap = 0.08
  let bar-aes = if guide.aesthetics.contains("colour") {
    "colour"
  } else { "fill" }
  let trained = ctx.trained.at(bar-aes)
  let ink = resolve-colour(theme, "ink")
  let _legend-text = _text-style(theme, "legend-text")
  let text-colour = _legend-text.fill
  let text-size = _legend-text.size
  let (lo, hi) = guide.domain

  _draw-title(ox, cursor, theme, guide.title)
  let bar-top = cursor - title-h
  let bar-bottom = bar-top - bar-h
  let steps = if guide.at("binned", default: false) {
    guide.at("n-breaks", default: 5)
  } else { 40 }
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
    stroke: (paint: ink, thickness: 0.2pt),
  )
  let breaks = guide.at("breaks", default: pretty(lo, hi, n: 5))
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
      stroke: (paint: ink, thickness: 0.3pt),
    )
    let tick-text = resolve-prose(
      resolve-label(
        labels,
        b,
        i,
        format-break(b),
        typst-mark: typst-mark,
      ),
      eval-strings: _legend-text.typst,
    )
    cetz.draw.content(
      (ox + bar-w + tick-gap + 0.1, cy),
      text(size: text-size, fill: text-colour)[#tick-text],
      anchor: "west",
    )
  }
}

#let _draw-custom(guide, ox, cursor, theme, title-h) = {
  let has-title = guide.title != none
  if has-title { _draw-title(ox, cursor, theme, guide.title) }
  let top = cursor - if has-title { title-h } else { 0.0 }
  cetz.draw.content(
    (ox, top),
    box(
      width: guide.cm-width * 1cm,
      height: guide.cm-height * 1cm,
      guide.content,
    ),
    anchor: "north-west",
  )
}

#let draw(guides, ctx, origin, height, theme) = {
  if guides.len() == 0 { return }
  let (ox, oy) = origin
  let cursor = oy + height
  let title-h = _legend-title-h(theme)
  for g in guides {
    if g.kind == "swatch" {
      _draw-swatch(g, ctx, ox, cursor, theme, title-h)
      cursor -= _swatch-height(g, title-h)
    } else if g.kind == "size-ladder" {
      _draw-size-ladder(g, ctx, ox, cursor, theme, title-h)
      cursor -= _size-ladder-height(g, title-h)
    } else if g.kind == "colourbar" {
      _draw-colourbar(g, ctx, ox, cursor, theme, title-h)
      cursor -= _colourbar-height(title-h)
    } else if g.kind == "custom" {
      _draw-custom(g, ox, cursor, theme, title-h)
      cursor -= _custom-height(g, title-h)
    }
  }
}
