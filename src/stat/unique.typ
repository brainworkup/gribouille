///! Deduplication statistic.
///!
///! Drops repeated `(x, y)` observations within a group. The framework already
///! partitions data per group, so duplicates are detected within one call.

/// Unique statistic: keep the first row per `(x, y)` key, drop later duplicates.
///
/// The dedup key concatenates the values referenced by `mapping.x` and
/// `mapping.y`. Mapping is returned unchanged.
///
/// @category Stats
/// @stability stable
/// @since 0.0.1
///
/// @returns Statistic object with `name: "unique"`, consumed by geom layers.
///
/// @examples Drop the duplicate `(1, 1)` row; the rendered scatter shows
/// each pair only once.
/// ```
/// #let d = (
///   (x: 1, y: 1),
///   (x: 1, y: 1),
///   (x: 2, y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(stat: "unique"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Compare the same data with @stat-sum to keep duplicates and
/// encode the count in marker size.
/// ```
/// #let d = (
///   (x: 1, y: 1),
///   (x: 1, y: 1),
///   (x: 1, y: 1),
///   (x: 2, y: 2),
///   (x: 3, y: 3),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-count(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @stat-identity
#let stat-unique() = (kind: "stat", name: "unique")

#let apply(data, mapping, params: (:)) = {
  let x-col = if mapping != none { mapping.at("x", default: none) } else {
    none
  }
  let y-col = if mapping != none { mapping.at("y", default: none) } else {
    none
  }
  let seen = (:)
  let rows = ()
  for row in data {
    let xv = if x-col != none { row.at(x-col, default: none) } else { none }
    let yv = if y-col != none { row.at(y-col, default: none) } else { none }
    let key = str(xv) + "\u{1}" + str(yv)
    if seen.keys().contains(key) { continue }
    seen.insert(key, true)
    rows.push(row)
  }
  (data: rows, mapping: mapping)
}
