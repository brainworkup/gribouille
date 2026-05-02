// CeTZ rendering glue.
// Draws a single cartesian panel with axes and layer marks.

#import "deps.typ": cetz
#import "scale/train.typ": (
  map-axis, map-continuous, map-position, mapping-ref-col,
  positional-aesthetics, train, transform-fwd, transform-inv,
)
#import "scale/expansion.typ": DISCRETE-AUTO-DATA-PAD, normalise-expansion
#import "stat/apply.typ": apply-stat, stat-default-params
#import "position/apply.typ": apply-position
#import "theme/defaults.typ": merge-theme, resolve-colour
#import "theme/theme.typ": _line-stroke, _rect-fill, _text-style
#import "utils/pretty.typ": pretty, pretty-log10, pretty-sqrt
#import "utils/types.typ": parse-number
#import "utils/palette.typ": default-discrete, palette-at, spec-palette
#import "utils/colour.typ": resolve-continuous-colour
#import "utils/group.typ": group-cols, partition-by-group
#import "utils/typst-markup.typ": is-typst-markup, resolve-prose
#import "utils/aes-resolve.typ": resolve-label, unwrap-mapping-refs
#import "data.typ": _normalise-data, group-by
#import "geom/point.typ" as point-geom
#import "geom/line.typ" as line-geom
#import "geom/path.typ" as path-geom
#import "geom/step.typ" as step-geom
#import "geom/area.typ" as area-geom
#import "geom/rect.typ" as rect-geom
#import "geom/tile.typ" as tile-geom
#import "geom/segment.typ" as segment-geom
#import "geom/curve.typ" as curve-geom
#import "geom/spoke.typ" as spoke-geom
#import "geom/polygon.typ" as polygon-geom
#import "geom/ellipse.typ" as ellipse-geom
#import "geom/mark.typ" as mark-geom
#import "geom/col.typ" as col-geom
#import "geom/ribbon.typ" as ribbon-geom
#import "geom/smooth.typ" as smooth-geom
#import "geom/hline.typ" as hline-geom
#import "geom/vline.typ" as vline-geom
#import "geom/abline.typ" as abline-geom
#import "geom/text.typ" as text-geom
#import "geom/typst.typ" as typst-geom
#import "geom/label.typ" as label-geom
#import "geom/boxplot.typ" as boxplot-geom
#import "geom/errorbar.typ" as errorbar-geom
#import "geom/errorbarh.typ" as errorbarh-geom
#import "geom/linerange.typ" as linerange-geom
#import "geom/crossbar.typ" as crossbar-geom
#import "geom/pointrange.typ" as pointrange-geom
#import "geom/blank.typ" as blank-geom
#import "geom/rug.typ" as rug-geom
#import "geom/function.typ" as function-geom
#import "geom/dotplot.typ" as dotplot-geom

// Single source of truth for layer dispatch in `_draw-axis-and-layers`.
// Each entry maps a layer's `geom` string to its `draw(layer, ctx)` function.
// Adding a new geom only requires importing it above and adding an entry here.
#let _geom-draw = (
  point: point-geom.draw,
  line: line-geom.draw,
  path: path-geom.draw,
  step: step-geom.draw,
  area: area-geom.draw,
  rect: rect-geom.draw,
  tile: tile-geom.draw,
  segment: segment-geom.draw,
  curve: curve-geom.draw,
  spoke: spoke-geom.draw,
  polygon: polygon-geom.draw,
  ellipse: ellipse-geom.draw,
  mark: mark-geom.draw,
  col: col-geom.draw,
  ribbon: ribbon-geom.draw,
  smooth: smooth-geom.draw,
  hline: hline-geom.draw,
  vline: vline-geom.draw,
  abline: abline-geom.draw,
  text: text-geom.draw,
  typst: typst-geom.draw,
  label: label-geom.draw,
  boxplot: boxplot-geom.draw,
  errorbar: errorbar-geom.draw,
  errorbarh: errorbarh-geom.draw,
  linerange: linerange-geom.draw,
  crossbar: crossbar-geom.draw,
  pointrange: pointrange-geom.draw,
  blank: blank-geom.draw,
  rug: rug-geom.draw,
  function: function-geom.draw,
  dotplot: dotplot-geom.draw,
)
#import "legend.typ" as legend-mod
#import "facet/labellers.typ" as labellers
#import "scale/secondary.typ" as secondary-mod

// Flatten a merged aesthetic mapping so geoms receive plain column-name
// strings. Both `mapping-ref` annotations (`as-factor`/`as-numeric`) and
// `typst-markup` annotations (`typst()`) are collapsed; the typst intent
// is captured separately by `_typst-marks-of` so display surfaces can
// honour it.
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

// Build a dictionary of `(aes-name: true)` entries for every aesthetic
// whose mapping value carries a `typst-markup` tag (at any nesting depth
// inside `mapping-ref` wrappers). Returns an empty dict when nothing is
// typst-tagged.
#let _typst-marks-of(mapping) = {
  let marks = (:)
  if mapping == none { return marks }
  for (k, v) in mapping.pairs() {
    if v == none { continue }
    if is-typst-markup(v) { marks.insert(k, true) }
  }
  marks
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

// `data-trusted: true` on the layer signals that `layer.data` is already in
// canonical row-store form; the faceted path sets it on per-panel buckets it
// has just produced from a normalised source, avoiding a second validation
// pass over the same rows.
#let _resolve-data(layer, plot-data) = {
  if layer.data == none { return plot-data }
  if layer.at("data-trusted", default: false) { return layer.data }
  _normalise-data(layer.data)
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
  // `stat:` accepts either a string name (with default params from the geom's
  // own params dict) or a dict returned by a `stat-*()` constructor carrying
  // its own name and params. Match the same pattern used for `position:` below.
  let stat-spec = layer.at("stat", default: "identity")
  let params = layer.at("params", default: (:))
  let stat-name = if type(stat-spec) == str {
    stat-spec
  } else { stat-spec.at("name", default: "identity") }
  let stat-params = if type(stat-spec) == str {
    stat-default-params(stat-name)
  } else {
    stat-spec.at("params", default: (:))
  }
  let stripped = _strip-mapping-refs(mapping)

  let stat-identity = stat-name == none or stat-name == "identity"
  let stat-data = data
  let stat-mapping = if stat-identity { mapping } else { stripped }
  if not stat-identity {
    // compute-group pattern: split by discrete-aesthetic groups,
    // apply the stat to each group independently, then recombine.
    let gcols = group-cols(mapping)
    let group-list = partition-by-group(data, mapping)
    let combined = ()
    let last-mapping = stripped
    for g in group-list {
      let r = apply-stat(stat-name, g.data, stripped, stat-params)
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

  // `position:` accepts either a string name (default params) or a dict
  // returned by a `position-*()` constructor carrying its own params.
  let position-spec = layer.at("position", default: "identity")
  let position-name = if type(position-spec) == str {
    position-spec
  } else { position-spec.at("name", default: "identity") }
  let position-params = if type(position-spec) == str { params } else {
    position-spec
  }
  let pos-data = stat-data
  let pos-mapping = stat-mapping
  if position-name != none and position-name != "identity" {
    // Position needs plain column names; strip again in case stat-identity
    // left annotations in place.
    let pos-in = _strip-mapping-refs(stat-mapping)
    let r = apply-position(
      position-name,
      stat-data,
      pos-in,
      params: position-params,
    )
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
  new.typst-marks = _typst-marks-of(mapping)
  if not stat-identity { new.stat = "identity" }
  new
}

// Build a colour resolver curried over the (trained, palette) pair so per-row
// callers resolve the palette once outside the row loop and call the returned
// closure with bare values. One-shot callers can still chain immediately:
// `(ctx.resolve-colour)(trained, palette)(value)`.
#let _make-resolve-colour(ink) = (trained, palette) => {
  if trained == none {
    return _ => ink
  }
  if trained.type == "identity" {
    return value => {
      if value == none or value == "" { return ink }
      if type(value) == color { return value }
      if type(value) == str { return rgb(value) }
      ink
    }
  }
  let pal = spec-palette(trained, palette)
  if trained.type == "discrete" {
    return value => {
      if value == none or value == "" { return ink }
      let s = str(value)
      let idx = trained.domain.position(v => v == s)
      if idx == none { return ink }
      palette-at(pal, idx)
    }
  }
  value => {
    if value == none or value == "" { return ink }
    let v = if type(value) == str { float(value.trim()) } else { float(value) }
    resolve-continuous-colour(trained, v, pal, ink)
  }
}

// Transform-aware axis break dispatch. Honours the trained scale's
// `transform` so log10 and sqrt panels get geometry-aware ticks instead of
// bunched linear ticks. If the user spec carries `binned: true`, ticks are
// placed at bin midpoints so labels sit under each `n-breaks`-wide
// quantised interval.
#let _axis-breaks(trained) = {
  let spec = trained.at("spec", default: none)
  let binned = if spec == none { false } else {
    spec.at("binned", default: false)
  }
  if binned {
    let (lo, hi) = trained.domain
    let n = if spec == none { 10 } else { spec.at("n-breaks", default: 10) }
    let count = calc.max(1, int(n))
    let span = hi - lo
    if span <= 0 { return (lo,) }
    let step = span / count
    return range(count).map(i => lo + (i + 0.5) * step)
  }
  let transform = trained.at("transform", default: none)
  let view-transform = trained.at("view-transform", default: none)
  let (lo, hi) = if view-transform != none {
    (
      transform-inv(transform, view-transform.at(0)),
      transform-inv(transform, view-transform.at(1)),
    )
  } else {
    trained.domain
  }
  if transform == "log10" { return pretty-log10(lo, hi) }
  if transform == "sqrt" { return pretty-sqrt(lo, hi) }
  pretty(lo, hi, n: 5)
}

