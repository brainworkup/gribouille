// Aesthetic mapping resolution.
//
// Aesthetic mapping values arrive in three shapes:
//
// - A plain column-name string: `aes(x: "col")`.
// - A `mapping-ref` produced by `as-factor`/`as-numeric`: forces the
//   scale type without changing the resolved value.
// - A `typst-markup` produced by `typst()`: marks the value for
//   evaluation as Typst markup wherever the scale renders text.
//
// The two tagged shapes compose: `typst(as-factor("col"))` is a
// `typst-markup` whose `source` is a `mapping-ref`, and the helpers
// below walk such chains innermost-first.

#import "typst-markup.typ": eval-as-markup, is-typst-markup

/// Strip `mapping-ref` wrappers but preserve `typst-markup` intent.
///
/// Returns the value with every `mapping-ref` collapsed to its inner
/// reference; if a `typst-markup` is present at any level the result is
/// a single `typst-markup` whose `source` is the underlying column name
/// or value. Plain strings and unrecognised values pass through.
///
/// \@internal
/// \@param spec An aesthetic mapping value.
/// \@returns A column-name string, a `typst-markup` dict, or `spec`
///   unchanged when neither tag applies.
#let unwrap-mapping-refs(spec) = {
  if type(spec) != dictionary { return spec }
  let kind = spec.at("kind", default: none)
  if kind == "mapping-ref" {
    return unwrap-mapping-refs(spec.at("var", default: none))
  }
  if kind == "typst-markup" {
    let inner = unwrap-mapping-refs(spec.at("source", default: none))
    if (
      type(inner) == dictionary
        and inner.at("kind", default: none) == "typst-markup"
    ) {
      return inner
    }
    return (kind: "typst-markup", source: inner)
  }
  spec
}

/// Return the underlying column name from an aesthetic mapping value.
///
/// Walks both `mapping-ref` and `typst-markup` wrappers and returns the
/// innermost string. Returns the input unchanged when no tag applies, or
/// `none` for `none`.
///
/// \@internal
/// \@param spec An aesthetic mapping value.
/// \@returns The column-name string or `none`.
#let aes-col(spec) = {
  if spec == none { return none }
  let unwrapped = unwrap-mapping-refs(spec)
  if (
    type(unwrapped) == dictionary
      and unwrapped.at("kind", default: none) == "typst-markup"
  ) {
    let src = unwrapped.source
    if type(src) == str { return src }
    return none
  }
  if type(unwrapped) == str { return unwrapped }
  none
}

/// Read an aesthetic value from a row, optionally evaluating as Typst
/// markup.
///
/// In `mode: "raw"` (the default) the underlying column value is
/// returned, regardless of whether the spec carries a `typst-markup`
/// tag. Used by scale training and the data-to-aesthetic mapping path.
///
/// In `mode: "display"` the resolver eval's the read value as Typst
/// markup when (and only when) the spec carries a `typst-markup` tag at
/// any nesting depth. Used by display surfaces (geom-text labels,
/// legend swatches, axis ticks, facet strip text).
///
/// \@internal
/// \@param spec Aesthetic mapping value (string, `mapping-ref`, or
///   `typst-markup`).
/// \@param row The row dictionary to read from.
/// \@param mode `"raw"` or `"display"`.
/// \@returns The resolved value, evaluated when in display mode and the
///   spec is typst-tagged.
#let resolve-aes-value(spec, row, mode: "raw") = {
  let col = aes-col(spec)
  if col == none { return none }
  let raw = row.at(col, default: none)
  if mode == "display" and is-typst-markup(spec) {
    return eval-as-markup(raw)
  }
  raw
}

/// Apply display-mode resolution to a pre-read break value.
///
/// Used by display surfaces that hold scale breaks rather than rows
/// (legend swatches, axis tick labels, facet strip text). Evaluates
/// `value` as Typst markup when `spec` is typst-tagged; returns the
/// value unchanged otherwise.
///
/// \@internal
/// \@param spec The originating aesthetic mapping value.
/// \@param value The break value to display.
/// \@returns The value, evaluated as markup when the spec is typst-tagged.
#let resolve-break-display(spec, value) = {
  if value == none { return none }
  if is-typst-markup(spec) { return eval-as-markup(value) }
  value
}
