// Scale training and value-to-range mapping.
//
// Training walks every layer's data for the given aesthetic and computes
// the union domain. A continuous domain is (min, max); a discrete domain
// is the list of unique levels in order of first appearance.
//
// Mapping turns a trained domain plus a target range into a scalar position.

#import "../data.typ": column
#import "../utils/types.typ": infer-column-type, parse-number
#import "../utils/typst-markup.typ": is-typst-markup

#let _resolve-mapping(layer, plot-mapping) = {
  if layer.at("inherit-aes", default: true) and plot-mapping != none {
    let merged = plot-mapping
    if layer.mapping != none {
      for (k, v) in layer.mapping.pairs() {
        if v != none { merged.insert(k, v) }
      }
    }
    merged
  } else if layer.mapping != none {
    layer.mapping
  } else {
    plot-mapping
  }
}

#let _resolve-data(layer, plot-data) = {
  if layer.data != none { layer.data } else { plot-data }
}

// A mapping value is either a plain string (column name), a `mapping-ref`
// annotation produced by `as-factor("col")` / `as-numeric("col")`, or a
// `typst-markup` annotation produced by `typst("col")`. The two tag
// kinds compose. Return the column name either way.
#let mapping-ref-col(value) = {
  if type(value) != dictionary { return value }
  let kind = value.at("kind", default: none)
  if kind == "mapping-ref" {
    return mapping-ref-col(value.at("var", default: none))
  }
  if kind == "typst-markup" {
    return mapping-ref-col(value.at("source", default: none))
  }
  value
}

// Return the forced type from a `mapping-ref` (`as-factor` /
// `as-numeric`), looking through `typst-markup` wrappers. Returns `none`
// when no `mapping-ref` is present.
#let mapping-ref-type(value) = {
  if type(value) != dictionary { return none }
  let kind = value.at("kind", default: none)
  if kind == "mapping-ref" { return value.type }
  if kind == "typst-markup" {
    return mapping-ref-type(value.at("source", default: none))
  }
  none
}

// Two-arg `as-factor(data, col)` stamps each row with `_gribouille-factors`
// listing every column it has stringified. Read the first row only because
// every row carries the same array.
#let _factor-sentinel-type(data, col-name) = {
  if type(data) != array or data.len() == 0 { return none }
  let first = data.at(0)
  if type(first) != dictionary { return none }
  let factors = first.at("_gribouille-factors", default: none)
  if type(factors) == array and factors.contains(col-name) {
    return "discrete"
  }
  none
}

#let _column-for-aesthetic(layer, aesthetic, plot-mapping, plot-data) = {
  let mapping = _resolve-mapping(layer, plot-mapping)
  let data = _resolve-data(layer, plot-data)
  if mapping == none { return none }
  let raw = mapping.at(aesthetic, default: none)
  if raw == none { return none }
  let col-name = mapping-ref-col(raw)
  let forced = mapping-ref-type(raw)
  if forced == none {
    forced = _factor-sentinel-type(data, col-name)
  }
  (
    name: col-name,
    values: column(data, col-name),
    forced-type: forced,
  )
}

// Positional aesthetics drive panel layout and are retrained per panel under
// `facet-wrap` free scales. The order here matters: `train()` folds the
// synthetic feeders (xmin/xmax/ymin/ymax/xend/yend) into x and y after the
// per-aesthetic loop, so x/y appear first.
#let positional-aesthetics = (
  "x",
  "y",
  "xmin",
  "xmax",
  "ymin",
  "ymax",
  "xend",
  "yend",
)

// Synthetic feeder axes feed their min/max into the main x or y axis; they
// must not get singleton-domain expansion (which would turn `ymin: 0` on
// every bar into `(-0.5, 0.5)` and bleed below the y=0 baseline).
#let _SYNTHETIC-FEEDERS = positional-aesthetics.filter(a => (
  a != "x" and a != "y"
))

#let all-aesthetics = (
  "x",
  "y",
  "colour",
  "fill",
  "size",
  "alpha",
  "linewidth",
  "shape",
  "linetype",
  "xmin",
  "xmax",
  "ymin",
  "ymax",
  "xend",
  "yend",
)

#let _continuous-domain-from-cache(cols, aesthetic) = {
  let all-vals = ()
  for col in cols {
    let numeric = col.values.map(parse-number).filter(v => v != none)
    all-vals += numeric
  }
  if all-vals.len() == 0 { return (0.0, 1.0) }
  let lo = calc.min(..all-vals)
  let hi = calc.max(..all-vals)
  if lo == hi and not _SYNTHETIC-FEEDERS.contains(aesthetic) {
    return (lo - 0.5, hi + 0.5)
  }
  (lo, hi)
}