#let _format-break(n) = {
  if type(n) == int { return str(n) }
  if calc.abs(n - calc.round(n)) < 1e-9 { return str(calc.round(n)) }
  str(calc.round(n, digits: 3))
}

// Convert a numeric break back to a Typst datetime against a fixed epoch and
// render it via `dt.display(fmt)`. `kind` selects the unit of `n`: `"date"`
// counts whole days, `"datetime"` and `"time"` count whole seconds.
#let _format-temporal(n, kind, fmt) = {
  let epoch = datetime(
    year: 2000,
    month: 1,
    day: 1,
    hour: 0,
    minute: 0,
    second: 0,
  )
  let dt = if kind == "date" {
    epoch + duration(days: int(calc.round(n)))
  } else {
    epoch + duration(seconds: int(calc.round(n)))
  }
  dt.display(fmt)
}

#let _axis-label(trained, n) = {
  let temporal = trained.at("temporal", default: none)
  if temporal != none {
    return _format-temporal(
      n,
      temporal,
      trained.at("date-format", default: ""),
    )
  }
  _format-break(n)
}

// Single-pass classifier feeding `_post-train`. Per layer it picks the
// minimal row scan needed (col layers project parsed x values; binned and
// ribbon layers fold per-row aggregates) so non-col, non-binned, non-ribbon
// layers skip the row loop entirely.
#let _post-train-scan(layers) = {
  let needs-y-zero = false
  let any-fill = false
  let cols = ()
  let bin-half-max = 0.0
  let ribbon-y-min = none
  let ribbon-y-max = none
  let ellipse-x-min = none
  let ellipse-x-max = none
  let ellipse-y-min = none
  let ellipse-y-max = none
  for layer in layers {
    let geom = layer.at("geom", default: none)
    if geom == "col" or geom == "area" { needs-y-zero = true }

    let mapping = layer.at("mapping", default: none)
    let layer-data = layer.at("data", default: ())

    if geom == "ellipse" and mapping != none {
      let x0-col = mapping.at("x0", default: none)
      let y0-col = mapping.at("y0", default: none)
      let a-col = mapping.at("a", default: none)
      let b-col = mapping.at("b", default: none)
      if x0-col != none and y0-col != none {
        let params = layer.at("params", default: (:))
        let a-fb = params.at("a", default: 1)
        let b-fb = params.at("b", default: 1)
        for row in layer-data {
          let x0 = parse-number(row.at(x0-col, default: none))
          let y0 = parse-number(row.at(y0-col, default: none))
          if x0 == none or y0 == none { continue }
          let a = if a-col == none { a-fb } else {
            let v = parse-number(row.at(a-col, default: none))
            if v == none { a-fb } else { v }
          }
          let b = if b-col == none { b-fb } else {
            let v = parse-number(row.at(b-col, default: none))
            if v == none { b-fb } else { v }
          }
          let r = calc.max(calc.abs(a), calc.abs(b))
          ellipse-x-min = if ellipse-x-min == none { x0 - r } else {
            calc.min(ellipse-x-min, x0 - r)
          }
          ellipse-x-max = if ellipse-x-max == none { x0 + r } else {
            calc.max(ellipse-x-max, x0 + r)
          }
          ellipse-y-min = if ellipse-y-min == none { y0 - r } else {
            calc.min(ellipse-y-min, y0 - r)
          }
          ellipse-y-max = if ellipse-y-max == none { y0 + r } else {
            calc.max(ellipse-y-max, y0 + r)
          }
        }
      }
    }
    let ymin-col = if mapping != none {
      mapping.at("ymin", default: none)
    } else { none }
    let ymax-col = if mapping != none {
      mapping.at("ymax", default: none)
    } else { none }
    let scan-width = (
      layer-data.len() > 0
        and layer-data.first().at("width", default: none) != none
    )

    if geom == "col" {
      if layer.at("position", default: "identity") == "fill" {
        any-fill = true
      }
      let x-col = if mapping != none {
        mapping.at("x", default: none)
      } else { none }
      let xs = if x-col != none {
        layer-data
          .map(r => parse-number(r.at(x-col, default: none)))
          .filter(v => v != none)
      } else { () }
      cols.push((
        bar-frac: layer.at("params", default: (:)).at("width", default: 0.9),
        xs: xs,
      ))
    }

    if not (scan-width or ymin-col != none or ymax-col != none) { continue }
    for row in layer-data {
      if scan-width {
        let w = row.at("width", default: none)
        if w != none and (type(w) == int or type(w) == float) {
          bin-half-max = calc.max(bin-half-max, w / 2)
        }
      }
      for col in (ymin-col, ymax-col) {
        if col == none { continue }
        let v = parse-number(row.at(col, default: none))
        if v == none { continue }
        ribbon-y-min = if ribbon-y-min == none { v } else {
          calc.min(ribbon-y-min, v)
        }
        ribbon-y-max = if ribbon-y-max == none { v } else {
          calc.max(ribbon-y-max, v)
        }
      }
    }
  }
  (
    needs-y-zero: needs-y-zero,
    any-fill: any-fill,
    cols: cols,
    bin-half-max: bin-half-max,
    ribbon-y-min: ribbon-y-min,
    ribbon-y-max: ribbon-y-max,
    ellipse-x-min: ellipse-x-min,
    ellipse-x-max: ellipse-x-max,
    ellipse-y-min: ellipse-y-min,
    ellipse-y-max: ellipse-y-max,
  )
}

// `geom-col` centres each bar on its category value and draws it from
// `centre ± min-gap * bar-frac / 2`. On a continuous category axis the
// trained domain is `(min, max)` of the raw values, so the outer bars hang
// off the panel by half a bar width. Mirror the geom's minimum-gap heuristic
// to compute the half-width in domain units and pad the trained domain on
// both sides. The renderer applies coord-flip after `_post-train`, so
// padding pre-flip x covers both orientations.
#let _col-half-width-x(cols) = {
  let max-half = 0.0
  for layer in cols {
    let sorted = layer.xs.dedup().sorted()
    if sorted.len() < 2 { continue }
    let gaps = range(sorted.len() - 1).map(i => (
      sorted.at(i + 1) - sorted.at(i)
    ))
    let min-gap = calc.min(..gaps)
    let half = min-gap * layer.bar-frac / 2
    if half > max-half { max-half = half }
  }
  max-half
}

