// Late-binding markers (`after-stat`, ...) round-trip through the
// mapping pipeline without being stripped or evaluated, and `train()`
// skips the channels they cover.

#import "../../src/utils/late-binding.typ": (
  after-stat, is-late-binding, late-binding-kind,
)
#import "../../src/utils/aes-resolve.typ": aes-col, merge-mapping
#import "../../src/aes.typ": aes
#import "../../src/render.typ": _strip-mapping-refs
#import "../../src/scale/train.typ": train

// --- constructor + predicates ------------------------------------------

#let m = after-stat("count")
#assert.eq(m.kind, "after-stat")
#assert.eq(m.expr, "count")
#assert(is-late-binding(m))
#assert.eq(late-binding-kind(m), "after-stat")

#let m-fn = after-stat((row, ctx) => row.count * 2)
#assert.eq(m-fn.kind, "after-stat")
#assert.eq(type(m-fn.expr), function)

// --- merge preserves the marker ----------------------------------------

#let layer = (
  geom: "bar",
  mapping: aes(y: after-stat("count")),
  data: none,
  inherit-aes: true,
)
#let merged = merge-mapping(layer, aes(x: "x", fill: "sp"))
#assert.eq(merged.y.kind, "after-stat")
#assert.eq(merged.x, "x")
#assert.eq(merged.fill, "sp")

// --- strip leaves the marker untouched ---------------------------------

#let stripped = _strip-mapping-refs(merged)
#assert.eq(stripped.y.kind, "after-stat")
#assert.eq(stripped.x, "x")

// --- aes-col reports `none` for markers --------------------------------

#assert.eq(aes-col(after-stat("count")), none)
#assert.eq(aes-col("col"), "col")

// --- train skips late-bound aesthetics without crashing ----------------

#let layers = (
  (
    geom: "bar",
    mapping: aes(x: "x", y: after-stat("count")),
    data: ((x: 1), (x: 2), (x: 3)),
    inherit-aes: true,
  ),
)
#let trained = train(
  scales: (),
  layers: layers,
  mapping: aes(x: "x", y: after-stat("count")),
  data: none,
)
#assert("x" in trained)
#assert(not ("y" in trained))

late-binding after-stat tests passed.
