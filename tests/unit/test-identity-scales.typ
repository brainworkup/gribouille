// Identity scale specs and training.

#import "../../src/scale/colour.typ": scale-colour-identity, scale-fill-identity
#import "../../src/scale/shape.typ": scale-shape-identity
#import "../../src/scale/linetype.typ": scale-linetype-identity
#import "../../src/scale/train.typ": train

// --- spec dicts carry type "identity" and the right aesthetic ---

#let s-colour = scale-colour-identity()
#assert.eq(s-colour.kind, "scale")
#assert.eq(s-colour.aesthetic, "colour")
#assert.eq(s-colour.type, "identity")

#let s-fill = scale-fill-identity()
#assert.eq(s-fill.aesthetic, "fill")
#assert.eq(s-fill.type, "identity")

#let s-shape = scale-shape-identity()
#assert.eq(s-shape.aesthetic, "shape")
#assert.eq(s-shape.type, "identity")

#let s-linetype = scale-linetype-identity()
#assert.eq(s-linetype.aesthetic, "linetype")
#assert.eq(s-linetype.type, "identity")

// --- train() returns identity scales without computing a domain ---

#let layers = (
  (
    geom: "point",
    mapping: (x: "x", y: "y", colour: "c"),
    data: (
      (x: 0, y: 0, c: "#1b9e77"),
      (x: 1, y: 1, c: "#d95f02"),
    ),
    inherit-aes: true,
  ),
)
#let trained = train(
  scales: (scale-colour-identity(),),
  layers: layers,
  mapping: (x: "x", y: "y", colour: "c"),
  data: none,
)
#assert.eq(trained.colour.type, "identity")
#assert.eq(trained.colour.domain, ())

Identity scales tests passed.
