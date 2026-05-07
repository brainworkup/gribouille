///! Per-stat metadata.
///!
///! `stat-info(name)` returns a static record describing what columns a
///! stat's `apply()` publishes. The `outputs` list is consulted by
///! `after-stat(<string>)` to validate column references at layer-prepare
///! time; an empty `outputs` list means "outputs depend on input mapping",
///! which suppresses validation.

#let _STAT-INFO = (
  identity: (outputs: (), default-y: none),
  bin: (
    outputs: ("x", "y", "width", "_count", "density"),
    default-y: "_count",
  ),
  bin_2d: (outputs: ("x", "y", "_count"), default-y: "_count"),
  bin_hex: (outputs: ("x", "y", "_count"), default-y: "_count"),
  bindot: (outputs: ("x", "y", "_count"), default-y: "_count"),
  contour: (outputs: ("x", "y", "level"), default-y: "y"),
  contour_filled: (
    outputs: ("x", "y", "level-low", "level-high"),
    default-y: "y",
  ),
  count: (outputs: ("x", "_count"), default-y: "_count"),
  sum: (outputs: ("x", "y"), default-y: "y"),
  smooth: (outputs: ("x", "y", "ymin", "ymax"), default-y: "y"),
  boxplot: (
    outputs: ("x", "ymin", "lower", "middle", "upper", "ymax"),
    default-y: "middle",
  ),
  summary: (outputs: ("x", "y", "ymin", "ymax"), default-y: "y"),
  summary_bin: (outputs: ("x", "y", "ymin", "ymax"), default-y: "y"),
  summary_2d: (outputs: ("x", "y", "z"), default-y: "y"),
  summary_hex: (outputs: ("x", "y", "z"), default-y: "y"),
  ecdf: (outputs: ("x", "y"), default-y: "y"),
  unique: (outputs: (), default-y: none),
  qq: (outputs: ("x", "y"), default-y: "y"),
  "qq-line": (outputs: ("x", "y"), default-y: "y"),
  function: (outputs: ("x", "y"), default-y: "y"),
  ellipse: (outputs: ("x", "y"), default-y: "y"),
  quantile: (outputs: ("x", "y"), default-y: "y"),
)

/// Look up the metadata record for a stat by name.
///
/// Returns `(outputs: (), default-y: none)` for an unknown stat so
/// callers can treat unknown stats as "no contract" without branching.
///
/// \@internal
/// \@param name Stat name string (e.g. `"bin"`, `"count"`).
/// \@returns Dict with `outputs` (array of column names) and `default-y`.
#let stat-info(name) = {
  _STAT-INFO.at(name, default: (outputs: (), default-y: none))
}

/// Every stat name registered in `apply-stat`'s dispatcher.
///
/// Used by tests to confirm `stat-info` covers every stat and by
/// validation paths that want to know the canonical name set.
///
/// \@internal
/// \@returns Array of stat name strings.
#let stat-names() = _STAT-INFO.keys()
