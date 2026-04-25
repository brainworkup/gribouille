// CeTZ rendering glue.
// Draws a single cartesian panel with axes and layer marks.

#import "deps.typ": cetz
#import "scale/train.typ": map-continuous, map-position, mapping-ref-col, train
#import "stat/apply.typ": apply-stat
#import "position/apply.typ": apply-position
#import "theme/defaults.typ": merge-theme, resolve-colour, resolve-field
#import "utils/pretty.typ": pretty
#import "utils/types.typ": parse-number
#import "utils/palette.typ": default-discrete
#import "utils/group.typ": group-cols, partition-by-group
#import "geom/point.typ" as point-geom
#import "geom/line.typ" as line-geom
#import "geom/col.typ" as col-geom
#import "geom/ribbon.typ" as ribbon-geom
#import "geom/smooth.typ" as smooth-geom
#import "geom/hline.typ" as hline-geom
#import "geom/vline.typ" as vline-geom
#import "geom/abline.typ" as abline-geom
#import "geom/text.typ" as text-geom
#import "geom/label.typ" as label-geom
#import "legend.typ" as legend-mod

// Flatten a merged aesthetic mapping so geoms receive plain column-name
// strings. Mapping-ref annotations produced by `as-factor("col")` have
// already been consumed by scale training by the time geoms draw.
#let _strip-mapping-refs(mapping) = {
  if mapping == none { return none }
  let out = mapping
  for (k, v) in mapping.pairs() {
    if v == none { continue }
    let col = mapping-ref-col(v)
    if col != v { out.insert(k, col) }
  }
  out
}

#let _merge-mapping(layer, plot-mapping) = {
  if layer.at("inherit-aes", default: true) and plot-mapping != none {
    let m = plot-mapping
    if layer.mapping != none {
      for (k, v) in layer.mapping.pairs() {
        if v != none { m.insert(k, v) }
      }
    }
    m
  } else if layer.mapping != none {
    layer.mapping
  } else {
    plot-mapping
  }
}

#let _resolve-mapping(layer, plot-mapping) = {
  _strip-mapping-refs(_merge-mapping(layer, plot-mapping))
}

#let _resolve-data(layer, plot-data) = {
  if layer.data != none { layer.data } else { plot-data }
}

// Collect unique levels of a column from the raw (pre-stat) data across all
// layers. Used by faceting to decide panel identity before any statistical
// transformation strips or synthesises rows.
#let _raw-levels-for(spec, var) = {
  let seen = ()
  for layer in spec.layers {
    let d = _resolve-data(layer, spec.data)
    for row in d {
      let v = row.at(var, default: none)
      if v == none { continue }
      let s = str(v)
      if not seen.contains(s) { seen.push(s) }
    }
  }
  seen
}

#let _prepare-layer(layer, plot-mapping, plot-data) = {
  // Keep mapping-ref annotations intact on the layer so scale training can
  // read forced types; only strip them when the renderer hands a mapping to
  // a geom's draw function.
  let mapping = _merge-mapping(layer, plot-mapping)
  let data = _resolve-data(layer, plot-data)
  let stat-name = layer.at("stat", default: "identity")
  let params = layer.at("params", default: (:))
  let stripped = _strip-mapping-refs(mapping)

  let stat-identity = stat-name == none or stat-name == "identity"
  let stat-data = data
  let stat-mapping = if stat-identity { mapping } else { stripped }
  if not stat-identity {
    // ggplot2 v4 compute_group() pattern: split by discrete-aesthetic groups,
    // apply the stat to each group independently, then recombine.
    let gcols = group-cols(mapping)
    let group-list = partition-by-group(data, mapping)
    let combined = ()
    let last-mapping = stripped
    for g in group-list {
      let r = apply-stat(stat-name, g.data, stripped, params)
      last-mapping = r.mapping
      // Re-inject group column values from the first row of this group so
      // scale training and position adjustments can still see them.
      let proto = g.data.at(0, default: (:))
      let enriched = r.data.map(row => {
        let new-row = row
        for gc in gcols {
          if new-row.at(gc, default: none) == none {
            new-row.insert(gc, proto.at(gc, default: none))
          }
        }
        new-row
      })
      combined += enriched
    }
    stat-data = combined
    stat-mapping = last-mapping
  }

  let position-name = layer.at("position", default: "identity")
  let pos-data = stat-data
  let pos-mapping = stat-mapping
  if position-name != none and position-name != "identity" {
    // Position needs plain column names; strip again in case stat-identity
    // left annotations in place.
    let pos-in = _strip-mapping-refs(stat-mapping)
    let r = apply-position(position-name, stat-data, pos-in, params: params)
    pos-data = r.data
    // Merge position's additions (e.g. ymin/ymax) into the annotated mapping
    // while preserving existing annotations on x/y/...
    let merged = stat-mapping
    for (k, v) in r.mapping.pairs() {
      if merged.at(k, default: none) == none {
        merged.insert(k, v)
      }
    }
    pos-mapping = merged
  }

  let new = layer
  new.data = pos-data
  new.mapping = pos-mapping
  new.inherit-aes = false
  if not stat-identity { new.stat = "identity" }
  new
}

