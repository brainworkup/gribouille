///! Per-stat metadata.
///!
///! `stat-info(name)` returns a static record describing what columns a
///! stat's `apply()` publishes. The `outputs` list is consulted by
///! `after-stat(<string>)` to validate column references at layer-prepare
///! time; an empty `outputs` list means "outputs depend on input mapping",
///! which suppresses validation. Stats whose published columns have not
///! been verified against their `apply()` keep `outputs: ()` until they
///! are; this is preferred over fabricating contracts that would mislead
///! validation.

#let _STAT-INFO = (
  identity: (outputs: ()),
  bin: (outputs: ("x", "y", "width", "_count", "density")),
  bin_2d: (outputs: ()),
  bin_hex: (outputs: ()),
  bindot: (outputs: ()),
  contour: (outputs: ()),
  contour_filled: (outputs: ()),
  count: (outputs: ("x", "_count")),
  sum: (outputs: ()),
  smooth: (outputs: ()),
  boxplot: (outputs: ()),
  summary: (outputs: ()),
  summary_bin: (outputs: ()),
  summary_2d: (outputs: ()),
  summary_hex: (outputs: ()),
  ecdf: (outputs: ()),
  unique: (outputs: ()),
  qq: (outputs: ()),
  "qq-line": (outputs: ()),
  function: (outputs: ()),
  ellipse: (outputs: ()),
  quantile: (outputs: ()),
)

/// Look up the metadata record for a stat by name.
///
/// Returns `(outputs: ())` for an unknown stat so callers can treat
/// unknown stats as "no contract" without branching.
///
/// \@internal
/// \@param name Stat name string (e.g. `"bin"`, `"count"`).
/// \@returns Dict with `outputs` (array of column names).
#let stat-info(name) = _STAT-INFO.at(name, default: (outputs: ()))

/// Every stat name registered in `apply-stat`'s dispatcher.
///
/// Used by tests to confirm `stat-info` covers every stat and by
/// validation paths that want to know the canonical name set.
///
/// \@internal
/// \@returns Array of stat name strings.
#let stat-names() = _STAT-INFO.keys()