// Pre-compute primary and secondary x/y axis breaks for a trained scale set.
// Callers that share `trained` across panels (e.g. grid facets without free
// scales) build this once and pass it down so per-panel renders skip the
// redundant `_axis-breaks` calls.
#let _shared-axis-breaks(trained) = {
  let xt = trained.at("x", default: none)
  let yt = trained.at("y", default: none)
  let x-breaks = if xt != none and xt.type == "continuous" {
    _axis-breaks(xt)
  } else { none }
  let y-breaks = if yt != none and yt.type == "continuous" {
    _axis-breaks(yt)
  } else { none }
  let x-sec-breaks = if xt != none and xt.type == "continuous" {
    let spec = xt.at("spec", default: none)
    if spec != none and spec.at("secondary", default: none) != none {
      x-breaks
    } else { none }
  } else { none }
  let y-sec-breaks = if yt != none and yt.type == "continuous" {
    let spec = yt.at("spec", default: none)
    if spec != none and spec.at("secondary", default: none) != none {
      y-breaks
    } else { none }
  } else { none }
  (x: x-breaks, y: y-breaks, x-sec: x-sec-breaks, y-sec: y-sec-breaks)
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
  show-x-sec: true,
  show-y-sec: true,
  flipped: false,
  axis-breaks: none,
) = {
  import cetz.draw: *
  let (ox, oy) = origin
  let (iw, ih) = inner-size
  let px-lo = ox
  let px-hi = ox + iw
  let py-lo = oy
  let py-hi = oy + ih
  // `px-range`/`py-range` carry the inset *data area* (panel bounds shrunk by
  // any canvas-cm padding from `view-pad-cm`), so geoms and ticks land on the
  // correct data positions. Bare `px-lo`/`py-lo`/`px-hi`/`py-hi` keep the
  // outer panel bounds and are used for axis lines, panel fill, and gridline
  // endpoints that span the full panel.
  let _read-pad(t) = if t == none { (0, 0) } else {
    t.at("view-pad-cm", default: (0, 0))
  }
  let (x-pad-lo, x-pad-hi) = _read-pad(trained.at("x", default: none))
  let (y-pad-lo, y-pad-hi) = _read-pad(trained.at("y", default: none))
  let px-range = (px-lo + x-pad-lo, px-hi - x-pad-hi)
  let py-range = (py-lo + y-pad-lo, py-hi - y-pad-hi)

  let _ink = resolve-colour(theme, "ink")
  let _ax-text = _text-style(theme, "axis-text")
  let _ax-title = _text-style(theme, "axis-title")

  let _resolve-mapping-flipped(layer) = {
    let m = _resolve-mapping(layer, spec.mapping)
    if not flipped or m == none { return m }
    let x = m.at("x", default: none)
    let y = m.at("y", default: none)
    let out = m
    out.insert("x", y)
    out.insert("y", x)
    out
  }

  let ctx = (
    trained: trained,
    px-range: px-range,
    py-range: py-range,
    palette: default-discrete,
    resolve-mapping: layer => _resolve-mapping-flipped(layer),
    resolve-data: layer => _resolve-data(layer, spec.data),
    resolve-colour: _make-resolve-colour(_ink),
    theme: theme,
    flipped: flipped,
  )

  let _panel-fill = _rect-fill(theme, "panel-background", fallback: theme.paper)
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
  let grid-stroke = _line-stroke(theme, "panel-grid", fallback-colour: _ink)
  let axis-stroke = _line-stroke(theme, "axis-line", fallback-colour: _ink)
  let tick-len = theme.tick-length

  let _read-axis-guide(aes) = {
    let g = spec.at("guides", default: (:)).at(aes, default: none)
    if g == none { (angle: 0, n-dodge: 1, logticks: false) } else {
      (
        angle: g.at("angle", default: 0),
        n-dodge: calc.max(1, g.at("n-dodge", default: 1)),
        logticks: g.at("logticks", default: false),
      )
    }
  }
  let x-guide = _read-axis-guide("x")
  let y-guide = _read-axis-guide("y")
  let _x-label-anchor(angle) = {
    if angle == 0 { "north" } else if angle > 0 { "north-east" } else {
      "north-west"
    }
  }
  let _draw-x-label(cx, label-text, idx) = {
    if not (show-x-labels and theme.tick-labels) { return }
    let dodge-row = calc.rem(idx, x-guide.n-dodge)
    let row-gap = 0.35
    let cy = py-lo - 0.25 - dodge-row * row-gap
    content(
      (cx, cy),
      text(
        size: _ax-text.size,
        fill: _ax-text.fill,
        weight: _ax-text.weight,
      )[#label-text],
      anchor: _x-label-anchor(x-guide.angle),
      angle: x-guide.angle * 1deg,
    )
  }
  let _draw-y-label(cy, label-text, idx) = {
    if not (show-y-labels and theme.tick-labels) { return }
    let dodge-col = calc.rem(idx, y-guide.n-dodge)
    let col-gap = 0.5
    let cx = px-lo - 0.2 - dodge-col * col-gap
    content(
      (cx, cy),
      text(
        size: _ax-text.size,
        fill: _ax-text.fill,
        weight: _ax-text.weight,
      )[#label-text],
      anchor: "east",
      angle: y-guide.angle * 1deg,
    )
  }

  let _axis-display(trained) = (
    typst-mark: if trained != none {
      trained.at("typst-mark", default: false)
    } else { false },
    labels: if trained != none and trained.at("spec", default: none) != none {
      trained.spec.at("labels", default: auto)
    } else { auto },
  )
  let _x-disp = _axis-display(x-trained)
  let _y-disp = _axis-display(y-trained)

  if x-trained != none and x-trained.type == "continuous" {
    let breaks = if axis-breaks != none and axis-breaks.x != none {
      axis-breaks.x
    } else { _axis-breaks(x-trained) }
    for (idx, b) in breaks.enumerate() {
      let cx = map-axis(x-trained, b, px-range)
      if grid-stroke != none {
        line((cx, py-lo), (cx, py-hi), stroke: grid-stroke)
      }
      if axis-stroke != none and tick-len > 0 {
        line((cx, py-lo), (cx, py-lo - tick-len), stroke: axis-stroke)
      }
      _draw-x-label(
        cx,
        resolve-prose(
          resolve-label(
            _x-disp.labels,
            b,
            idx,
            _axis-label(x-trained, b),
            typst-mark: _x-disp.typst-mark,
          ),
          eval-strings: _ax-text.typst,
        ),
        idx,
      )
    }
  } else if x-trained != none and x-trained.type == "discrete" {
    for (idx, level) in x-trained.domain.enumerate() {
      let cx = map-position(x-trained, level, px-range)
      if axis-stroke != none and tick-len > 0 {
        line((cx, py-lo), (cx, py-lo - tick-len), stroke: axis-stroke)
      }
      _draw-x-label(
        cx,
        resolve-prose(
          resolve-label(
            _x-disp.labels,
            level,
            idx,
            level,
            typst-mark: _x-disp.typst-mark,
          ),
          eval-strings: _ax-text.typst,
        ),
        idx,
      )
    }
  }

  if y-trained != none and y-trained.type == "continuous" {
    let breaks = if axis-breaks != none and axis-breaks.y != none {
      axis-breaks.y
    } else { _axis-breaks(y-trained) }
    for (idx, b) in breaks.enumerate() {
      let cy = map-axis(y-trained, b, py-range)
      if grid-stroke != none {
        line((px-lo, cy), (px-hi, cy), stroke: grid-stroke)
      }
      if axis-stroke != none and tick-len > 0 {
        line((px-lo - tick-len, cy), (px-lo, cy), stroke: axis-stroke)
      }
      _draw-y-label(
        cy,
        resolve-prose(
          resolve-label(
            _y-disp.labels,
            b,
            idx,
            _axis-label(y-trained, b),
            typst-mark: _y-disp.typst-mark,
          ),
          eval-strings: _ax-text.typst,
        ),
        idx,
      )
    }
  } else if y-trained != none and y-trained.type == "discrete" {
    for (idx, level) in y-trained.domain.enumerate() {
      let cy = map-position(y-trained, level, py-range)
      if axis-stroke != none and tick-len > 0 {
        line((px-lo - tick-len, cy), (px-lo, cy), stroke: axis-stroke)
      }
      _draw-y-label(
        cy,
        resolve-prose(
          resolve-label(
            _y-disp.labels,
            level,
            idx,
            level,
            typst-mark: _y-disp.typst-mark,
          ),
          eval-strings: _ax-text.typst,
        ),
        idx,
      )
    }
  }

  // Minor log ticks: opt-in via guide-axis-logticks() on a log10-trans axis.
  // Emits half-length, unlabelled ticks at sub-decade positions (2, 3, ..., 9
  // within each decade) covered by the visible domain.
  let _draw-log-minors(trained, guide, axis, range) = {
    if not guide.logticks { return }
    if trained == none { return }
    if trained.type != "continuous" { return }
    if trained.at("transform", default: "identity") != "log10" { return }
    if axis-stroke == none or tick-len <= 0 { return }
    let view-transform = trained.at("view-transform", default: none)
    let (lo, hi) = if view-transform != none {
      (
        transform-inv("log10", view-transform.at(0)),
        transform-inv("log10", view-transform.at(1)),
      )
    } else { trained.domain }
    if lo <= 0 or hi <= 0 { return }
    let minor-len = tick-len * 0.5
    let k-lo = int(calc.floor(calc.log(lo, base: 10)))
    let k-hi = int(calc.ceil(calc.log(hi, base: 10)))
    let k = k-lo
    while k <= k-hi {
      let scale = calc.pow(10.0, k)
      for c in (2, 3, 4, 5, 6, 7, 8, 9) {
        let v = c * scale
        if v >= lo and v <= hi {
          if axis == "x" {
            let cx = map-axis(trained, v, range)
            line((cx, py-lo), (cx, py-lo - minor-len), stroke: axis-stroke)
          } else {
            let cy = map-axis(trained, v, range)
            line((px-lo - minor-len, cy), (px-lo, cy), stroke: axis-stroke)
          }
        }
      }
      k = k + 1
    }
  }
  _draw-log-minors(x-trained, x-guide, "x", px-range)
  _draw-log-minors(y-trained, y-guide, "y", py-range)

  // Secondary x-axis: draw on top edge if the trained x scale carries a
  // secondary spec. Breaks reuse the primary axis grid; their labels go
  // through the user's transformation function.
  let _x-sec = if (
    x-trained != none
      and x-trained.type == "continuous"
      and x-trained.at("spec", default: none) != none
  ) {
    x-trained.spec.at("secondary", default: none)
  } else { none }
  if _x-sec != none and show-x-sec {
    let breaks = if axis-breaks != none and axis-breaks.x-sec != none {
      axis-breaks.x-sec
    } else { _axis-breaks(x-trained) }
    for b in breaks {
      let cx = map-axis(x-trained, b, px-range)
      if axis-stroke != none and tick-len > 0 {
        line((cx, py-hi), (cx, py-hi + tick-len), stroke: axis-stroke)
      }
      if theme.tick-labels {
        let mapped = secondary-mod.apply-transform(_x-sec, b)
        content(
          (cx, py-hi + tick-len + 0.05),
          text(
            size: _ax-text.size,
            fill: _ax-text.fill,
            weight: _ax-text.weight,
          )[#resolve-prose(
            _format-break(mapped),
            eval-strings: _ax-text.typst,
          )],
          anchor: "south",
        )
      }
    }
    if axis-stroke != none {
      line((px-lo, py-hi), (px-hi, py-hi), stroke: axis-stroke)
    }
    if _x-sec.name != none and _ax-title.size > 0pt {
      content(
        ((px-lo + px-hi) / 2, py-hi + tick-len + 0.55),
        text(
          size: _ax-title.size,
          fill: _ax-title.fill,
          weight: _ax-title.weight,
        )[#resolve-prose(_x-sec.name, eval-strings: _ax-title.typst)],
        anchor: "south",
      )
    }
  }

  // Secondary y-axis: draw on right edge if the trained y scale carries a
  // secondary spec.
  let _y-sec = if (
    y-trained != none
      and y-trained.type == "continuous"
      and y-trained.at("spec", default: none) != none
  ) {
    y-trained.spec.at("secondary", default: none)
  } else { none }
  if _y-sec != none and show-y-sec {
    let breaks = if axis-breaks != none and axis-breaks.y-sec != none {
      axis-breaks.y-sec
    } else { _axis-breaks(y-trained) }
    for b in breaks {
      let cy = map-axis(y-trained, b, py-range)
      if axis-stroke != none and tick-len > 0 {
        line((px-hi, cy), (px-hi + tick-len, cy), stroke: axis-stroke)
      }
      if theme.tick-labels {
        let mapped = secondary-mod.apply-transform(_y-sec, b)
        content(
          (px-hi + tick-len + 0.05, cy),
          text(
            size: _ax-text.size,
            fill: _ax-text.fill,
            weight: _ax-text.weight,
          )[#resolve-prose(
            _format-break(mapped),
            eval-strings: _ax-text.typst,
          )],
          anchor: "west",
        )
      }
    }
    if axis-stroke != none {
      line((px-hi, py-lo), (px-hi, py-hi), stroke: axis-stroke)
    }
    if _y-sec.name != none and _ax-title.size > 0pt {
      content(
        (px-hi + tick-len + 0.7, (py-lo + py-hi) / 2),
        text(
          size: _ax-title.size,
          fill: _ax-title.fill,
          weight: _ax-title.weight,
        )[#resolve-prose(_y-sec.name, eval-strings: _ax-title.typst)],
        angle: 90deg,
      )
    }
  }

  if axis-stroke != none {
    line((px-lo, py-lo), (px-hi, py-lo), stroke: axis-stroke)
    line((px-lo, py-lo), (px-lo, py-hi), stroke: axis-stroke)
  }

  for layer in prepared {
    let draw = _geom-draw.at(layer.geom, default: none)
    if draw != none { draw(layer, ctx) }
  }

  // When flipped, the bottom axis shows the user's original y mapping and
  // the left axis shows the user's original x mapping; trained.x and
  // trained.y already carry the swapped scale specs (and labs labels), so
  // only the mapping-name fallback needs an explicit swap here.
  let _mapping-x-name = if spec.mapping == none { none } else if flipped {
    mapping-ref-col(spec.mapping.at("y", default: none))
  } else { mapping-ref-col(spec.mapping.at("x", default: none)) }
  let _mapping-y-name = if spec.mapping == none { none } else if flipped {
    mapping-ref-col(spec.mapping.at("x", default: none))
  } else { mapping-ref-col(spec.mapping.at("y", default: none)) }
  let x-title = {
    let from-scale = if x-trained != none and x-trained.spec != none {
      x-trained.spec.name
    } else { none }
    if from-scale != none { from-scale } else { _mapping-x-name }
  }
  let y-title = {
    let from-scale = if y-trained != none and y-trained.spec != none {
      y-trained.spec.name
    } else { none }
    if from-scale != none { from-scale } else { _mapping-y-name }
  }
  if show-x-title and x-title != none and _ax-title.size > 0pt {
    content(
      ((px-lo + px-hi) / 2, oy - 0.8),
      text(
        size: _ax-title.size,
        fill: _ax-title.fill,
        weight: _ax-title.weight,
      )[#resolve-prose(x-title, eval-strings: _ax-title.typst)],
      anchor: "south",
    )
  }
  if show-y-title and y-title != none and _ax-title.size > 0pt {
    content(
      (px-lo - 1.1, (py-lo + py-hi) / 2),
      text(
        size: _ax-title.size,
        fill: _ax-title.fill,
        weight: _ax-title.weight,
      )[#resolve-prose(y-title, eval-strings: _ax-title.typst)],
      angle: 90deg,
    )
  }

  if guides.len() > 0 and legend-origin != none {
    legend-mod.draw(guides, ctx, legend-origin, legend-height, theme)
  }
}

// Inject labs `x`/`y`/... names into trained scale specs so axis and legend
// titles follow labs() overrides.
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

// coord-transform overrides each axis's `trans` so the trained view is
// warped at mapping time. Runs before `_apply-expand` so expansion uses the
// final transformation. Identity values are no-ops.
#let _apply-coord-transform(trained, coord) = {
  if coord == none or coord.at("coord", default: none) != "transform" {
    return trained
  }
  for axis in ("x", "y") {
    let t = coord.at(axis, default: "identity")
    if t == "identity" { continue }
    let entry = trained.at(axis, default: none)
    if entry == none or entry.type != "continuous" { continue }
    let new-entry = entry
    new-entry.insert("transform", t)
    trained.insert(axis, new-entry)
  }
  trained
}

// coord-cartesian xlim/ylim overrides take precedence over scale training,
// so re-apply them after any per-panel retraining.
#let _apply-coord(trained, coord) = {
  if coord == none { return trained }
  if coord.coord != "cartesian" { return trained }
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

// Detect whether the spec asks for axis-flipping at render time.
#let _is-flipped(coord) = (
  coord != none and coord.at("coord", default: none) == "flip"
)

// Swap the trained x and y scales so the renderer's bottom axis shows the
// user's original y scale and the left axis shows the user's original x
// scale. Called after `_apply-coord` so any cartesian xlim/ylim overrides
// apply to the pre-flip axes as the user wrote them.
#let _apply-flip(trained, coord) = {
  if not _is-flipped(coord) { return trained }
  let x = trained.at("x", default: none)
  let y = trained.at("y", default: none)
  trained.insert("x", y)
  trained.insert("y", x)
  trained
}

// Swap a layer's mapping x and y so direction-agnostic geoms read the user's
// original y column where they expect x and vice versa. Direction-sensitive
// geoms (col, hline, vline, abline) read `ctx.flipped` instead and rotate
// their drawing without a mapping swap.
#let _flip-layer-mapping(layer) = {
  let mapping = layer.at("mapping", default: none)
  if mapping == none { return layer }
  let x = mapping.at("x", default: none)
  let y = mapping.at("y", default: none)
  let new-mapping = mapping
  new-mapping.insert("x", y)
  new-mapping.insert("y", x)
  let new = layer
  new.mapping = new-mapping
  new
}

