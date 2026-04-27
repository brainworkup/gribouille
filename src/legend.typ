// Guide extraction and legend drawing.
// Supports discrete colour/fill (swatch legend) and continuous colour/fill
// (colourbar), rendered to the right of the panel.

#import "deps.typ": cetz
#import "utils/pretty.typ": pretty
#import "utils/colour.typ": resolve-continuous-colour
#import "theme/defaults.typ": resolve-colour, resolve-field
#import "guide/draw-key.typ": default-key-for, draw-glyph
#import "scale/train.typ": mapping-ref-col

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

// Priority used when several layers contribute to the same legend. Points
// dominate lines, lines dominate rects, so the swatch reflects the most
// distinctive mark drawn for that aesthetic.
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

// Resolve the key kind for a swatch driven by `aes-name`. Considers every
// layer that maps the aesthetic and picks the highest-priority key kind.
// Layers may pin a kind via `key: draw-key-*()`; otherwise the kind is
// inferred from the geom name.
#let _key-kind-for(spec, aes-name) = {
  let layers = spec.at("layers", default: ())
  let plot-mapping = spec.at("mapping", default: none)
  let best = "rect"
  let best-prio = 0
  for layer in layers {
    let mapping = layer.at("mapping", default: none)
    let inherits = layer.at("inherit-aes", default: true)
    let merged = if inherits and plot-mapping != none {
      let m = plot-mapping
      if mapping != none {
        for (k, v) in mapping.pairs() {
          if v != none { m.insert(k, v) }
        }
      }
      m
    } else if mapping != none { mapping } else { plot-mapping }
    if merged == none { continue }
    if merged.at(aes-name, default: none) == none { continue }
    let geom = layer.at("geom", default: "")
    if aes-name == "fill" and not _geom-uses-fill(geom) { continue }
    let pinned = layer.at("key", default: auto)
    let candidate = if pinned != auto and pinned != none { pinned.key } else {
      default-key-for(geom)
    }
    let prio = _key-priority(candidate)
    if prio > best-prio {
      best = candidate
      best-prio = prio
    }
  }
  best
}

#let guides-for(spec, trained) = {
  let overrides = spec.at("guides", default: (:))
  let guides = ()
  for aes-name in ("colour", "fill") {
    let t = trained.at(aes-name, default: none)
    if t == none { continue }
    if t.type == "identity" { continue }
    let override = overrides.at(aes-name, default: none)
    if override != none and override.at("suppress", default: false) {
      continue
    }
    let title = _guide-title(t, spec, aes-name)
    if override != none and override.at("title", default: none) != none {
      title = override.title
    }
    if t.type == "discrete" {
      let levels = t.domain
      let reverse = if override != none {
        override.at("reverse", default: false)
      } else { false }
      if reverse { levels = levels.rev() }
      let nrow = if override != none {
        override.at("nrow", default: none)
      } else { none }
      let ncol = if override != none {
        override.at("ncol", default: none)
      } else { none }
      guides.push((
        kind: "swatch",
        aesthetic: aes-name,
        title: title,
        levels: levels,
        nrow: nrow,
        ncol: ncol,
        key: _key-kind-for(spec, aes-name),
      ))
    } else if t.type == "continuous" {
      guides.push((
        kind: "colourbar",
        aesthetic: aes-name,
        title: title,
        domain: t.domain,
      ))
    }
  }
  guides
}

#let _palette-for(trained, fallback) = {
  let spec = trained.at("spec", default: none)
  if spec == none { return fallback }
  let p = spec.at("palette", default: auto)
  if p == auto or p == none { fallback } else { p }
}

#let _resolve-colour-simple(trained, value, palette, ink) = {
  if trained == none or value == none { return ink }
  let pal = _palette-for(trained, palette)
  if trained.type == "discrete" {
    let s = str(value)
    let idx = trained.domain.position(v => v == s)
    if idx == none { return ink }
    pal.at(calc.rem(idx, pal.len()))
  } else {
    resolve-continuous-colour(trained, value, pal, ink)
  }
}

#let _format-break(n) = {
  if type(n) == int { return str(n) }
  if calc.abs(n - calc.round(n)) < 1e-9 { return str(calc.round(n)) }
  str(calc.round(n, digits: 3))
}

