#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/bin2d.typ": bin-midpoint-2d, bin-of-2d, resolve-bin-grid-2d
#import "../utils/summaries.typ": mean, median
#import "../utils/types.typ": parse-number

#let _numeric(values) = {
  values.map(parse-number).filter(v => v != none)
}

#let _scalar-reducers = (
  mean: values => mean(values).y,
  median: values => median(values).y,
  sum: values => {
    let xs = _numeric(values)
    if xs.len() == 0 { none } else { xs.sum() }
  },
  min: values => {
    let xs = _numeric(values)
    if xs.len() == 0 { none } else { calc.min(..xs) }
  },
  max: values => {
    let xs = _numeric(values)
    if xs.len() == 0 { none } else { calc.max(..xs) }
  },
)

#let _reduce(name, values) = {
  if type(name) == function { return name(values) }
  let fn = _scalar-reducers.at(name, default: none)
  if fn == none {
    panic("stat-summary-2d: unknown fun " + repr(name))
  }
  fn(values)
}

/// Two-dimensional summary statistic.
///
/// Partitions (x, y) into a rectangular grid (same rule as \@stat-bin-2d),
/// then for every non-empty cell reduces the `z` values inside to a single
/// scalar emitted as the `value` column.
///
/// `fun` accepts a string keyword (`"mean"`, `"median"`, `"sum"`, `"min"`,
/// `"max"`) or a callable `values => scalar`.
///
/// \@category Stats
/// \@stability stable
/// \@since 0.4.0
///
/// \@param fun Reduction. String keyword or callable.
/// \@param bins Scalar or `(x, y)` pair — target bin counts.
/// \@param binwidth Scalar or `(x, y)` pair — fixed bin widths.
///
/// \@returns Statistic object with `name: "summary_2d"`.
///
/// \@see \@stat-bin-2d, \@stat-summary-bin
#let stat-summary-2d(fun: "mean", bins: 30, binwidth: none) = (
  kind: "stat",
  name: "summary_2d",
  params: (fun: fun, bins: bins, binwidth: binwidth),
)

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (
      x: "x",
      y: "y",
      xmin: "xmin",
      xmax: "xmax",
      ymin: "ymin",
      ymax: "ymax",
      fill: "value",
    ),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let z-col = mapping.at("z", default: none)
  if x-col == none or y-col == none or z-col == none {
    return (data: (), mapping: new-mapping)
  }
  let triples = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      let yv = parse-number(r.at(y-col, default: none))
      let zv = r.at(z-col, default: none)
      if xv == none or yv == none or zv == none { return none }
      (x: xv, y: yv, z: zv)
    })
    .filter(p => p != none)
  if triples.len() == 0 { return (data: (), mapping: new-mapping) }
  let grid = resolve-bin-grid-2d(
    triples.map(t => t.x),
    triples.map(t => t.y),
    params,
  )
  let ny = grid.y-n-bins
  let buckets = range(grid.x-n-bins * ny).map(_ => ())
  for t in triples {
    let (ix, iy) = bin-of-2d(t.x, t.y, grid)
    let k = ix * ny + iy
    let bucket = buckets.at(k)
    bucket.push(t.z)
    buckets.at(k) = bucket
  }
  let fun = params.at("fun", default: "mean")
  let rows = ()
  for k in range(buckets.len()) {
    let bucket = buckets.at(k)
    if bucket.len() == 0 { continue }
    let value = _reduce(fun, bucket)
    if value == none { continue }
    let (xm, ym) = bin-midpoint-2d(grid, calc.quo(k, ny), calc.rem(k, ny))
    rows.push((
      x: xm,
      y: ym,
      xmin: xm - grid.x-width / 2,
      xmax: xm + grid.x-width / 2,
      ymin: ym - grid.y-width / 2,
      ymax: ym + grid.y-width / 2,
      value: value,
    ))
  }
  (data: rows, mapping: new-mapping)
}