// Shrink the inner panel along the longer axis so that one x data unit
// projects to `ratio` y data units. Returns the adjusted (width, height).
// Falls back to the input box if either trained scale is missing or has a
// zero-length domain.
#let _fixed-inner-size(coord, trained, box-w, box-h) = {
  if coord == none or coord.coord != "fixed" { return (box-w, box-h) }
  let x-trained = trained.at("x", default: none)
  let y-trained = trained.at("y", default: none)
  if x-trained == none or y-trained == none { return (box-w, box-h) }
  if x-trained.type != "continuous" or y-trained.type != "continuous" {
    return (box-w, box-h)
  }
  let (x-lo, x-hi) = x-trained.domain
  let (y-lo, y-hi) = y-trained.domain
  let dx = x-hi - x-lo
  let dy = y-hi - y-lo
  if dx <= 0 or dy <= 0 { return (box-w, box-h) }
  let ratio = coord.at("ratio", default: 1)
  // Pixels-per-x-unit must equal ratio * pixels-per-y-unit.
  let want = (dy * ratio) / dx
  let have = box-h / box-w
  if want >= have {
    (box-h / want, box-h)
  } else {
    (box-w, box-w * want)
  }
}

// Apply scale expansion on top of the already-padded domain produced by
// `_post-train`. Multiplicative breathing room (ratio) is folded into
// `view-transform` (continuous) / `view-index` (discrete); absolute additive
// padding (length) is recorded as `view-pad-cm` and applied later by
// `_draw-axis-and-layers` as a canvas-cm inset on the data area.
// `coord-cartesian(expand: false)` zeroes everything.
#let _apply-expand(trained, coord) = {
  let coord-no-expand = (
    coord != none
      and coord.at("coord", default: none) == "cartesian"
      and coord.at("expand", default: true) == false
  )
  for axis in ("x", "y") {
    let entry = trained.at(axis, default: none)
    if entry == none { continue }
    let spec = entry.at("spec", default: none)
    let raw = if spec == none { auto } else { spec.at("expand", default: auto) }
    let expand = if coord-no-expand { false } else { raw }
    let (mult-lo, add-cm-lo, mult-hi, add-cm-hi) = normalise-expansion(
      expand,
      entry.type,
    )
    // Bars / areas anchor at y=0: when the user did not pin `expand`
    // explicitly, drop the multiplicative expansion on the anchored side so
    // the baseline sits flush against the axis line. Length-add is always
    // honoured.
    let anchor = entry.at("anchor-zero", default: none)
    if anchor != none and raw == auto {
      if anchor == "lo" or anchor == "both" { mult-lo = 0 }
      if anchor == "hi" or anchor == "both" { mult-hi = 0 }
    }
    let new-entry = entry
    if entry.type == "continuous" {
      let (lo, hi) = entry.domain
      let transform = entry.at("transform", default: "identity")
      let t-lo = transform-fwd(transform, lo)
      let t-hi = transform-fwd(transform, hi)
      let span = t-hi - t-lo
      new-entry.insert(
        "view-transform",
        (t-lo - mult-lo * span, t-hi + mult-hi * span),
      )
    } else if entry.type == "discrete" {
      let n = entry.domain.len()
      let span = if n > 1 { n - 1 } else { 0 }
      // Discrete `auto` gets a default 0.6-slot data-unit pad on each side;
      // any explicit `expand:` value supersedes it.
      let auto-data-pad = if raw == auto { DISCRETE-AUTO-DATA-PAD } else { 0 }
      let geom-min = entry.at("geom-min-pad", default: 0)
      let pad-lo = calc.max(mult-lo * span + auto-data-pad, geom-min)
      let pad-hi = calc.max(mult-hi * span + auto-data-pad, geom-min)
      new-entry.insert("view-index", (0 - pad-lo, (n - 1) + pad-hi))
    }
    new-entry.insert("view-pad-cm", (add-cm-lo, add-cm-hi))
    trained.insert(axis, new-entry)
  }
  trained
}