// Prepare a layer as _prepare-layer does, but on the subset of rows matching
// every (column, value) pair in `filters`. Enables per-panel stat evaluation
// so geom-smooth, geom-histogram, etc. fit their subset rather than the
// whole plot data.
#let _prepare-layer-filtered(layer, plot-mapping, plot-data, filters) = {
  let raw = _resolve-data(layer, plot-data)
  let subset = raw.filter(row => {
    let keep = true
    for (col, value) in filters {
      if str(row.at(col, default: "")) != value {
        keep = false
        break
      }
    }
    keep
  })
  let l = layer
  l.data = subset
  _prepare-layer(l, plot-mapping, plot-data)
}

#let _scale-palette(trained, fallback) = {
  let spec = trained.at("spec", default: none)
  if spec == none { return fallback }
  let p = spec.at("palette", default: auto)
  if p == auto or p == none { fallback } else { p }
}

#let _make-resolve-colour(ink) = (trained, value, palette) => {
  if trained == none or value == none or value == "" { return ink }
  let pal = _scale-palette(trained, palette)
  if trained.type == "discrete" {
    let s = str(value)
    let idx = trained.domain.position(v => v == s)
    if idx == none { return ink }
    pal.at(calc.rem(idx, pal.len()))
  } else {
    let v = if type(value) == str { float(value.trim()) } else { float(value) }
    let (d-lo, d-hi) = trained.domain
    if d-hi == d-lo { return pal.first() }
    let t = calc.max(0.0, calc.min(1.0, (v - d-lo) / (d-hi - d-lo)))
    let a = pal.first()
    let b = pal.last()
    a.mix((b, t * 100%))
  }
}

#let _format-break(n) = {
  if type(n) == int { return str(n) }
  if calc.abs(n - calc.round(n)) < 1e-9 { return str(calc.round(n)) }
  str(calc.round(n, digits: 3))
}

#let _extend-x-for-bins(trained, layers) = {
  if trained.at("x", default: none) == none { return trained }
  if trained.x.type != "continuous" { return trained }
  let max-half = 0.0
  for layer in layers {
    for row in layer.data {
      let w = row.at("width", default: none)
      if w != none and (type(w) == int or type(w) == float) {
        max-half = calc.max(max-half, w / 2)
      }
    }
  }
  if max-half == 0 { return trained }
  let (lo, hi) = trained.x.domain
  let new-x = trained.x
  new-x.insert("domain", (lo - max-half, hi + max-half))
  trained.insert("x", new-x)
  trained
}

#let _extend-y-for-ribbon(trained, layers) = {
  if trained.at("y", default: none) == none { return trained }
  if trained.y.type != "continuous" { return trained }
  let extras = ()
  for layer in layers {
    let mapping = layer.mapping
    if mapping == none { continue }
    for key in ("ymin", "ymax") {
      let col = mapping.at(key, default: none)
      if col == none { continue }
      for row in layer.data {
        let v = parse-number(row.at(col, default: none))
        if v != none { extras.push(v) }
      }
    }
  }
  if extras.len() == 0 { return trained }
  let (lo, hi) = trained.y.domain
  let new-lo = calc.min(lo, ..extras)
  let new-hi = calc.max(hi, ..extras)
  let new-y = trained.y
  new-y.insert("domain", (new-lo, new-hi))
  trained.insert("y", new-y)
  trained
}

