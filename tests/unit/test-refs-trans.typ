// Reference-line geoms route through `map-axis`, so a stub trained dict
// with `transform: "log10"` warps the position the same way axes do.

#import "../../src/scale/train.typ": map-axis

#let log-trained = (
  type: "continuous",
  domain: (1.0, 1000.0),
  spec: none,
  transform: "log10",
)
#let log-pos = map-axis(log-trained, 100, (0.0, 100.0))
#assert(calc.abs(log-pos - 200.0 / 3.0) < 1e-9)

#let id-trained = (
  type: "continuous",
  domain: (1.0, 1000.0),
  spec: none,
  transform: "identity",
)
#let id-pos = map-axis(id-trained, 100, (0.0, 100.0))
#assert(calc.abs(id-pos - 99.0 * 100.0 / 999.0) < 1e-9)

Refs transform tests passed.
