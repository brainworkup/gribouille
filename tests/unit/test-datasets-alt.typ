// Bundled datasets carry the documented schema and `plot()` propagates
// the alt parameter through the spec so `get-alt-text` can recover it.

#import "../../src/datasets/economics.typ": economics
#import "../../src/datasets/mpg.typ": mpg
#import "../../src/plot.typ": get-alt-text, plot
#import "../../src/aes.typ": aes
#import "../../src/geom/point.typ": geom-point

#assert.eq(economics.len(), 24)
#let first-econ = economics.at(0)
#assert.eq(first-econ.date, "2008-01-01")
#assert(first-econ.keys().contains("pce"))
#assert(first-econ.keys().contains("pop"))
#assert(first-econ.keys().contains("psavert"))
#assert(first-econ.keys().contains("uempmed"))
#assert(first-econ.keys().contains("unemploy"))

#assert.eq(mpg.len(), 30)
#let first-mpg = mpg.at(0)
#assert(first-mpg.keys().contains("manufacturer"))
#assert(first-mpg.keys().contains("model"))
#assert(first-mpg.keys().contains("displ"))
#assert(first-mpg.keys().contains("cyl"))
#assert(first-mpg.keys().contains("class"))
#assert(first-mpg.keys().contains("cty"))
#assert(first-mpg.keys().contains("hwy"))

// `plot()` returns rendered content, so exercise the spec contract via
// the accessor on a hand-built spec dict mirroring what `plot()` stores.
#let spec-with-alt = (
  data: mpg,
  mapping: aes(x: "displ", y: "hwy"),
  layers: (geom-point(),),
  alt: "An example plot",
)
#assert.eq(get-alt-text(spec-with-alt), "An example plot")

#let spec-without-alt = (
  data: mpg,
  mapping: aes(x: "displ", y: "hwy"),
  layers: (geom-point(),),
)
#assert.eq(get-alt-text(spec-without-alt), none)

// `plot()` accepts the alt parameter and renders without error.
#let _figure = plot(
  data: mpg,
  mapping: aes(x: "displ", y: "hwy"),
  layers: (geom-point(size: 2pt),),
  alt: "An example plot",
  width: 6cm,
  height: 4cm,
)

Datasets and alt-text tests passed.
