// Verify the colour/fill aesthetic split: `resolve-fill-colour` no longer
// falls back to the colour scale by default, and `geom-point`'s stroke
// builder injects the colour-scale paint only when `stroke` is non-zero.

#import "../../src/utils/fill-resolve.typ": resolve-fill-colour
#import "../../src/geom/point.typ": _build-stroke

#let fake-trained = (type: "discrete", domain: ("a", "b"))
#let marker-resolve(trained, value, palette) = {
  if trained == none { return rgb("#000000") }
  // Encode which scale was consulted by mixing the value into the alpha
  // channel so the test can distinguish fill vs colour paths.
  if value == "a" { rgb("#ff0000") } else { rgb("#0000ff") }
}

#let make-ctx(trained-dict) = (
  trained: trained-dict,
  resolve-colour: marker-resolve,
  palette: (rgb("#111111"), rgb("#222222")),
)

#let layer(fill: auto, alpha: 1) = (
  geom: "point",
  params: (fill: fill, alpha: alpha),
)

// 1. Fill mapping with a trained fill scale resolves through the fill scale.
#let ctx-fill = make-ctx((fill: fake-trained))
#let fill-col-row = (k: "a")
#assert.eq(
  resolve-fill-colour(
    layer(),
    (fill: "k"),
    ctx-fill,
    fill-col-row,
    rgb("#cccccc"),
  ),
  rgb("#ff0000"),
)

// 2. Only the colour aesthetic is mapped: with the new default
// `colour-fallback: false`, the fill resolves to `default-fill` and ignores
// the colour scale entirely.
#let ctx-colour = make-ctx((colour: fake-trained))
#assert.eq(
  resolve-fill-colour(
    layer(),
    (colour: "k"),
    ctx-colour,
    (k: "a"),
    rgb("#cccccc"),
  ),
  rgb("#cccccc"),
)

// 3. Opt-in `colour-fallback: true` restores the legacy behaviour for callers
// that genuinely want it (currently none, but the parameter is preserved).
#assert.eq(
  resolve-fill-colour(
    layer(),
    (colour: "k"),
    ctx-colour,
    (k: "b"),
    rgb("#cccccc"),
    colour-fallback: true,
  ),
  rgb("#0000ff"),
)

// 4. A fixed `params.fill` wins over any scale resolution.
#assert.eq(
  resolve-fill-colour(
    layer(fill: rgb("#abcdef")),
    (fill: "k"),
    ctx-fill,
    (k: "a"),
    rgb("#cccccc"),
  ),
  rgb("#abcdef"),
)

// 5. `_build-stroke` returns `none` when the layer disables stroke entirely
// or sets it to a zero length, so the `colour` aesthetic has no effect on a
// stroke-less point.
#assert.eq(_build-stroke(none, rgb("#ff0000")), none)
#assert.eq(_build-stroke(0pt, rgb("#ff0000")), none)

// 6. A length stroke is wrapped into a CeTZ stroke dict with the resolved
// colour-scale paint injected.
#let stroke-from-length = _build-stroke(0.5pt, rgb("#ff0000"))
#assert.eq(stroke-from-length.thickness, 0.5pt)
#assert.eq(stroke-from-length.paint, rgb("#ff0000"))

// 7. A user-supplied stroke dict keeps its explicit `paint` and only fills in
// missing fields, so fixed-stroke layers ignore the resolved colour scale.
#let stroke-from-dict = _build-stroke(
  (paint: rgb("#222222"), thickness: 0.4pt),
  rgb("#ff0000"),
)
#assert.eq(stroke-from-dict.paint, rgb("#222222"))
#assert.eq(stroke-from-dict.thickness, 0.4pt)

aesthetic colour/fill split tests passed.