// Rewrite a continuous trained-scale's domain via `fn((lo, hi)) -> (lo, hi)`.
// No-ops when the axis is missing or non-continuous.
#let _rewrite-continuous-domain(trained, axis, fn) = {
  let t = trained.at(axis, default: none)
  if t == none or t.type != "continuous" { return trained }
  let new = t
  new.insert("domain", fn(t.domain))
  trained.insert(axis, new)
  trained
}

// Apply post-training domain fix-ups (bar-zero floor, bin width padding,
// ribbon ymin/ymax padding). Called once globally and once per panel under
// free scales so each panel's domain reflects its own subset.
#let _post-train(trained, layers) = {
  let scan = _post-train-scan(layers)

  // Bars and areas anchor against y=0. The touching side is tagged so
  // `_apply-expand` collapses its auto-expansion to zero, matching ggplot2's
  // `expansion(mult = c(0, 0.05))`. `position: "fill"` anchors both sides;
  // mixed-sign data keeps symmetric expansion.
  if scan.needs-y-zero {
    let yt = trained.at("y", default: none)
    if yt != none and yt.type == "continuous" {
      let (lo, hi) = yt.domain
      let new-y = yt
      new-y.insert("domain", (calc.min(lo, 0.0), calc.max(hi, 0.0)))
      let anchor = if scan.any-fill {
        "both"
      } else if lo >= 0 {
        "lo"
      } else if hi <= 0 {
        "hi"
      } else { none }
      if anchor != none { new-y.insert("anchor-zero", anchor) }
      trained.insert("y", new-y)
    }
  }

  if scan.bin-half-max > 0 {
    let pad = scan.bin-half-max
    trained = _rewrite-continuous-domain(trained, "x", ((lo, hi)) => (
      lo - pad,
      hi + pad,
    ))
  }

  // `geom-col` mirrors its own min-gap heuristic: pad the continuous category
  // axis by half a bar width so outer bars stay inside the panel. Coord-flip
  // is applied later, so padding pre-flip x covers both orientations.
  if scan.cols.len() > 0 {
    let max-half = _col-half-width-x(scan.cols)
    if max-half > 0 {
      trained = _rewrite-continuous-domain(trained, "x", ((lo, hi)) => (
        lo - max-half,
        hi + max-half,
      ))
    }
  }

  if scan.ribbon-y-min != none {
    let lo-extra = scan.ribbon-y-min
    let hi-extra = scan.ribbon-y-max
    trained = _rewrite-continuous-domain(trained, "y", ((lo, hi)) => (
      calc.min(lo, lo-extra),
      calc.max(hi, hi-extra),
    ))
  }

  let _seed-or-extend(t, axis, lo-extra, hi-extra) = {
    if t.at(axis, default: none) == none {
      t.insert(axis, (
        type: "continuous",
        domain: (lo-extra, hi-extra),
        spec: none,
        transform: "identity",
        typst-mark: false,
      ))
      t
    } else {
      _rewrite-continuous-domain(t, axis, ((lo, hi)) => (
        calc.min(lo, lo-extra),
        calc.max(hi, hi-extra),
      ))
    }
  }
  if scan.ellipse-x-min != none {
    trained = _seed-or-extend(
      trained,
      "x",
      scan.ellipse-x-min,
      scan.ellipse-x-max,
    )
  }
  if scan.ellipse-y-min != none {
    trained = _seed-or-extend(
      trained,
      "y",
      scan.ellipse-y-min,
      scan.ellipse-y-max,
    )
  }

  // Discrete category axes get `geom-min-pad` so `_apply-expand` keeps outer
  // bars inside the panel; the continuous case is already covered above.
  if scan.cols.len() > 0 {
    let bar-half = 0
    for layer in scan.cols {
      let half = layer.bar-frac / 2
      if half > bar-half { bar-half = half }
    }
    if bar-half > 0 {
      let xt = trained.at("x", default: none)
      if xt != none and xt.type == "discrete" {
        let new-x = xt
        new-x.insert("geom-min-pad", bar-half)
        trained.insert("x", new-x)
      }
    }
  }

  trained
}

