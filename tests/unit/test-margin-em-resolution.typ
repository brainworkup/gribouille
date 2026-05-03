// length-to-cm and resolve-margin-side-cm convert user-supplied lengths to
// cm, resolving em components against the surface font size in pt.

#import "../../src/utils/margin.typ": (
  length-to-cm, resolve-margin-side, resolve-margin-side-cm,
)

#let approx-eq(a, b, tol: 1e-9) = {
  let diff = a - b
  if diff < 0 { diff = -diff }
  assert(diff < tol, message: "expected " + repr(a) + " ~= " + repr(b))
}

#let pt-cm(n) = (n * 1pt) / 1cm

// Absolute lengths convert directly to cm.
#approx-eq(length-to-cm(0.4cm, 9), 0.4)
#approx-eq(length-to-cm(2pt, 9), pt-cm(2))

// em components use the surface font size in pt.
#approx-eq(length-to-cm(1em, 9), pt-cm(9))
#approx-eq(length-to-cm(1.25em, 9), pt-cm(1.25 * 9))
#approx-eq(length-to-cm(0.5em + 2pt, 9), pt-cm(0.5 * 9) + pt-cm(2))

// resolve-margin-side-cm uses the value when it is a length.
#approx-eq(
  resolve-margin-side-cm(1.5em, 1.25em, size-pt: 10),
  pt-cm(1.5 * 10),
)

// auto falls through to the fallback length, resolved against the same size.
#approx-eq(resolve-margin-side-cm(auto, 1.25em, size-pt: 9), pt-cm(1.25 * 9))
#approx-eq(resolve-margin-side-cm(auto, 0.4cm, size-pt: 9), 0.4)

// none also falls through.
#approx-eq(resolve-margin-side-cm(none, 0.4cm, size-pt: 9), 0.4)

// resolve-margin-side keeps non-em behaviour for the plot-margin pathway.
#assert.eq(resolve-margin-side(auto, 0.5), 0.5)
#approx-eq(resolve-margin-side(2cm, 0.5), 2.0)

length-to-cm and resolve-margin-side-cm smoke test passed.
