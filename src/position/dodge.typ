///! Dodge position adjustment.
///!
///! Shifts grouped bars side by side at each x.
///! Partitions rows by the composite group key (all discrete grouping
///! aesthetics in canonical order) and writes dodge offsets consumed by
///! @geom-col.

/// Dodge position adjustment: place grouped bars side by side.
///
/// Typically set on a layer as `position: "dodge"` rather than constructed
/// directly; the constructor exists for symmetry with the other positions.
///
/// @category Positions
/// @stability stable
/// @since 0.0.1
///
/// @param width Total width reserved for the dodged group, as a fraction of the category width.
///
/// @returns Position dictionary with `name: "dodge"`, consumed by @plot.
///
/// @example
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #let d = (
///   (q: "Q1", grp: "a", y: 3),
///   (q: "Q1", grp: "b", y: 5),
///   (q: "Q2", grp: "a", y: 4),
///   (q: "Q2", grp: "b", y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp"),
///   layers: (geom-col(position: "dodge"),),
/// )
/// ```
///
/// @see @position-stack, @position-fill, @position-identity
#import "../utils/group.typ": group-key

#let position-dodge(width: 0.9) = (
  kind: "position",
  name: "dodge",
  width: width,
)

#let apply(data, mapping, params: (:)) = {
  let x-col = mapping.at("x", default: none)
  if x-col == none { return (data: data, mapping: mapping) }

  // Compute composite group keys once; collect levels in first-appearance order.
  // Data-type mode (trained: none) since positions run before scale training.
  let keys = data.map(row => group-key(row, mapping))
  let levels = ()
  for k in keys {
    if not levels.contains(k) { levels.push(k) }
  }
  let n = levels.len()
  if n <= 1 { return (data: data, mapping: mapping) }

  let out = data
    .zip(keys)
    .map(((row, k)) => {
      let idx = levels.position(v => v == k)
      if idx == none { return row }
      let off = (idx + 0.5) / n - 0.5
      let new-row = row
      new-row.insert("_dodge-offset", off)
      new-row.insert("_dodge-n", n)
      new-row
    })

  (data: out, mapping: mapping)
}
