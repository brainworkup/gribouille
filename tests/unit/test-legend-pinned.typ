// Verify guide suppression and key-kind selection when one or more layers
// pin the colour/fill aesthetic locally. A pinned layer must not contribute
// to the aesthetic's guide; if every contributing layer is pinned, the guide
// is suppressed entirely.

#import "../../src/legend.typ": guides-for

#let trained = (
  colour: (type: "discrete", domain: ("a", "b")),
  fill: (type: "discrete", domain: ("a", "b")),
)

#let mk-spec(layers) = (
  mapping: (colour: "k", fill: "k"),
  layers: layers,
  guides: (:),
)

#let layer-point(colour: auto, fill: auto) = (
  geom: "point",
  mapping: none,
  inherit-aes: true,
  params: (colour: colour, fill: fill),
)

#let layer-line(colour: auto) = (
  geom: "line",
  mapping: none,
  inherit-aes: true,
  params: (colour: colour),
)

// 1. No pin: both colour and fill guides are emitted, swatch reflects the
// highest-priority contributor (`point` for both).
#let g1 = guides-for(mk-spec((layer-point(),)), trained)
#assert.eq(g1.len(), 2)
#assert.eq(g1.at(0).aesthetic, "colour")
#assert.eq(g1.at(0).key, "point")
#assert.eq(g1.at(1).aesthetic, "fill")
#assert.eq(g1.at(1).key, "point")

// 2. Single layer pins `colour`: the colour guide is suppressed because no
// layer is left contributing to it. The fill guide stays.
#let g2 = guides-for(
  mk-spec((layer-point(colour: rgb("#ffffff")),)),
  trained,
)
#assert.eq(g2.len(), 1)
#assert.eq(g2.at(0).aesthetic, "fill")

// 3. Mixed pinned/unpinned: a pinned point coexists with an unpinned line.
// The colour guide is emitted and its key reflects the only contributor
// (the `line` geom). Fill is unaffected because line does not consume fill.
#let g3 = guides-for(
  mk-spec((layer-point(colour: rgb("#ffffff")), layer-line())),
  trained,
)
#assert.eq(g3.len(), 2)
#assert.eq(g3.at(0).aesthetic, "colour")
#assert.eq(g3.at(0).key, "line")
#assert.eq(g3.at(1).aesthetic, "fill")
#assert.eq(g3.at(1).key, "point")

// 4. Both colour and fill pinned on the only layer: both guides suppressed.
#let g4 = guides-for(
  mk-spec((layer-point(colour: rgb("#000000"), fill: rgb("#ffffff")),)),
  trained,
)
#assert.eq(g4.len(), 0)

Pinned-layer legend tests passed.
