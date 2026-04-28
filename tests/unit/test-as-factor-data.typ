// Two-arg `as-factor(data, col)` should mark the column as discrete so a
// later `aes(x: col)` (with no inline annotation) still trains a discrete
// scale, mirroring the inline `as-factor(col)` form.

#import "../../src/data.typ": as-factor
#import "../../src/scale/train.typ": train
#import "../../src/geom/col.typ": geom-col
#import "../../src/aes.typ": aes

#let raw = (
  (sp: 1, y: 5.1),
  (sp: 2, y: 7.0),
  (sp: 3, y: 6.3),
)

#let d = as-factor(raw, "sp")

// Each row carries a `_gribouille-factors` array listing every column the
// helper has stringified.
#assert.eq(d.at(0).at("_gribouille-factors"), ("sp",))
#assert.eq(type(d.at(0).sp), str)

// Calling `as-factor` twice on the same column is idempotent: the sentinel
// does not accumulate duplicate entries.
#let d2 = as-factor(d, "sp")
#assert.eq(d2.at(0).at("_gribouille-factors"), ("sp",))

// train() picks up the sentinel and forces the x scale to discrete even
// though the values stringify to digits matching the numeric regex.
#let trained = train(
  layers: (geom-col(),),
  mapping: aes(x: "sp", y: "y"),
  data: d,
)
#assert.eq(trained.x.type, "discrete")
#assert.eq(trained.x.domain, ("1", "2", "3"))

// Other columns on the same data are unaffected by the sentinel.
#assert.eq(trained.y.type, "continuous")

as-factor data sentinel tests passed.