#let _render-style(theme) = (
  strip-fill: _rect-fill(theme, "strip-background", fallback: theme.paper),
  strip-text: _text-style(theme, "strip-text"),
  ax-title: _text-style(theme, "axis-title"),
)

// Resolve a per-side margin value to canvas units (cm). Typst lengths are
// converted via `/1cm`; `auto` falls through to the dynamic default.
#let _resolve-margin-side(value, fallback) = {
  if value == auto { return fallback }
  if type(value) == length { return value / 1cm }
  fallback
}

// Build the four-sided margin used by the canvas layout. `theme-margin` may
// be `none` or a non-margin value (use the dynamic default verbatim) or a
// `margin(...)` dict whose per-side values override the dynamic default.
#let _resolve-margin(theme-margin, auto-margin) = {
  if (
    theme-margin == none
      or type(theme-margin) != dictionary
      or theme-margin.at("kind", default: none) != "margin"
  ) {
    return auto-margin
  }
  (
    top: _resolve-margin-side(theme-margin.top, auto-margin.top),
    right: _resolve-margin-side(theme-margin.right, auto-margin.right),
    bottom: _resolve-margin-side(theme-margin.bottom, auto-margin.bottom),
    left: _resolve-margin-side(theme-margin.left, auto-margin.left),
  )
}

// ASCII Unit Separator joins the two grid-facet level strings into a single
// dict key. Assumed absent from any user-facing facet level.
#let _facet-key-sep = "\u{1F}"

// Build a (row-key-fn, panel-key-fn) pair for a grid facet spec, specialised
// on which of `rows` / `cols` is set. The row-key-fn is invoked once per data
// row inside `group-by` and must avoid per-row allocation.
#let _grid-facet-keyers(spec) = {
  let r = spec.facet.rows
  let c = spec.facet.cols
  if r != none and c != none {
    return (
      row: row => (
        str(row.at(r, default: ""))
          + _facet-key-sep
          + str(row.at(c, default: ""))
      ),
      panel: (rl, cl) => rl + _facet-key-sep + cl,
    )
  }
  if r != none {
    return (
      row: row => str(row.at(r, default: "")),
      panel: (rl, _) => rl,
    )
  }
  (
    row: row => str(row.at(c, default: "")),
    panel: (_, cl) => cl,
  )
}

#let _render-prepare(spec) = {
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

  // Partition each layer's data once by the facet key, then look up each
  // panel's subset in O(1).
  let panels = if facet-wrap-mode {
    let var = spec.facet.var
    let layer-groups = spec.layers.map(l => group-by(
      _resolve-data(l, spec.data),
      row => str(row.at(var, default: "")),
    ))
    wrap-levels.map(level => (
      level: level,
      layers: spec
        .layers
        .enumerate()
        .map(((i, l)) => {
          let with-subset = l
          with-subset.data = layer-groups.at(i).at(level, default: ())
          with-subset.insert("data-trusted", true)
          _prepare-layer(with-subset, spec.mapping, spec.data)
        }),
    ))
  } else if facet-grid-mode {
    let keyers = _grid-facet-keyers(spec)
    let layer-groups = spec.layers.map(l => group-by(
      _resolve-data(l, spec.data),
      keyers.row,
    ))
    let out = ()
    for row-lv in grid-row-levels {
      for col-lv in grid-col-levels {
        let key = (keyers.panel)(row-lv, col-lv)
        out.push((
          row-level: row-lv,
          col-level: col-lv,
          layers: spec
            .layers
            .enumerate()
            .map(((i, l)) => {
              let with-subset = l
              with-subset.data = layer-groups.at(i).at(key, default: ())
              with-subset.insert("data-trusted", true)
              _prepare-layer(with-subset, spec.mapping, spec.data)
            }),
        ))
      }
    }
    out
  } else { () }

  let prepared = if facet-wrap-mode or facet-grid-mode {
    let union = ()
    for panel in panels { union += panel.layers }
    union
  } else {
    spec.layers.map(l => _prepare-layer(l, spec.mapping, spec.data))
  }

  (
    facet-wrap-mode: facet-wrap-mode,
    facet-grid-mode: facet-grid-mode,
    wrap-levels: wrap-levels,
    grid-row-levels: grid-row-levels,
    grid-col-levels: grid-col-levels,
    panels: panels,
    prepared: prepared,
  )
}

#let _panel-row-count(panel-layers) = {
  let n = 0
  for layer in panel-layers { n += layer.data.len() }
  n
}

