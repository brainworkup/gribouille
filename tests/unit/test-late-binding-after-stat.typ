// Slice 2: late-binding markers must round-trip through the mapping
// pipeline without being stripped or evaluated. `after-stat` evaluation
// itself lands in slice 3; here we only verify the marker survives
// `_merge-mapping`, `_strip-mapping-refs`, and scale training.

#import "../../src/utils/late-binding.typ": (
  after-stat, from-theme, is-late-binding, late-binding-kind,
)
#import "../../src/utils/aes-resolve.typ": aes-col, late-binding-of
#import "../../src/aes.typ": aes
#import "../../src/render.typ": _merge-mapping, _strip-mapping-refs
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

// --- aes() round-trip ---------------------------------------------------

#let mapping = aes(x: "x", y: after-stat("count"), fill: "sp")
#assert.eq(mapping.y.kind, "after-stat")
#assert.eq(mapping.y.expr, "count")

// --- merge preserves the marker ----------------------------------------

#let layer = (
  geom: "bar",
  mapping: aes(y: after-stat("count")),
  data: none,
  inherit-aes: true,
)
#let merged = _merge-mapping(layer, aes(x: "x", fill: "sp"))
#assert.eq(merged.y.kind, "after-stat")
#assert.eq(merged.x, "x")
#assert.eq(merged.fill, "sp")

// --- strip leaves the marker untouched ---------------------------------

#let stripped = _strip-mapping-refs(merged)
#assert.eq(stripped.y.kind, "after-stat")
#assert.eq(stripped.x, "x")

// --- aes-col reports `none` for markers --------------------------------

#assert.eq(aes-col(after-stat("count")), none)
#assert.eq(aes-col(from-theme("ink")), none)
#assert.eq(aes-col("col"), "col")

// --- late-binding-of returns the marker --------------------------------

#assert.eq(late-binding-of(after-stat("count")).kind, "after-stat")
#assert.eq(late-binding-of("col"), none)

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
