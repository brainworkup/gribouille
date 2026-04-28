///! Stack position adjustment.
///!
///! Cumulates y per x bucket, writing `ymin` and `ymax` per row so geoms
///! that honour them (like @geom-col) can draw the stacked segment. Groups
///! sharing the same x and discrete aesthetic are stacked in the order rows
///! appear in `data`.

#import "../utils/types.typ": parse-number

/// Stack position adjustment: cumulate y per x bucket.
///
/// Stacking is per x bucket across all groups, so different groups at the
/// same x are stacked on top of each other in row order.
///
/// Typically set on a layer as `position: "stack"` rather than constructed
/// directly; the constructor exists for symmetry with the other positions.
///
/// @category Positions
/// @stability stable
/// @since 0.0.1
///
/// @returns Position dictionary with `name: "stack"`, consumed by @plot.
///
/// @examples Two groups stacked per quarter to show component contribution
/// to a total.
/// ```
/// #let d = (
///   (q: "Q1", grp: "a", y: 3),
///   (q: "Q1", grp: "b", y: 5),
///   (q: "Q2", grp: "a", y: 4),
///   (q: "Q2", grp: "b", y: 2),
///   (q: "Q3", grp: "a", y: 6),
///   (q: "Q3", grp: "b", y: 4),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp"),
///   layers: (geom-col(position: "stack"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @examples Stacked area chart over time, useful when the running total
/// itself is informative.
/// ```
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for i in range(0, 10) {
///     d.push((x: i, y: i * 0.3 + (if grp == "b" { 1 } else if grp == "c" { 2 } else { 0 }), grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "grp"),
///   layers: (geom-area(position: "stack", alpha: 0.6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// @see @position-dodge, @position-fill, @position-identity
#let position-stack() = (kind: "position", name: "stack")

#let apply(data, mapping, params: (:)) = {
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return (data: data, mapping: mapping) }

  // Cumulative running totals keyed by x value.
  let running = (:)
  let out = ()
  for row in data {
    let xv = row.at(x-col, default: none)
    let yv = parse-number(row.at(y-col, default: none))
    if xv == none or yv == none {
      out.push(row)
      continue
    }
    let k = str(xv)
    let prev = running.at(k, default: 0.0)
    let ymin = prev
    let ymax = prev + yv
    running.insert(k, ymax)
    let new-row = row
    new-row.insert("ymin", ymin)
    new-row.insert("ymax", ymax)
    new-row.insert(y-col, ymax)
    out.push(new-row)
  }

  let new-mapping = mapping
  new-mapping.insert("ymin", "ymin")
  new-mapping.insert("ymax", "ymax")
  (data: out, mapping: new-mapping)
}