#let _train-panels(spec, panels, trained, coord, labs, free-x, free-y) = {
  if not (free-x or free-y) { return () }
  // Only positional aesthetics are retrained per panel; non-positionals stay
  // shared so legends do not fragment. Labs labels must be re-applied because
  // pt.x / pt.y overwrite the globally-labelled merged.x / merged.y below.
  panels.map(p => {
    let pt = train(
      scales: spec.scales,
      layers: p.layers,
      mapping: spec.mapping,
      data: spec.data,
      aesthetics: positional-aesthetics,
    )
    pt = _apply-labs(pt, labs)
    pt = _post-train(pt, p.layers)
    pt = _apply-coord-transform(pt, coord)
    pt = _apply-expand(pt, coord)
    pt = _apply-coord(pt, coord)
    pt = _apply-flip(pt, coord)
    let merged = trained
    if free-x and pt.at("x", default: none) != none {
      merged.insert("x", pt.x)
    }
    if free-y and pt.at("y", default: none) != none {
      merged.insert("y", pt.y)
    }
    merged
  })
}

#let _render-canvas-wrap(ctx) = {
  let spec = ctx.spec
  let theme = ctx.theme
  let coord = ctx.coord
  let trained = ctx.trained
  let panels = ctx.panels
  let panel-trained-list = ctx.panel-trained-list
  let wrap-levels = ctx.wrap-levels
  let guides = ctx.guides
  let legend-gap = ctx.legend-gap
  let margin = ctx.margin
  let width-units = ctx.width-units
  let height-units = ctx.height-units
  let free-x = ctx.free-x
  let free-y = ctx.free-y
  let style = ctx.style
  let _ax-title = style.ax-title

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

  // Compute shared breaks once per axis. A free axis sets its entry to
  // `none` so `_draw-axis-and-layers` falls back to per-panel computation
  // (the per-panel scale is what differs); the fixed axis still benefits
  // from the cached breaks even when the other axis is free.
  let shared-breaks = {
    let s = _shared-axis-breaks(trained)
    if free-x {
      s.insert("x", none)
      s.insert("x-sec", none)
    }
    if free-y {
      s.insert("y", none)
      s.insert("y-sec", none)
    }
    s
  }

  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    let _wrap-labeller = spec.facet.at("labeller", default: none)
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
        fill: style.strip-fill,
        stroke: none,
      )
      let panel-layers = panels.at(i).layers
      let panel-count = _panel-row-count(panel-layers)
      let strip-text = labellers.format(
        _wrap-labeller,
        spec.facet.var,
        level,
        count: panel-count,
      )
      content(
        (x0 + panel-w / 2, y0 + panel-h + strip-h / 2),
        text(
          size: style.strip-text.size,
          fill: style.strip-text.fill,
          weight: style.strip-text.weight,
        )[#resolve-prose(strip-text, eval-strings: style.strip-text.typst)],
      )
      let panel-trained = if panel-trained-list.len() == 0 {
        trained
      } else { panel-trained-list.at(i) }
      let (inner-w, inner-h) = _fixed-inner-size(
        coord,
        panel-trained,
        panel-w,
        panel-h,
      )
      let inner-y0 = y0 + (panel-h - inner-h)
      _draw-axis-and-layers(
        panel-layers,
        panel-trained,
        theme,
        spec,
        (x0, inner-y0),
        (inner-w, inner-h),
        show-x-labels: free-x or row == nrow - 1,
        show-y-labels: free-y or col == 0,
        show-x-title: false,
        show-y-title: false,
        show-x-sec: free-x or row == 0,
        show-y-sec: free-y or col == ncol - 1,
        flipped: _is-flipped(coord),
        axis-breaks: shared-breaks,
      )
    }

    let x-trained = trained.at("x", default: none)
    let y-trained = trained.at("y", default: none)
    let x-title = {
      let from-scale = if x-trained != none and x-trained.spec != none {
        x-trained.spec.name
      } else { none }
      if from-scale != none { from-scale } else if spec.mapping != none {
        mapping-ref-col(spec.mapping.at("x", default: none))
      } else { none }
    }
    let y-title = {
      let from-scale = if y-trained != none and y-trained.spec != none {
        y-trained.spec.name
      } else { none }
      if from-scale != none { from-scale } else if spec.mapping != none {
        mapping-ref-col(spec.mapping.at("y", default: none))
      } else { none }
    }
    if x-title != none and _ax-title.size > 0pt {
      content(
        (margin.left + grid-w / 2, 0.1),
        text(
          size: _ax-title.size,
          fill: style.ax-title.fill,
          weight: style.ax-title.weight,
        )[#resolve-prose(x-title, eval-strings: _ax-title.typst)],
        anchor: "south",
      )
    }
    if y-title != none and _ax-title.size > 0pt {
      content(
        (0.2, margin.bottom + grid-h / 2),
        text(
          size: _ax-title.size,
          fill: style.ax-title.fill,
          weight: style.ax-title.weight,
        )[#resolve-prose(y-title, eval-strings: _ax-title.typst)],
        angle: 90deg,
      )
    }

    if guides.len() > 0 {
      let lctx = (
        trained: trained,
        palette: default-discrete,
        theme: theme,
      )
      legend-mod.draw(
        guides,
        lctx,
        (margin.left + grid-w + legend-gap, margin.bottom),
        grid-h,
        theme,
      )
    }
  })
}