#let estimate-width(guides) = {
  if guides.len() == 0 { return 0.0 }
  let max-width = 0.0
  for g in guides {
    if g.kind == "swatch" {
      let title-chars = g.title.len()
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
    } else if g.kind == "colourbar" {
      let (lo, hi) = g.domain
      let breaks = pretty(lo, hi, n: 5)
      let max-chars = g.title.len()
      for b in breaks {
        max-chars = calc.max(max-chars, _format-break(b).len())
      }
      // Colourbar strip width + padding + tick labels.
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

#let _colourbar-height() = {
  let title-h = 0.45
  let bar-h = 3.0
  title-h + bar-h + 0.3
}

#let _draw-swatch(guide, ctx, ox, cursor, theme) = {
  let title-h = 0.45
  let line-h = 0.4
  let glyph-size = 0.12
  let trained = ctx.trained.at(guide.aesthetic)
  let ink = resolve-colour(theme, "ink")
  let title-colour = resolve-colour(
    theme,
    "legend-title-colour",
    "text-colour",
    "ink",
  )
  let text-colour = resolve-colour(
    theme,
    "legend-text-colour",
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
  let text-size = theme.at("legend-text-size", default: 8pt)
  cetz.draw.content(
    (ox, cursor),
    text(
      size: title-size,
      fill: title-colour,
      weight: title-weight,
    )[#guide.title],
    anchor: "north-west",
  )
  let top = cursor - title-h
  let shape = _grid-shape(guide.levels.len(), guide.nrow, guide.ncol)
  let level-chars = 0
  for level in guide.levels {
    level-chars = calc.max(level-chars, level.len())
  }
  let col-w = calc.min(2.5, 0.6 + level-chars * 0.18)
  let col-gap = calc.max(0.15, 0.1 * col-w)
  let key-kind = guide.at("key", default: "rect")
  for (i, level) in guide.levels.enumerate() {
    let col = calc.quo(i, shape.rows)
    let row = calc.rem(i, shape.rows)
    let cx = ox + col * (col-w + col-gap)
    let cy = top - row * line-h
    let colour = _resolve-colour-simple(trained, level, ctx.palette, ink)
    draw-glyph(key-kind, cx + glyph-size, cy - glyph-size, glyph-size, colour)
    cetz.draw.content(
      (cx + glyph-size * 2 + 0.15, cy - glyph-size),
      text(size: text-size, fill: text-colour)[#level],
      anchor: "west",
    )
  }
}

#let _draw-colourbar(guide, ctx, ox, cursor, theme) = {
  let title-h = 0.45
  let bar-w = 0.35
  let bar-h = 3.0
  let tick-gap = 0.08
  let trained = ctx.trained.at(guide.aesthetic)
  let ink = resolve-colour(theme, "ink")
  let title-colour = resolve-colour(
    theme,
    "legend-title-colour",
    "text-colour",
    "ink",
  )
  let text-colour = resolve-colour(
    theme,
    "legend-text-colour",
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
  let text-size = theme.at("legend-text-size", default: 8pt)
  let (lo, hi) = guide.domain
  cetz.draw.content(
    (ox, cursor),
    text(
      size: title-size,
      fill: title-colour,
      weight: title-weight,
    )[#guide.title],
    anchor: "north-west",
  )
  let bar-top = cursor - title-h
  let bar-bottom = bar-top - bar-h
  let steps = 40
  let step-h = bar-h / steps
  for i in range(steps) {
    let t = (i + 0.5) / steps
    let value = lo + t * (hi - lo)
    let colour = _resolve-colour-simple(trained, value, ctx.palette, ink)
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
  for b in breaks {
    if hi == lo { continue }
    let t = (b - lo) / (hi - lo)
    if t < 0 or t > 1 { continue }
    let cy = bar-bottom + t * bar-h
    cetz.draw.line(
      (ox + bar-w, cy),
      (ox + bar-w + 0.1, cy),
      stroke: (paint: luma(33%), thickness: 0.3pt),
    )
    cetz.draw.content(
      (ox + bar-w + tick-gap + 0.1, cy),
      text(size: text-size, fill: text-colour)[#_format-break(b)],
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
    } else if g.kind == "colourbar" {
      _draw-colourbar(g, ctx, ox, cursor, theme)
      cursor -= _colourbar-height()
    }
  }
}
