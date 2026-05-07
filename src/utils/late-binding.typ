///! Late-binding aesthetic markers.
///!
///! Constructors for ggplot2 v4 / plotnine late-binding primitives. These
///! markers defer aesthetic resolution past the point where a column was
///! first bound, so callers can pull values from the trained stat output,
///! the resolved scale output, or the active theme.
///!
///! Slice 1 ships `from-theme(path)`. The remaining primitives
///! (`after-stat`, `after-scale`, `stage`) are added in later slices and
///! share the same `is-late-binding(v)` / `late-binding-kind(v)` test pair.

#let _LATE-BINDING-KINDS = ("after-stat", "after-scale", "stage", "from-theme")

/// Whether a mapping value is a late-binding marker.
///
/// \@internal
/// \@param v Any value pulled from an aesthetic mapping.
/// \@returns `true` when `v` is a dictionary tagged with one of the
///   late-binding kinds.
#let is-late-binding(v) = (
  type(v) == dictionary and v.at("kind", default: none) in _LATE-BINDING-KINDS
)

/// Read the late-binding kind tag on a marker, or `none` if `v` is not a
/// late-binding marker.
///
/// \@internal
/// \@param v Any value.
/// \@returns The kind string (`"after-stat"`, `"after-scale"`, `"stage"`,
///   `"from-theme"`) or `none`.
#let late-binding-kind(v) = if is-late-binding(v) { v.kind } else { none }

/// Pull a value from the resolved theme at render time.
///
/// `path` may be a dotted string (`"axis-line.colour"`) or an array of
/// keys (`("axis-line", "colour")`). Both forms are equivalent.
///
/// `from-theme(...)` resolves at layer prepare time, so the marker is
/// replaced by a literal scalar before scale training and per-row
/// rendering ever see it. Use it on aesthetic channels that have a
/// fixed-value layer parameter (`colour`, `fill`, `size`, `alpha`,
/// `linewidth`, `stroke`, `shape`, `linetype`).
///
/// \@category Aesthetics
/// \@stability experimental
/// \@since 0.0.1
///
/// \@param path Dotted string or array of keys naming a theme entry.
/// \@returns Late-binding marker consumed by \@aes.
///
/// \@examples Pin a layer's stroke colour to the active theme's `ink`.
/// ```
/// #let d = (
///   (x: 1, y: 2),
///   (x: 2, y: 4),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: from-theme("ink")),
///   layers: (geom-point(size: 3pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@aes, \@theme
#let from-theme(path) = (kind: "from-theme", path: path)

#let _path-parts(path) = {
  if type(path) == str { return path.split(".") }
  if type(path) == array { return path }
  panic(
    "from-theme: path must be a string or array; got " + str(type(path)),
  )
}

/// Resolve a `from-theme(path)` marker against a merged theme dictionary.
///
/// Walks each key of the path through nested dictionaries; panics with a
/// readable message when a key is missing or the cursor is no longer a
/// dictionary halfway through the walk.
///
/// \@internal
/// \@param theme Merged theme dictionary.
/// \@param path Dotted string or array of keys.
/// \@returns The resolved scalar (often a colour or length).
#let resolve-from-theme(theme, path) = {
  let parts = _path-parts(path)
  if parts.len() == 0 {
    panic("from-theme: empty path")
  }
  let cur = theme
  let walked = ()
  for part in parts {
    if type(cur) != dictionary {
      panic(
        "from-theme: cannot descend into "
          + str(type(cur))
          + " at '"
          + part
          + "' in path "
          + walked.join(".")
          + (if walked.len() > 0 { "." } else { "" })
          + part,
      )
    }
    if not (part in cur) {
      panic(
        "from-theme: key '"
          + part
          + "' not found in theme at path "
          + walked.join(".")
          + (if walked.len() > 0 { "." } else { "" })
          + part,
      )
    }
    cur = cur.at(part)
    walked.push(part)
  }
  cur
}