#let _render-canvas-grid(ctx) = {
  let spec = ctx.spec
  let theme = ctx.theme
  let coord = ctx.coord
  let trained = ctx.trained
  let panels = ctx.panels
  let grid-row-levels = ctx.grid-row-levels
  let grid-col-levels = ctx.grid-col-levels
  let guides = ctx.guides
  let legend-gap = ctx.legend-gap
  let margin = ctx.margin
  let width-units = ctx.width-units
  let height-units = ctx.height-units
  let style = ctx.style
  let _ax-title = style.ax-title

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

  let shared-breaks = _shared-axis-breaks(trained)

  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    for (r, row-lv) in row-levels.enumerate() {
      for (c, col-lv) in col-levels.enumerate() {
        let x0 = margin.left + c * (panel-w + gutter-x)
        let y0 = margin.bottom + (n-rows - 1 - r) * (panel-h + gutter-y)
        let panel-layers = panels.at(r * n-cols + c).layers
        let (inner-w, inner-h) = _fixed-inner-size(
          coord,
          trained,
          panel-w,
          panel-h,
        )
        let inner-y0 = y0 + (panel-h - inner-h)
        _draw-axis-and-layers(
          panel-layers,
          trained,
          theme,
          spec,
          (x0, inner-y0),
          (inner-w, inner-h),
          show-x-labels: r == n-rows - 1,
          show-y-labels: c == 0,
          show-x-title: false,
          show-y-title: false,
          show-x-sec: r == 0,
          show-y-sec: c == n-cols - 1,
          flipped: _is-flipped(coord),
          axis-breaks: shared-breaks,
        )
      }
    }

    let _grid-labeller = spec.facet.at("labeller", default: none)
    let _col-count(c) = {
      let n = 0
      for r in range(n-rows) {
        n += _panel-row-count(panels.at(r * n-cols + c).layers)
      }
      n
    }
    let _row-count(r) = {
      let n = 0
      for c in range(n-cols) {
        n += _panel-row-count(panels.at(r * n-cols + c).layers)
      }
      n
    }

    if col-var != none {
      let strip-y = margin.bottom + grid-h
      for (c, col-lv) in col-levels.enumerate() {
        let x0 = margin.left + c * (panel-w + gutter-x)
        rect(
          (x0, strip-y),
          (x0 + panel-w, strip-y + top-strip),
          fill: style.strip-fill,
          stroke: none,
        )
        let strip-text = labellers.format(
          _grid-labeller,
          col-var,
          col-lv,
          count: _col-count(c),
        )
        content(
          (x0 + panel-w / 2, strip-y + top-strip / 2),
          text(
            size: style.strip-text.size,
            fill: style.strip-text.fill,
            weight: style.strip-text.weight,
          )[#resolve-prose(strip-text, eval-strings: style.strip-text.typst)],
        )
      }
    }

    if row-var != none {
      let strip-x = margin.left + grid-w
      for (r, row-lv) in row-levels.enumerate() {
        let y0 = margin.bottom + (n-rows - 1 - r) * (panel-h + gutter-y)
        rect(
          (strip-x, y0),
          (strip-x + right-strip, y0 + panel-h),
          fill: style.strip-fill,
          stroke: none,
        )
        let strip-text = labellers.format(
          _grid-labeller,
          row-var,
          row-lv,
          count: _row-count(r),
        )
        content(
          (strip-x + right-strip / 2, y0 + panel-h / 2),
          text(
            size: style.strip-text.size,
            fill: style.strip-text.fill,
            weight: style.strip-text.weight,
          )[#resolve-prose(strip-text, eval-strings: style.strip-text.typst)],
          angle: -90deg,
        )
      }
    }

    let x-trained = trained.at("x", default: none)
    let y-trained = trained.at("y", default: none)
    let x-title = {
      let from-scale = if x-trained != none and x-trained.spec != none {
        x-trained.spec.name
      } else { none }
      if from-scale != none { from-scale } else if spec.mapping != none {
        mapping-ref-col(spec.mapping.at("x", default: none))
      } else { none }
    }
    let y-title = {
      let from-scale = if y-trained != none and y-trained.spec != none {
        y-trained.spec.name
      } else { none }
      if from-scale != none { from-scale } else if spec.mapping != none {
        mapping-ref-col(spec.mapping.at("y", default: none))
      } else { none }
    }
    if x-title != none and _ax-title.size > 0pt {
      content(
        (margin.left + grid-w / 2, 0.1),
        text(
          size: _ax-title.size,
          fill: style.ax-title.fill,
          weight: style.ax-title.weight,
        )[#resolve-prose(x-title, eval-strings: _ax-title.typst)],
        anchor: "south",
      )
    }
    if y-title != none and _ax-title.size > 0pt {
      content(
        (0.2, margin.bottom + grid-h / 2),
        text(
          size: _ax-title.size,
          fill: style.ax-title.fill,
          weight: style.ax-title.weight,
        )[#resolve-prose(y-title, eval-strings: _ax-title.typst)],
        angle: 90deg,
      )
    }

    if guides.len() > 0 {
      let lctx = (
        trained: trained,
        palette: default-discrete,
        theme: theme,
      )
      legend-mod.draw(
        guides,
        lctx,
        (margin.left + grid-w + right-strip + legend-gap, margin.bottom),
        grid-h,
        theme,
      )
    }
  })
}

#let _render-canvas-single(
  spec,
  theme,
  trained,
  prepared,
  coord,
  guides,
  legend-gap,
  margin,
  width-units,
  height-units,
) = {
  let px-lo = margin.left
  let px-hi = width-units - margin.right
  let py-lo = margin.bottom
  let py-hi = height-units - margin.top

  let box-w = px-hi - px-lo
  let box-h = py-hi - py-lo
  let (inner-w, inner-h) = _fixed-inner-size(coord, trained, box-w, box-h)

  cetz.canvas(length: 1cm, {
    _draw-axis-and-layers(
      prepared,
      trained,
      theme,
      spec,
      (px-lo, py-lo),
      (inner-w, inner-h),
      guides: guides,
      legend-origin: (px-lo + inner-w + legend-gap, py-lo),
      legend-height: inner-h,
      flipped: _is-flipped(coord),
    )
  })
}

#let _render-decorate(canvas, labs, theme) = {
  if labs == none { return canvas }
  let title = _text-style(theme, "plot-title")
  let subtitle = _text-style(theme, "plot-subtitle")
  let caption = _text-style(theme, "plot-caption")
  let title-block = if labs.title != none {
    text(
      size: title.size,
      weight: title.weight,
      fill: title.fill,
    )[#resolve-prose(labs.title, eval-strings: title.typst)]
  } else { none }
  let subtitle-block = if labs.subtitle != none {
    text(
      size: subtitle.size,
      fill: subtitle.fill,
    )[#resolve-prose(labs.subtitle, eval-strings: subtitle.typst)]
  } else { none }
  let caption-block = if labs.caption != none {
    text(
      size: caption.size,
      fill: caption.fill,
      style: "italic",
    )[#resolve-prose(labs.caption, eval-strings: caption.typst)]
  } else { none }

  let parts = ()
  if title-block != none { parts.push(title-block) }
  if subtitle-block != none { parts.push(subtitle-block) }
  parts.push(canvas)
  if caption-block != none { parts.push(caption-block) }
  if parts.len() == 1 { return canvas }
  block(stack(dir: ttb, spacing: 0.3em, ..parts))
}

#let render-plot(spec) = {
  let theme = merge-theme(spec.theme)
  let labs = spec.at("labs", default: none)

  let style = _render-style(theme)

  // Faceted plots prepare layers per panel so stats (smooth, bin, count) fit
  // each panel's own row subset, following grammar-of-graphics semantics.
  let prep = _render-prepare(spec)
  let facet-wrap-mode = prep.facet-wrap-mode
  let facet-grid-mode = prep.facet-grid-mode
  let wrap-levels = prep.wrap-levels
  let grid-row-levels = prep.grid-row-levels
  let grid-col-levels = prep.grid-col-levels
  let panels = prep.panels
  let prepared = prep.prepared

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
  // clip limits so axis ticks and marks follow them. Data outside the limits
  // is preserved for stats and training but may render outside the panel.
  let coord = spec.at("coord", default: none)
  trained = _apply-coord-transform(trained, coord)
  trained = _apply-expand(trained, coord)
  trained = _apply-coord(trained, coord)
  // coord-flip swaps trained x and y so axis labels swap automatically;
  // direction-sensitive geoms branch on `ctx.flipped` inside their draw.
  trained = _apply-flip(trained, coord)

  // For facet-wrap with non-fixed scales, train each panel's positional axes
  // on its own subset so x and/or y differ across panels. Non-positional
  // scales (colour, fill, size, shape, linetype) stay shared so legends do
  // not fragment.
  let wrap-scales = if facet-wrap-mode { spec.facet.scales } else { "fixed" }
  let free-x = (
    facet-wrap-mode
      and (
        wrap-scales == "free" or wrap-scales == "free_x"
      )
  )
  let free-y = (
    facet-wrap-mode
      and (
        wrap-scales == "free" or wrap-scales == "free_y"
      )
  )
  let panel-trained-list = _train-panels(
    spec,
    panels,
    trained,
    coord,
    labs,
    free-x,
    free-y,
  )

  let width-units = spec.width / 1cm
  let height-units = spec.height / 1cm

  let guides = legend-mod.guides-for(spec, trained)
  let legend-width = legend-mod.estimate-width(guides)
  let legend-gap = if legend-width > 0 { 0.25 } else { 0.0 }

  let auto-margin = (
    left: 1.3,
    bottom: 0.9,
    top: 0.3,
    right: 0.3 + legend-gap + legend-width,
  )
  let margin = _resolve-margin(
    theme.at("plot-margin", default: none),
    auto-margin,
  )

  let canvas = if facet-wrap-mode {
    _render-canvas-wrap((
      spec: spec,
      theme: theme,
      coord: coord,
      trained: trained,
      panels: panels,
      panel-trained-list: panel-trained-list,
      wrap-levels: wrap-levels,
      guides: guides,
      legend-gap: legend-gap,
      margin: margin,
      width-units: width-units,
      height-units: height-units,
      free-x: free-x,
      free-y: free-y,
      style: style,
    ))
  } else if facet-grid-mode {
    _render-canvas-grid((
      spec: spec,
      theme: theme,
      coord: coord,
      trained: trained,
      panels: panels,
      grid-row-levels: grid-row-levels,
      grid-col-levels: grid-col-levels,
      guides: guides,
      legend-gap: legend-gap,
      margin: margin,
      width-units: width-units,
      height-units: height-units,
      style: style,
    ))
  } else {
    _render-canvas-single(
      spec,
      theme,
      trained,
      prepared,
      coord,
      guides,
      legend-gap,
      margin,
      width-units,
      height-units,
    )
  }

  _render-decorate(canvas, labs, theme)
}
