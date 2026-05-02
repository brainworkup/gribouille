// Scale expansion helper and renderer plumbing.

#import "../../src/scale/expansion.typ": expansion, normalise-expansion
#import "../../src/scale/train.typ": map-discrete, map-position, train
#import "../../src/scale/continuous.typ": scale-x-continuous
#import "../../src/scale/discrete.typ": scale-x-discrete
#import "../../src/coord/cartesian.typ": coord-cartesian

#let e1 = expansion(mult: 0.05)
#assert.eq(e1.kind, "expansion")
#assert.eq(e1.mult, 0.05)
#assert.eq(e1.add, 0)

#let e2 = expansion(add: 0.6)
#assert.eq(e2.mult, 0)
#assert.eq(e2.add, 0.6)

// Auto resolves to ggplot2 defaults per scale type.
#assert.eq(normalise-expansion(auto, "continuous"), (0.05, 0, 0.05, 0))
#assert.eq(normalise-expansion(auto, "discrete"), (0, 0.6, 0, 0.6))

// expansion() dict normalises.
#assert.eq(
  normalise-expansion(expansion(mult: 0.1, add: 1), "continuous"),
  (0.1, 1, 0.1, 1),
)

// Pair inputs split lo/hi.
#assert.eq(
  normalise-expansion(expansion(mult: (0.0, 0.1)), "continuous"),
  (0.0, 0, 0.1, 0),
)

// 4-tuple shorthand passes through.
#assert.eq(
  normalise-expansion((0.05, 0, 0.1, 0), "continuous"),
  (0.05, 0, 0.1, 0),
)

// false / none collapse to zero.
#assert.eq(normalise-expansion(false, "continuous"), (0, 0, 0, 0))
#assert.eq(normalise-expansion(none, "discrete"), (0, 0, 0, 0))

// Discrete mapping with view-index places level i at integer position i,
// linearly interpolated through the supplied viewport.
#assert.eq(
  map-discrete("a", ("a", "b", "c"), (0.0, 10.0), view-index: (-0.6, 2.6)),
  10.0 * (0 - (-0.6)) / (2.6 - (-0.6)),
)
#assert.eq(
  map-discrete("c", ("a", "b", "c"), (0.0, 10.0), view-index: (-0.6, 2.6)),
  10.0 * (2 - (-0.6)) / (2.6 - (-0.6)),
)

// Without view-index, mapping retains the midpoint behaviour used by
// non-positional discrete scales (colour, fill, shape, ...).
#assert.eq(map-discrete("a", ("a", "b"), (0.0, 10.0)), 2.5)
#assert.eq(map-discrete("b", ("a", "b"), (0.0, 10.0)), 7.5)

// Bar layers anchor y=0 at the axis line. With `geom-col`, `_post-train`
// tags the y trained entry with `anchor-zero: "lo"`, and `_apply-expand`
// collapses the lower-side multiplicative expansion. The y=0 baseline maps
// to the panel bottom, not 4.5% above it.
#import "../../src/render.typ": _apply-expand, _post-train, _prepare-layer
#import "../../src/geom/col.typ": geom-col
#import "../../src/aes.typ": aes
#import "../../src/scale/train.typ": _map-trans

#let bar-data = (
  (cat: "a", y: 3),
  (cat: "b", y: 5),
  (cat: "c", y: 2),
)
#let bar-layers = (geom-col(),)
#let bar-prepared = bar-layers.map(l => _prepare-layer(
  l,
  aes(x: "cat", y: "y"),
  bar-data,
))
#let bar-trained = train(
  layers: bar-prepared,
  mapping: aes(x: "cat", y: "y"),
  data: bar-data,
)
#let bar-trained = _post-train(bar-trained, bar-prepared)
#assert.eq(bar-trained.y.at("anchor-zero", default: none), "lo")

#let bar-trained = _apply-expand(bar-trained, none)
// Lower-side mult collapsed to 0; upper side still gets the 5% default.
#let (vt-lo, vt-hi) = bar-trained.y.view-trans
#assert.eq(vt-lo, 0)
#assert(vt-hi > 5)

// `_map-trans` places y=0 exactly at the start of the panel range.
#assert.eq(_map-trans(bar-trained.y, 0, (0.0, 100.0)), 0.0)

// `geom-col(position: "fill")` anchors both ends: y=0 at the panel bottom
// and y=1 at the panel top, since fill stacks always live in `[0, 1]`.
#let fill-data = (
  (q: "Q1", p: "A", v: 6),
  (q: "Q1", p: "B", v: 4),
  (q: "Q2", p: "A", v: 3),
  (q: "Q2", p: "B", v: 7),
)
#let fill-mapping = aes(x: "q", y: "v", fill: "p")
#let fill-layers = (geom-col(position: "fill"),)
#let fill-prepared = fill-layers.map(l => _prepare-layer(
  l,
  fill-mapping,
  fill-data,
))
#let fill-trained = train(
  layers: fill-prepared,
  mapping: fill-mapping,
  data: fill-data,
)
#let fill-trained = _post-train(fill-trained, fill-prepared)
#assert.eq(fill-trained.y.at("anchor-zero"), "both")

#let fill-trained = _apply-expand(fill-trained, none)
#assert.eq(fill-trained.y.view-trans, (0, 1))

Expansion tests passed.
