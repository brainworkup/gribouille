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

#let train-continuous(layers, aesthetic, plot-mapping, plot-data) = {
  let all-vals = ()
  for layer in layers {
    let col = _column-for-aesthetic(layer, aesthetic, plot-mapping, plot-data)
    if col == none { continue }
    let numeric = col.values.map(parse-number).filter(v => v != none)
    all-vals += numeric
  }
  if all-vals.len() == 0 { return (0.0, 1.0) }
  let lo = calc.min(..all-vals)
  let hi = calc.max(..all-vals)
  if lo == hi { return (lo - 0.5, hi + 0.5) }
  (lo, hi)
}

#let train-discrete(layers, aesthetic, plot-mapping, plot-data) = {
  let seen = ()
  for layer in layers {
    let col = _column-for-aesthetic(layer, aesthetic, plot-mapping, plot-data)
    if col == none { continue }
    for v in col.values {
      if v == none or v == "" { continue }
      let s = str(v)
      if not seen.contains(s) { seen.push(s) }
    }
  }
  seen
}

#let _layer-aesthetic-type(layers, aesthetic, plot-mapping, plot-data) = {
  for layer in layers {
    let col = _column-for-aesthetic(layer, aesthetic, plot-mapping, plot-data)
    if col == none { continue }
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

#let train(scales: (), layers: (), mapping: none, data: none) = {
  let trained = (:)
  let aesthetics = (
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
  for a in aesthetics {
    let user-scale = _find-user-scale(scales, a)
    let mapped = false
    let typst-mark = false
    for layer in layers {
      let m = _resolve-mapping(layer, mapping)
      if m == none { continue }
      let v = m.at(a, default: none)
      if v == none { continue }
      mapped = true
      if is-typst-markup(v) { typst-mark = true }
    }
    if not mapped and user-scale == none { continue }
    let scale-type = if user-scale != none {
      user-scale.type
    } else {
      _layer-aesthetic-type(layers, a, mapping, data)
    }
    let domain = if scale-type == "identity" {
      ()
    } else if scale-type == "continuous" {
      train-continuous(layers, a, mapping, data)
    } else {
      train-discrete(layers, a, mapping, data)
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
  // domains span every column that contributes a position: `x` plus
  // `xmin/xmax/xend`, and `y` plus `ymin/ymax/yend`. Without this,
  // `geom-segment(x: 0, xend: 4, ...)` would clip the panel at x = 0.
  for (axis, sources) in (
    (axis: "x", sources: ("xmin", "xmax", "xend")),
    (axis: "y", sources: ("ymin", "ymax", "yend")),
  ) {
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

#let map-discrete(value, domain, range) = {
  let s = str(value)
  let idx = domain.position(v => v == s)
  let n = domain.len()
  if idx == none or n == 0 { return none }
  let (r-lo, r-hi) = range
  if n == 1 { return (r-lo + r-hi) / 2 }
  r-lo + (idx + 0.5) * (r-hi - r-lo) / n
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

#let _map-trans(trained, value, range) = {
  let trans = trained.at("trans", default: "identity")
  let (d-lo, d-hi) = trained.domain
  let (r-lo, r-hi) = range
  let target = if trans == "reverse" { (r-hi, r-lo) } else { (r-lo, r-hi) }
  map-continuous(
    trans-fwd(trans, value),
    (trans-fwd(trans, d-lo), trans-fwd(trans, d-hi)),
    target,
  )
}

#let map-position(trained, value, range) = {
  if trained.type == "continuous" {
    let v = parse-number(value)
    if v == none { return none }
    _map-trans(trained, v, range)
  } else {
    map-discrete(value, trained.domain, range)
  }
}

// Trans-aware wrapper for callers that already hold a numeric axis value
// (renderer break placement, reference-line geoms). Equivalent to
// `map-position` but skips the `parse-number` round-trip.
#let map-axis(trained, value, range) = {
  if trained.type != "continuous" { return none }
  _map-trans(trained, value, range)
}