#let _draw-axis-and-layers(
  prepared,
  trained,
  theme,
  spec,
  origin,
  inner-size,
  guides: (),
  legend-origin: none,
  legend-height: 0,
  show-x-labels: true,
  show-y-labels: true,
  show-x-title: true,
  show-y-title: true,
) = {
  import cetz.draw: *
  let (ox, oy) = origin
  let (iw, ih) = inner-size
  let px-lo = ox
  let px-hi = ox + iw
  let py-lo = oy
  let py-hi = oy + ih
  let px-range = (px-lo, px-hi)
  let py-range = (py-lo, py-hi)

  let _ink = resolve-colour(theme, "ink")
  let _ax-text-colour = resolve-colour(
    theme,
    "axis-text-colour",
    "text-colour",
    "ink",
  )
  let _ax-text-weight = resolve-field(
    theme,
    "axis-text-weight",
    "text-weight",
    fallback: "regular",
  )
  let _ax-title-colour = resolve-colour(
    theme,
    "axis-title-colour",
    "text-colour",
    "ink",
  )
  let _ax-title-weight = resolve-field(
    theme,
    "axis-title-weight",
    "text-weight",
    fallback: "regular",
  )

  let ctx = (
    trained: trained,
    px-range: px-range,
    py-range: py-range,
    palette: default-discrete,
    resolve-mapping: layer => _resolve-mapping(layer, spec.mapping),
    resolve-data: layer => _resolve-data(layer, spec.data),
    resolve-colour: _make-resolve-colour(_ink),
    theme: theme,
  )

  let _line-base = theme.at("line-colour", default: auto)
  let _rect-base = theme.at("rect-fill", default: auto)
  let _resolve-line(value) = {
    if value == none { return none }
    if value == auto {
      if _line-base != none and _line-base != auto { return _line-base }
      return _ink
    }
    value
  }
  let _resolve-rect(value, fallback) = {
    if value == none { return none }
    if value == auto {
      if _rect-base != none and _rect-base != auto { return _rect-base }
      return fallback
    }
    value
  }

  let _panel-fill = _resolve-rect(theme.panel-fill, theme.paper)
  if _panel-fill != none {
    rect(
      (px-lo, py-lo),
      (px-hi, py-hi),
      fill: _panel-fill,
      stroke: none,
    )
  }

  let x-trained = trained.at("x", default: none)
  let y-trained = trained.at("y", default: none)
  let _grid-paint = _resolve-line(theme.grid-colour)
  let grid-stroke = if _grid-paint == none { none } else {
    (paint: _grid-paint, thickness: theme.grid-thickness)
  }
  let _axis-paint = _resolve-line(theme.axis-colour)
  let axis-stroke = if _axis-paint == none { none } else {
    (paint: _axis-paint, thickness: theme.axis-thickness)
  }
  let tick-len = theme.tick-length

  if x-trained != none and x-trained.type == "continuous" {
    let breaks = pretty(x-trained.domain.at(0), x-trained.domain.at(1), n: 5)
    for b in breaks {
      let cx = map-continuous(b, x-trained.domain, px-range)
      if grid-stroke != none {
        line((cx, py-lo), (cx, py-hi), stroke: grid-stroke)
      }
      if axis-stroke != none and tick-len > 0 {
        line((cx, py-lo), (cx, py-lo - tick-len), stroke: axis-stroke)
      }
      if show-x-labels and theme.tick-labels {
        content(
          (cx, py-lo - 0.25),
          text(
            size: theme.axis-text-size,
            fill: _ax-text-colour,
            weight: _ax-text-weight,
          )[#_format-break(b)],
          anchor: "north",
        )
      }
    }
  } else if x-trained != none and x-trained.type == "discrete" {
    let n = x-trained.domain.len()
    for (idx, level) in x-trained.domain.enumerate() {
      let cx = px-lo + (idx + 0.5) * (px-hi - px-lo) / n
      if axis-stroke != none and tick-len > 0 {
        line((cx, py-lo), (cx, py-lo - tick-len), stroke: axis-stroke)
      }
      if show-x-labels and theme.tick-labels {
        content(
          (cx, py-lo - 0.25),
          text(
            size: theme.axis-text-size,
            fill: _ax-text-colour,
            weight: _ax-text-weight,
          )[#level],
          anchor: "north",
        )
      }
    }
  }

  if y-trained != none and y-trained.type == "continuous" {
    let breaks = pretty(y-trained.domain.at(0), y-trained.domain.at(1), n: 5)
    for b in breaks {
      let cy = map-continuous(b, y-trained.domain, py-range)
      if grid-stroke != none {
        line((px-lo, cy), (px-hi, cy), stroke: grid-stroke)
      }
      if axis-stroke != none and tick-len > 0 {
        line((px-lo - tick-len, cy), (px-lo, cy), stroke: axis-stroke)
      }
      if show-y-labels and theme.tick-labels {
        content(
          (px-lo - 0.2, cy),
          text(
            size: theme.axis-text-size,
            fill: _ax-text-colour,
            weight: _ax-text-weight,
          )[#_format-break(b)],
          anchor: "east",
        )
      }
    }
  }

  if axis-stroke != none {
    line((px-lo, py-lo), (px-hi, py-lo), stroke: axis-stroke)
    line((px-lo, py-lo), (px-lo, py-hi), stroke: axis-stroke)
  }

  for layer in prepared {
    if layer.geom == "point" {
      point-geom.draw(layer, ctx)
    } else if layer.geom == "line" {
      line-geom.draw(layer, ctx)
    } else if layer.geom == "col" {
      col-geom.draw(layer, ctx)
    } else if layer.geom == "ribbon" {
      ribbon-geom.draw(layer, ctx)
    } else if layer.geom == "smooth" {
      smooth-geom.draw(layer, ctx)
    } else if layer.geom == "hline" {
      hline-geom.draw(layer, ctx)
    } else if layer.geom == "vline" {
      vline-geom.draw(layer, ctx)
    } else if layer.geom == "abline" {
      abline-geom.draw(layer, ctx)
    } else if layer.geom == "text" {
      text-geom.draw(layer, ctx)
    } else if layer.geom == "label" {
      label-geom.draw(layer, ctx)
    }
  }

  let x-title = {
    let from-scale = if x-trained != none and x-trained.spec != none {
      x-trained.spec.name
    } else { none }
    if from-scale != none { from-scale } else if spec.mapping != none {
      spec.mapping.at("x", default: none)
    } else { none }
  }
  let y-title = {
    let from-scale = if y-trained != none and y-trained.spec != none {
      y-trained.spec.name
    } else { none }
    if from-scale != none { from-scale } else if spec.mapping != none {
      spec.mapping.at("y", default: none)
    } else { none }
  }
  if show-x-title and x-title != none and theme.axis-title-size > 0pt {
    content(
      ((px-lo + px-hi) / 2, oy - 0.8),
      text(
        size: theme.axis-title-size,
        fill: _ax-title-colour,
        weight: _ax-title-weight,
      )[#x-title],
      anchor: "south",
    )
  }
  if show-y-title and y-title != none and theme.axis-title-size > 0pt {
    content(
      (px-lo - 1.1, (py-lo + py-hi) / 2),
      text(
        size: theme.axis-title-size,
        fill: _ax-title-colour,
        weight: _ax-title-weight,
      )[#y-title],
      angle: 90deg,
    )
  }

  if guides.len() > 0 and legend-origin != none {
    legend-mod.draw(guides, ctx, legend-origin, legend-height, theme)
  }
}

// Inject labs `x`/`y`/... names into trained scale specs so axis and legend
// titles follow labs() just like ggplot2's / plotnine's labs() overrides.
#let _apply-labs(trained, labs) = {
  if labs == none { return trained }
  for (aes-name, label) in labs.axes.pairs() {
    if label == none { continue }
    let t = trained.at(aes-name, default: none)
    if t == none { continue }
    let spec = t.at("spec", default: none)
    let new-spec = if spec == none { (aesthetic: aes-name, name: label) } else {
      let s = spec
      s.insert("name", label)
      s
    }
    let new-t = t
    new-t.insert("spec", new-spec)
    trained.insert(aes-name, new-t)
  }
  trained
}

// coord-cartesian xlim/ylim overrides take precedence over scale training,
// so re-apply them after any per-panel retraining.
#let _apply-coord(trained, coord) = {
  if coord == none or coord.coord != "cartesian" { return trained }
  let xlim = coord.at("xlim", default: none)
  if (
    xlim != none
      and trained.at("x", default: none) != none
      and trained.x.type == "continuous"
  ) {
    let new-x = trained.x
    new-x.insert("domain", xlim)
    trained.insert("x", new-x)
  }
  let ylim = coord.at("ylim", default: none)
  if (
    ylim != none
      and trained.at("y", default: none) != none
      and trained.y.type == "continuous"
  ) {
    let new-y = trained.y
    new-y.insert("domain", ylim)
    trained.insert("y", new-y)
  }
  trained
}

// Apply post-training domain fix-ups (bar-zero floor, bin width padding,
// ribbon ymin/ymax padding). Called once globally and once per panel under
// free scales so each panel's domain reflects its own subset.
#let _post-train(trained, layers) = {
  let has-bar = layers.any(l => l.geom == "col")
  if (
    has-bar
      and trained.at("y", default: none) != none
      and trained.y.type == "continuous"
  ) {
    let (lo, hi) = trained.y.domain
    let new-y = trained.y
    new-y.insert("domain", (calc.min(lo, 0.0), calc.max(hi, 0.0)))
    trained.insert("y", new-y)
  }
  trained = _extend-x-for-bins(trained, layers)
  trained = _extend-y-for-ribbon(trained, layers)
  trained
}

#let render-plot(spec) = {
  let theme = merge-theme(spec.theme)
  let labs = spec.at("labs", default: none)

  // Pre-resolve theme colours and fields used across the renderer.
  let _strip-fill = resolve-colour(theme, "strip-fill", "rect-fill", "paper")
  let _strip-text-size = theme.at("strip-text-size", default: 8pt)
  let _strip-text-colour = resolve-colour(
    theme,
    "strip-text-colour",
    "text-colour",
    "ink",
  )
  let _strip-text-weight = resolve-field(
    theme,
    "strip-text-weight",
    "text-weight",
    fallback: "medium",
  )
  let _ax-title-colour = resolve-colour(
    theme,
    "axis-title-colour",
    "text-colour",
    "ink",
  )
  let _ax-title-weight = resolve-field(
    theme,
    "axis-title-weight",
    "text-weight",
    fallback: "regular",
  )

  // Faceted plots prepare layers per panel so that stats (smooth, bin,
  // count) are computed on each panel's own subset of rows — the
  // grammar-of-graphics semantics followed by ggplot2 and plotnine.
  // Non-faceted plots run the classic single-pass preparation.
  let facet-wrap-mode = spec.facet != none and spec.facet.facet == "wrap"
  let facet-grid-mode = spec.facet != none and spec.facet.facet == "grid"

  let wrap-levels = if facet-wrap-mode {
    _raw-levels-for(spec, spec.facet.var)
  } else { () }

  let grid-row-levels = if facet-grid-mode and spec.facet.rows != none {
    _raw-levels-for(spec, spec.facet.rows)
  } else if facet-grid-mode { ("",) } else { () }
  let grid-col-levels = if facet-grid-mode and spec.facet.cols != none {
    _raw-levels-for(spec, spec.facet.cols)
  } else if facet-grid-mode { ("",) } else { () }

  // panels: list of (key: ..., layers: (prepared-layer, ...))
  // For wrap, key is the level string. For grid, key is a (row, col) pair.
  let panels = if facet-wrap-mode {
    wrap-levels.map(level => (
      level: level,
      layers: spec.layers.map(l => _prepare-layer-filtered(
        l,
        spec.mapping,
        spec.data,
        ((spec.facet.var, level),),
      )),
    ))
  } else if facet-grid-mode {
    let out = ()
    for row-lv in grid-row-levels {
      for col-lv in grid-col-levels {
        let filters = ()
        if spec.facet.rows != none { filters.push((spec.facet.rows, row-lv)) }
        if spec.facet.cols != none { filters.push((spec.facet.cols, col-lv)) }
        out.push((
          row-level: row-lv,
          col-level: col-lv,
          layers: spec.layers.map(l => _prepare-layer-filtered(
            l,
            spec.mapping,
            spec.data,
            filters,
          )),
        ))
      }
    }
    out
  } else { () }

  // `prepared` is the training set. For faceted plots it is the union of
  // every panel's prepared layers, so shared (fixed) scales span all panels
  // exactly. For non-faceted plots it is the classic plot-wide preparation.
  let prepared = if facet-wrap-mode or facet-grid-mode {
    let union = ()
    for panel in panels { union += panel.layers }
    union
  } else {
    spec.layers.map(l => _prepare-layer(l, spec.mapping, spec.data))
  }

  let trained = train(
    scales: spec.scales,
    layers: prepared,
    mapping: spec.mapping,
    data: spec.data,
  )
  trained = _apply-labs(trained, labs)

  // Once training is done, mapping-ref annotations have served their purpose;
  // flatten them so geoms receive plain column names.
  prepared = prepared.map(l => {
    let new = l
    new.mapping = _strip-mapping-refs(l.mapping)
    new
  })
  panels = panels.map(p => {
    let new = p
    new.layers = p.layers.map(l => {
      let ll = l
      ll.mapping = _strip-mapping-refs(l.mapping)
      ll
    })
    new
  })

  trained = _post-train(trained, prepared)

  // coord-cartesian zooms the view: override trained domains with the user's
  // clip limits so axis ticks and marks follow them. Data outside still exists
  // for stats and training but may render outside the panel. This preserves
  // ggplot's "data is not dropped" distinction.
  let coord = spec.at("coord", default: none)
  trained = _apply-coord(trained, coord)

  // For facet-wrap with non-fixed scales, train each panel's positional axes
  // on its own subset so x and/or y differ across panels. Non-positional
  // scales (colour, fill, size, shape, linetype) stay shared so legends do
  // not fragment.
  let wrap-scales = if facet-wrap-mode { spec.facet.scales } else { "fixed" }
  let free-x = wrap-scales == "free" or wrap-scales == "free_x"
  let free-y = wrap-scales == "free" or wrap-scales == "free_y"
  let panel-trained-list = if facet-wrap-mode and (free-x or free-y) {
    panels.map(p => {
      let pt = train(
        scales: spec.scales,
        layers: p.layers,
        mapping: spec.mapping,
        data: spec.data,
      )
      pt = _apply-labs(pt, labs)
      pt = _post-train(pt, p.layers)
      pt = _apply-coord(pt, coord)
      let merged = trained
      if free-x and pt.at("x", default: none) != none {
        merged.insert("x", pt.x)
      }
      if free-y and pt.at("y", default: none) != none {
        merged.insert("y", pt.y)
      }
      merged
    })
  } else { () }

  let width-units = spec.width / 1cm
  let height-units = spec.height / 1cm

  let guides = legend-mod.guides-for(spec, trained)
  let legend-width = legend-mod.estimate-width(guides)
  let legend-gap = if legend-width > 0 { 0.25 } else { 0.0 }

  let margin = (
    left: 1.3,
    bottom: 0.9,
    top: 0.3,
    right: 0.3 + legend-gap + legend-width,
  )

  let canvas = if facet-wrap-mode {
    let levels = wrap-levels
    let n = levels.len()
    let ncol = if spec.facet.ncol != none {
      spec.facet.ncol
    } else if spec.facet.nrow != none {
      calc.ceil(n / spec.facet.nrow)
    } else {
      calc.max(1, int(calc.ceil(calc.sqrt(n))))
    }
    let nrow = calc.max(1, int(calc.ceil(n / ncol)))
    let strip-h = 0.45
    let gutter-x = 0.4
    let gutter-y = 0.4
    let grid-w = width-units - margin.left - margin.right
    let grid-h = height-units - margin.bottom - margin.top
    let panel-w = (grid-w - gutter-x * (ncol - 1)) / ncol
    let panel-h = (grid-h - gutter-y * (nrow - 1) - strip-h * nrow) / nrow

    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      for (i, level) in levels.enumerate() {
        let col = calc.rem(i, ncol)
        let row = int(i / ncol)
        let x0 = margin.left + col * (panel-w + gutter-x)
        let y0 = (
          margin.bottom + (nrow - 1 - row) * (panel-h + gutter-y + strip-h)
        )
        rect(
          (x0, y0 + panel-h),
          (x0 + panel-w, y0 + panel-h + strip-h),
          fill: _strip-fill,
          stroke: none,
        )
        content(
          (x0 + panel-w / 2, y0 + panel-h + strip-h / 2),
          text(
            size: _strip-text-size,
            fill: _strip-text-colour,
            weight: _strip-text-weight,
          )[#level],
        )
        let panel-layers = panels.at(i).layers
        let panel-trained = if panel-trained-list.len() == 0 {
          trained
        } else { panel-trained-list.at(i) }
        _draw-axis-and-layers(
          panel-layers,
          panel-trained,
          theme,
          spec,
          (x0, y0),
          (panel-w, panel-h),
          show-x-labels: free-x or row == nrow - 1,
          show-y-labels: free-y or col == 0,
          show-x-title: false,
          show-y-title: false,
        )
      }

      // Overall titles.
      let x-trained = trained.at("x", default: none)
      let y-trained = trained.at("y", default: none)
      let x-title = {
        let from-scale = if x-trained != none and x-trained.spec != none {
          x-trained.spec.name
        } else { none }
        if from-scale != none { from-scale } else if spec.mapping != none {
          spec.mapping.at("x", default: none)
        } else { none }
      }
      let y-title = {
        let from-scale = if y-trained != none and y-trained.spec != none {
          y-trained.spec.name
        } else { none }
        if from-scale != none { from-scale } else if spec.mapping != none {
          spec.mapping.at("y", default: none)
        } else { none }
      }
      if x-title != none and theme.axis-title-size > 0pt {
        content(
          (margin.left + grid-w / 2, 0.1),
          text(
            size: theme.axis-title-size,
            fill: _ax-title-colour,
            weight: _ax-title-weight,
          )[#x-title],
          anchor: "south",
        )
      }
      if y-title != none and theme.axis-title-size > 0pt {
        content(
          (0.2, margin.bottom + grid-h / 2),
          text(
            size: theme.axis-title-size,
            fill: _ax-title-colour,
            weight: _ax-title-weight,
          )[#y-title],
          angle: 90deg,
        )
      }

      if guides.len() > 0 {
        let ctx = (
          trained: trained,
          palette: default-discrete,
          theme: theme,
        )
        legend-mod.draw(
          guides,
          ctx,
          (margin.left + grid-w + legend-gap, margin.bottom),
          grid-h,
          theme,
        )
      }
    })
  } else if facet-grid-mode {
    let row-var = spec.facet.rows
    let col-var = spec.facet.cols
    let row-levels = grid-row-levels
    let col-levels = grid-col-levels
    let n-rows = calc.max(1, row-levels.len())
    let n-cols = calc.max(1, col-levels.len())
    let strip-h = 0.45
    let strip-w = 0.55
    let gutter-x = 0.3
    let gutter-y = 0.3
    let top-strip = if col-var != none { strip-h } else { 0.0 }
    let right-strip = if row-var != none { strip-w } else { 0.0 }
    let inner-right = margin.right + right-strip
    let grid-w = width-units - margin.left - inner-right
    let grid-h = height-units - margin.bottom - margin.top - top-strip
    let panel-w = (grid-w - gutter-x * (n-cols - 1)) / n-cols
    let panel-h = (grid-h - gutter-y * (n-rows - 1)) / n-rows

    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      for (r, row-lv) in row-levels.enumerate() {
        for (c, col-lv) in col-levels.enumerate() {
          let x0 = margin.left + c * (panel-w + gutter-x)
          let y0 = margin.bottom + (n-rows - 1 - r) * (panel-h + gutter-y)
          let panel-layers = panels.at(r * n-cols + c).layers
          _draw-axis-and-layers(
            panel-layers,
            trained,
            theme,
            spec,
            (x0, y0),
            (panel-w, panel-h),
            show-x-labels: r == n-rows - 1,
            show-y-labels: c == 0,
            show-x-title: false,
            show-y-title: false,
          )
        }
      }

      // Column strips on top.
      if col-var != none {
        let strip-y = margin.bottom + grid-h
        for (c, col-lv) in col-levels.enumerate() {
          let x0 = margin.left + c * (panel-w + gutter-x)
          rect(
            (x0, strip-y),
            (x0 + panel-w, strip-y + top-strip),
            fill: _strip-fill,
            stroke: none,
          )
          content(
            (x0 + panel-w / 2, strip-y + top-strip / 2),
            text(
              size: _strip-text-size,
              fill: _strip-text-colour,
              weight: _strip-text-weight,
            )[#col-lv],
          )
        }
      }

      // Row strips on the right.
      if row-var != none {
        let strip-x = margin.left + grid-w
        for (r, row-lv) in row-levels.enumerate() {
          let y0 = margin.bottom + (n-rows - 1 - r) * (panel-h + gutter-y)
          rect(
            (strip-x, y0),
            (strip-x + right-strip, y0 + panel-h),
            fill: _strip-fill,
            stroke: none,
          )
          content(
            (strip-x + right-strip / 2, y0 + panel-h / 2),
            text(
              size: _strip-text-size,
              fill: _strip-text-colour,
              weight: _strip-text-weight,
            )[#row-lv],
            angle: -90deg,
          )
        }
      }

      // Overall titles.
      let x-trained = trained.at("x", default: none)
      let y-trained = trained.at("y", default: none)
      let x-title = {
        let from-scale = if x-trained != none and x-trained.spec != none {
          x-trained.spec.name
        } else { none }
        if from-scale != none { from-scale } else if spec.mapping != none {
          spec.mapping.at("x", default: none)
        } else { none }
      }
      let y-title = {
        let from-scale = if y-trained != none and y-trained.spec != none {
          y-trained.spec.name
        } else { none }
        if from-scale != none { from-scale } else if spec.mapping != none {
          spec.mapping.at("y", default: none)
        } else { none }
      }
      if x-title != none and theme.axis-title-size > 0pt {
        content(
          (margin.left + grid-w / 2, 0.1),
          text(
            size: theme.axis-title-size,
            fill: _ax-title-colour,
            weight: _ax-title-weight,
          )[#x-title],
          anchor: "south",
        )
      }
      if y-title != none and theme.axis-title-size > 0pt {
        content(
          (0.2, margin.bottom + grid-h / 2),
          text(
            size: theme.axis-title-size,
            fill: _ax-title-colour,
            weight: _ax-title-weight,
          )[#y-title],
          angle: 90deg,
        )
      }

      if guides.len() > 0 {
        let ctx = (
          trained: trained,
          palette: default-discrete,
          theme: theme,
        )
        legend-mod.draw(
          guides,
          ctx,
          (margin.left + grid-w + right-strip + legend-gap, margin.bottom),
          grid-h,
          theme,
        )
      }
    })
  } else {
    let px-lo = margin.left
    let px-hi = width-units - margin.right
    let py-lo = margin.bottom
    let py-hi = height-units - margin.top

    cetz.canvas(length: 1cm, {
      _draw-axis-and-layers(
        prepared,
        trained,
        theme,
        spec,
        (px-lo, py-lo),
        (px-hi - px-lo, py-hi - py-lo),
        guides: guides,
        legend-origin: (px-hi + legend-gap, py-lo),
        legend-height: py-hi - py-lo,
      )
    })
  }

  if labs == none { return canvas }
  let title-block = if labs.title != none {
    text(
      size: theme.at("plot-title-size", default: 12pt),
      weight: resolve-field(
        theme,
        "plot-title-weight",
        "text-weight",
        fallback: "bold",
      ),
      fill: resolve-colour(theme, "plot-title-colour", "text-colour", "ink"),
    )[#labs.title]
  } else { none }
  let subtitle-block = if labs.subtitle != none {
    text(
      size: theme.at("plot-subtitle-size", default: 9pt),
      fill: resolve-colour(theme, "plot-subtitle-colour", "text-colour", "ink"),
    )[#labs.subtitle]
  } else { none }
  let caption-block = if labs.caption != none {
    text(
      size: theme.at("plot-caption-size", default: 8pt),
      fill: resolve-colour(theme, "plot-caption-colour", "text-colour", "ink"),
      style: "italic",
    )[#labs.caption]
  } else { none }

  let parts = ()
  if title-block != none { parts.push(title-block) }
  if subtitle-block != none { parts.push(subtitle-block) }
  parts.push(canvas)
  if caption-block != none { parts.push(caption-block) }
  if parts.len() == 1 { return canvas }
  block(stack(dir: ttb, spacing: 0.3em, ..parts))
}
