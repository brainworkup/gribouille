// Shared margin and length resolution helpers used by the renderer and theme
// code. Converts user-supplied lengths (absolute or em) to cm floats consumed
// by the cetz canvas, and provides fall-through semantics so unset sides keep
// the renderer default.

// Convert a Typst length (which may contain em components) to a float in cm.
// `size-pt` is the surface font size as a unitless point value; em components
// are resolved against it using Typst's exact pt-to-cm conversion so absolute
// and relative parts stay consistent.
#let length-to-cm(value, size-pt) = {
  if type(value) == length {
    value.abs / 1cm + value.em * (size-pt * 1pt / 1cm)
  } else if type(value) == int or type(value) == float {
    float(value)
  } else {
    0.0
  }
}

// Resolve a margin-side input to a float in cm, falling back when the input
// is `auto` or otherwise unset. `value` may be `auto`, `none`, or a length.
// `fallback` may be a length or a cm-as-float; em components in either are
// resolved against `size-pt`.
#let resolve-margin-side-cm(value, fallback, size-pt: 9) = {
  if type(value) == length {
    return length-to-cm(value, size-pt)
  }
  if type(fallback) == length {
    return length-to-cm(fallback, size-pt)
  }
  if type(fallback) == int or type(fallback) == float {
    return float(fallback)
  }
  0.0
}

// Resolve a margin-side input without em awareness. `value` is `auto` or an
// absolute length; `fallback` is a cm-as-float dynamic default that already
// covers the chrome (axis title, tick labels, legend, caption, etc.). User
// values are additive: they extend the dynamic default outward. `auto` keeps
// the dynamic default unchanged (no extra padding).
#let resolve-margin-side(value, fallback) = {
  let base = if type(fallback) == int or type(fallback) == float {
    float(fallback)
  } else { 0.0 }
  if value == auto { return base }
  if type(value) == length { return base + value / 1cm }
  base
}
