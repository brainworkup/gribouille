// coord-flip: spec dictionary shape and renderer detection.

#import "../../src/coord/flip.typ": coord-flip
#import "../../src/render.typ": _apply-flip, _is-flipped

#let c1 = coord-flip()
#assert.eq(c1.kind, "coord")
#assert.eq(c1.coord, "flip")

// The dict shape must stay stable so the renderer can route the spec into
// the flip swap without touching positional or fixed-aspect coords.
#let keys-c1 = c1.keys().sorted()
#assert.eq(keys-c1, ("coord", "kind"))

// `_is-flipped` recognises the flip coord and rejects everything else.
#assert.eq(_is-flipped(c1), true)
#assert.eq(_is-flipped((kind: "coord", coord: "cartesian")), false)
#assert.eq(_is-flipped((kind: "coord", coord: "fixed", ratio: 1)), false)
#assert.eq(_is-flipped(none), false)

// `_apply-flip` swaps trained.x and trained.y when the coord is flip,
// and is a no-op otherwise.
#let trained = (
  x: (type: "discrete", domain: ("a", "b", "c")),
  y: (type: "continuous", domain: (0, 10)),
)
#let flipped = _apply-flip(trained, c1)
#assert.eq(flipped.x.type, "continuous")
#assert.eq(flipped.x.domain, (0, 10))
#assert.eq(flipped.y.type, "discrete")
#assert.eq(flipped.y.domain, ("a", "b", "c"))

#let untouched = _apply-flip(trained, (kind: "coord", coord: "cartesian"))
#assert.eq(untouched.x.type, "discrete")
#assert.eq(untouched.y.type, "continuous")

coord-flip tests passed.