#let _discrete-domain-from-cache(cols) = {
  let seen = ()
  for col in cols {
    for v in col.values {
      if v == none or v == "" { continue }
      let s = str(v)
      if not seen.contains(s) { seen.push(s) }
    }
  }
  seen
}

#let _scale-type-from-cache(cols) = {
  for col in cols {
    if col.forced-type != none { return col.forced-type }
    let t = infer-column-type(col.values)
    if t == "numeric" { return "continuous" }
    if t == "colour" or t == "length" { return "identity" }
    return "discrete"
  }
  "continuous"
}

#let _find-user-scale(scales, aesthetic) = {
  for s in scales {
    if s.aesthetic == aesthetic { return s }
  }
  none
}

#let _scale-param(target, spec, key, fallback) = {
  if target != none { return target.at(key, default: fallback) }
  if spec != none { return spec.at(key, default: fallback) }
  fallback
}

#let train(
  scales: (),
  layers: (),
  mapping: none,
  data: none,
  aesthetics: none,
) = {
  let trained = (:)
  let aes-list = if aesthetics == none { all-aesthetics } else { aesthetics }

  let cache = (:)
  for a in aes-list { cache.insert(a, (cols: (), typst-mark: false)) }
  for layer in layers {
    let layer-mapping = _resolve-mapping(layer, mapping)
    if layer-mapping == none { continue }
    let layer-data = _resolve-data(layer, data)
    for a in aes-list {
      let raw = layer-mapping.at(a, default: none)
      if raw == none { continue }
      let col-name = mapping-ref-col(raw)
      let forced = mapping-ref-type(raw)
      if forced == none {
        forced = _factor-sentinel-type(layer-data, col-name)
      }
      let entry = cache.at(a)
      entry.cols.push((
        name: col-name,
        values: column(layer-data, col-name),
        forced-type: forced,
      ))
      if is-typst-markup(raw) { entry.typst-mark = true }
      cache.insert(a, entry)
    }
  }

  for a in aes-list {
    let user-scale = _find-user-scale(scales, a)
    let cached = cache.at(a)
    let cols = cached.cols
    let mapped = cols.len() > 0
    let typst-mark = cached.typst-mark
    if not mapped and user-scale == none { continue }
    let scale-type = if user-scale != none {
      user-scale.type
    } else {
      _scale-type-from-cache(cols)
    }
    let domain = if scale-type == "identity" {
      ()
    } else if scale-type == "continuous" {
      _continuous-domain-from-cache(cols, a)
    } else {
      _discrete-domain-from-cache(cols)
    }
    if (
      scale-type != "identity"
        and user-scale != none
        and user-scale.at("limits", default: none) != none
    ) {
      domain = user-scale.limits
    }
    if (
      scale-type == "continuous"
        and user-scale != none
        and user-scale.at("extend", default: none) != none
        and (user-scale.at("limits", default: none) == none)
    ) {
      let (lo, hi) = domain
      for v in user-scale.extend {
        let n = parse-number(v)
        if n == none { continue }
        lo = calc.min(lo, n)
        hi = calc.max(hi, n)
      }
      if lo == hi {
        lo -= 0.5
        hi += 0.5
      }
      domain = (lo, hi)
    }
    let trans = if user-scale != none {
      user-scale.at("trans", default: "identity")
    } else { "identity" }
    let entry = (
      type: scale-type,
      domain: domain,
      spec: user-scale,
      trans: trans,
      typst-mark: typst-mark,
    )
    if user-scale != none and user-scale.at("temporal", default: none) != none {
      entry.insert("temporal", user-scale.temporal)
      entry.insert("date-format", user-scale.at("date-format", default: ""))
    }
    trained.insert(a, entry)
  }

  // Fold the directional aesthetics into the positional axes so the x and y
  // domains span every column that contributes a position. Without this,
  // `geom-segment(x: 0, xend: 4, ...)` would clip the panel at x = 0.
  for axis in ("x", "y") {
    let sources = _SYNTHETIC-FEEDERS.filter(s => s.starts-with(axis))
    let target = trained.at(axis, default: none)
    if target != none and target.type != "continuous" { continue }
    let lo = if target != none { target.domain.at(0) } else { none }
    let hi = if target != none { target.domain.at(1) } else { none }
    for s in sources {
      let t = trained.at(s, default: none)
      if t == none or t.type != "continuous" { continue }
      let (slo, shi) = t.domain
      lo = if lo == none { slo } else { calc.min(lo, slo) }
      hi = if hi == none { shi } else { calc.max(hi, shi) }
    }
    if lo == none or hi == none { continue }
    if lo == hi {
      lo -= 0.5
      hi += 0.5
    }
    let spec = if target != none { target.spec } else { none }
    if spec != none and spec.at("limits", default: none) != none { continue }
    let entry = (
      type: "continuous",
      domain: (lo, hi),
      spec: spec,
      trans: _scale-param(target, spec, "trans", "identity"),
      typst-mark: _scale-param(target, none, "typst-mark", false),
    )
    let temporal = _scale-param(target, spec, "temporal", none)
    if temporal != none {
      entry.insert("temporal", temporal)
      entry.insert(
        "date-format",
        _scale-param(target, spec, "date-format", ""),
      )
    }
    trained.insert(axis, entry)
  }

  trained
}

