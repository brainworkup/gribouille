///! Connection vertices between consecutive observations.
///!
///! `stat-connect` expands each gap between two ordered points into a
///! step-, mid-, or linear-style connector by inserting intermediate
///! vertices. Pair with `geom-path` (or `geom-line`) to render.

#let _CONNECTION-MODES = ("hv", "vh", "mid", "linear")

#let _expand-gap(a, b, x-col, y-col, mode) = {
  if mode == "linear" { return () }
  let xa = a.at(x-col)
  let ya = a.at(y-col)
  let xb = b.at(x-col)
  let yb = b.at(y-col)
  if mode == "hv" {
    return (a + ((x-col): xb, (y-col): ya),)
  }
  if mode == "vh" {
    return (a + ((x-col): xa, (y-col): yb),)
  }
  let mid = (xa + xb) / 2
  (
    a + ((x-col): mid, (y-col): ya),
    a + ((x-col): mid, (y-col): yb),
  )
}

/// Connection statistic: expand consecutive points with intermediate vertices.
///
/// Modes:
/// - `"hv"` (default): horizontal then vertical. Inserts `(x_{i+1}, y_i)` between each pair.
/// - `"vh"`: vertical then horizontal. Inserts `(x_i, y_{i+1})`.
/// - `"mid"`: half-step both ways. Inserts `(mid, y_i)` and `(mid, y_{i+1})` at the midpoint.
/// - `"linear"`: pass-through (no intermediate vertices).
///
/// \@category Stats
/// \@stability stable
/// \@since 0.6.0
///
/// \@param connection Connection mode (`"hv"` / `"vh"` / `"mid"` / `"linear"`).
/// \@param na-rm Drop rows with `none` x or y. Defaults to `false`.
///
/// \@returns Statistic object with `name: "connect"`, consumed by geom layers.
///
/// \@examples Step-style line via `"mid"`: midpoint corners between
/// consecutive observations.
/// ```
/// #let d = range(0, 7).map(i => (x: i, y: calc.rem(i * 3, 5)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-path(stat: stat-connect(connection: "mid"), stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-step, \@geom-path
#let stat-connect(connection: "hv", na-rm: false) = {
  if not _CONNECTION-MODES.contains(connection) {
    panic(
      "stat-connect: connection must be one of "
        + repr(_CONNECTION-MODES)
        + "; got "
        + repr(connection),
    )
  }
  (
    kind: "stat",
    name: "connect",
    params: (connection: connection, na-rm: na-rm),
  )
}

#let apply(data, mapping, params: (:)) = {
  if mapping == none { return (data: data, mapping: mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: data, mapping: mapping)
  }
  let mode = params.at("connection", default: "hv")
  let na-rm = params.at("na-rm", default: false)

  let rows = data
  if na-rm {
    rows = rows.filter(r => (
      r.at(x-col, default: none) != none and r.at(y-col, default: none) != none
    ))
  }
  let n = rows.len()
  if n < 2 { return (data: rows, mapping: mapping) }

  let sorted = rows.sorted(key: r => r.at(x-col))
  let out = (sorted.first(),)
  for i in range(1, n) {
    let prev = sorted.at(i - 1)
    let cur = sorted.at(i)
    for v in _expand-gap(prev, cur, x-col, y-col, mode) {
      out.push(v)
    }
    out.push(cur)
  }
  (data: out, mapping: mapping)
}
