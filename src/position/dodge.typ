///! Dodge position adjustment.
///!
///! Shifts grouped marks side by side at each x. Partitions rows by the
///! composite group key (all discrete grouping aesthetics in canonical
///! order) and writes per-row dodge offsets consumed by the rendering
///! geom. When every mark at a given x has the same width, output matches
///! the simple uniform layout. When widths differ, slots are packed
///! side-by-side using each mark's own width, with `padding` between
///! adjacent slots, scaled to fit the bucket.

#import "../utils/group.typ": group-key
#import "../utils/types.typ": parse-number

/// Dodge position adjustment: place grouped marks side by side.
///
/// Typically set on a layer as `position: "dodge"` rather than constructed
/// directly; the constructor exists for symmetry with the other positions.
/// When all marks at a given x share the same width, the result matches a
/// simple uniform dodge. When widths differ (per-row `width` column), each
/// mark uses its own width as its slot, with `padding` between slots and a
/// shrink-to-fit if total slot use would exceed the bucket.
///
/// @category Positions
/// @stability stable
/// @since 0.0.1
///
/// @param width Total width reserved for the dodged group, as a fraction of the category width.
/// @param padding Gap between adjacent dodge slots in mixed-width mode, as a fraction of the bucket.
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
/// @see @position-stack, @position-fill, @position-identity, @position-jitter
#let position-dodge(width: 0.9, padding: 0.1) = (
  kind: "position",
  name: "dodge",
  width: width,
  padding: padding,
)

#let _row-width(row, default-width) = {
  let w = parse-number(row.at("width", default: none))
  if w == none { default-width } else { w }
}

#let apply(data, mapping, params: (:)) = {
  let x-col = mapping.at("x", default: none)
  if x-col == none { return (data: data, mapping: mapping) }

  let bar-frac = params.at("width", default: 0.9)
  let padding = params.at("padding", default: 0.1)

  let keys = data.map(row => group-key(row, mapping))
  let levels = ()
  for k in keys {
    if not levels.contains(k) { levels.push(k) }
  }
  let n-levels = levels.len()
  if n-levels <= 1 { return (data: data, mapping: mapping) }

  let buckets = (:)
  let bucket-order = ()
  for (i, row) in data.enumerate() {
    let xv = row.at(x-col, default: none)
    let bk = if xv == none { "" } else { str(xv) }
    let bucket = buckets.at(bk, default: ())
    bucket.push((i: i, row: row, key: keys.at(i)))
    buckets.insert(bk, bucket)
    if not bucket-order.contains(bk) { bucket-order.push(bk) }
  }

  let n-data = data.len()
  let offsets = range(n-data).map(_ => 0.0)
  let n-slots = range(n-data).map(_ => 1)

  for bk in bucket-order {
    let entries = buckets.at(bk)
    let widths = entries.map(e => _row-width(e.row, bar-frac))
    let uniform = widths.dedup().len() <= 1

    if uniform {
      for entry in entries {
        let idx = levels.position(v => v == entry.key)
        if idx == none { continue }
        let off = (idx + 0.5) / n-levels - 0.5
        offsets.at(entry.i) = off
        n-slots.at(entry.i) = n-levels
      }
    } else {
      let n = entries.len()
      let total = widths.sum() + if n > 1 { (n - 1) * padding } else { 0 }
      let scale = if total > 1 { 1.0 / total } else { 1.0 }
      let eff-widths = widths.map(w => w * scale)
      let eff-pad = padding * scale
      let cursor = -0.5
      for (k, entry) in entries.enumerate() {
        let w = eff-widths.at(k)
        let centre = cursor + w / 2
        cursor = cursor + w + eff-pad
        let half = w / 2
        let off = if bar-frac == 0 { 0.0 } else { centre / bar-frac }
        let n-equiv = if half == 0 { 1 } else { bar-frac / (2 * half) }
        offsets.at(entry.i) = off
        n-slots.at(entry.i) = n-equiv
      }
    }
  }

  let out = data
    .enumerate()
    .map(((i, row)) => {
      let new-row = row
      new-row.insert("_dodge-offset", offsets.at(i))
      new-row.insert("_dodge-n", n-slots.at(i))
      new-row
    })

  (data: out, mapping: mapping)
}