#let map-continuous(value, domain, range) = {
  let (d-lo, d-hi) = domain
  let (r-lo, r-hi) = range
  if d-hi == d-lo { return (r-lo + r-hi) / 2 }
  let t = (value - d-lo) / (d-hi - d-lo)
  r-lo + t * (r-hi - r-lo)
}

// `view-index` overrides the default midpoint placement: levels sit at
// integer positions `0..n-1` and map linearly through the supplied viewport.
// Used by positional discrete scales after expansion is applied. The default
// viewport `(-0.5, n - 0.5)` reproduces the midpoint-of-equal-slots layout
// used by non-positional discrete scales (colour, fill, shape, ...).
#let map-discrete(value, domain, range, view-index: none) = {
  let s = str(value)
  let idx = domain.position(v => v == s)
  let n = domain.len()
  if idx == none or n == 0 { return none }
  let (r-lo, r-hi) = range
  let (v-lo, v-hi) = if view-index == none {
    (-0.5, n - 0.5)
  } else { view-index }
  if v-hi == v-lo { return (r-lo + r-hi) / 2 }
  r-lo + (idx - v-lo) * (r-hi - r-lo) / (v-hi - v-lo)
}

// Panel-units span between adjacent levels for a discrete trained scale,
// honouring `view-index` expansion. Returns `0` for an empty domain.
#let discrete-slot-width(trained, range) = {
  let (lo, hi) = range
  let view = trained.at("view-index", default: none)
  if view != none {
    let (v-lo, v-hi) = view
    if v-hi == v-lo { return hi - lo }
    return (hi - lo) / (v-hi - v-lo)
  }
  let n = trained.domain.len()
  if n == 0 { return 0 }
  (hi - lo) / n
}

// Forward axis transformation for `log10` and `sqrt`: warps coordinates so
// equal visual distances correspond to equal multiplicative or square-root
// steps. `reverse` is handled separately by swapping the range endpoints.
#let trans-fwd(name, x) = {
  if name == none or name == "identity" or name == "reverse" { return x }
  if name == "log10" { return calc.log(x, base: 10) }
  if name == "sqrt" { return calc.sqrt(x) }
  x
}

// Inverse of `trans-fwd`: convert a transformed-space coordinate back to
// data space. Used to back-translate a padded view range so axis breaks
// can be picked in data units.
#let trans-inv(name, x) = {
  if name == none or name == "identity" or name == "reverse" { return x }
  if name == "log10" { return calc.pow(10, x) }
  if name == "sqrt" { return x * x }
  x
}

#let _map-trans(trained, value, range) = {
  let trans = trained.at("trans", default: "identity")
  let view-trans = trained.at("view-trans", default: none)
  let (t-lo, t-hi) = if view-trans != none {
    view-trans
  } else {
    let (d-lo, d-hi) = trained.domain
    (trans-fwd(trans, d-lo), trans-fwd(trans, d-hi))
  }
  let (r-lo, r-hi) = range
  let target = if trans == "reverse" { (r-hi, r-lo) } else { (r-lo, r-hi) }
  map-continuous(trans-fwd(trans, value), (t-lo, t-hi), target)
}

#let map-position(trained, value, range) = {
  if trained.type == "continuous" {
    let v = parse-number(value)
    if v == none { return none }
    _map-trans(trained, v, range)
  } else {
    map-discrete(
      value,
      trained.domain,
      range,
      view-index: trained.at("view-index", default: none),
    )
  }
}

// Trans-aware wrapper for callers that already hold a numeric axis value
// (renderer break placement, reference-line geoms). Equivalent to
// `map-position` but skips the `parse-number` round-trip.
#let map-axis(trained, value, range) = {
  if trained.type != "continuous" { return none }
  _map-trans(trained, value, range)
}
