///! Count observations per unique `(x, y)` pair.
///!
///! Backing statistic for @geom-count. Groups rows by the `(x, y)` key from
///! the layer mapping and emits one row per unique pair carrying the count
///! and proportion as new aesthetics.

/// Sum statistic: one output row per unique `(x, y)` pair with `n` and `prop`.
///
/// Output rows preserve first-seen pair order. The stat re-maps `size` to the
/// `"n"` column so geoms picking up the aesthetic see counts directly.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @returns Statistic object with `name: "sum"`, consumed by geom layers.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = (
///   (x: 1, y: 1),
///   (x: 1, y: 1),
///   (x: 2, y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-count(),),
/// )
/// ```
///
/// @see @geom-count, @stat-count, @stat-unique
#let stat-sum() = (kind: "stat", name: "sum")

#let apply(data, mapping, params: (:)) = {
  let base-mapping = (x: "x", y: "y", size: "n")
  if mapping == none { return (data: (), mapping: base-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: (), mapping: base-mapping)
  }

  let counts = (:)
  let order = ()
  let proto = (:)
  let total = 0
  for row in data {
    let xv = row.at(x-col, default: none)
    let yv = row.at(y-col, default: none)
    if xv == none or yv == none { continue }
    let key = str(xv) + "\u{1}" + str(yv)
    if not order.contains(key) {
      order.push(key)
      proto.insert(key, (x: xv, y: yv))
    }
    counts.insert(key, counts.at(key, default: 0) + 1)
    total += 1
  }

  let rows = ()
  for key in order {
    let p = proto.at(key)
    let n = counts.at(key)
    let prop = if total == 0 { 0.0 } else { n / total }
    rows.push((x: p.x, y: p.y, n: n, prop: prop))
  }

  (data: rows, mapping: base-mapping)
}
