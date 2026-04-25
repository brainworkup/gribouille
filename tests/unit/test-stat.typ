// Statistical transformation tests.

#import "../../src/stat/apply.typ": apply-stat

// --- stat-count: single group (no fill/colour) ---

#let df-simple = (
  (cat: "a"),
  (cat: "b"),
  (cat: "a"),
  (cat: "c"),
  (cat: "a"),
)
#let m-simple = (x: "cat")

#let r-simple = apply-stat("count", df-simple, m-simple, (:))

// Output uses original column name, not "x".
#assert.eq(r-simple.data.at(0).at("cat"), "a")
#assert.eq(r-simple.data.at(0).at("_count"), 3)
#assert.eq(r-simple.data.at(1).at("cat"), "b")
#assert.eq(r-simple.data.at(1).at("_count"), 1)
#assert.eq(r-simple.data.at(2).at("cat"), "c")
#assert.eq(r-simple.data.at(2).at("_count"), 1)

// Mapping: x unchanged, y → "_count".
#assert.eq(r-simple.mapping.x, "cat")
#assert.eq(r-simple.mapping.y, "_count")

// --- stat-count: order preserved (first-appearance) ---

#let df-order = (
  (v: "b"),
  (v: "a"),
  (v: "b"),
  (v: "c"),
)
#let r-order = apply-stat("count", df-order, (x: "v"), (:))
#assert.eq(r-order.data.at(0).at("v"), "b")
#assert.eq(r-order.data.at(1).at("v"), "a")
#assert.eq(r-order.data.at(2).at("v"), "c")

// --- stat-count: none and empty-string values are skipped ---

#let df-nones = (
  (v: "a"),
  (v: none),
  (v: ""),
  (v: "a"),
)
#let r-nones = apply-stat("count", df-nones, (x: "v"), (:))
#assert.eq(r-nones.data.len(), 1)
#assert.eq(r-nones.data.at(0).at("_count"), 2)

Stat tests passed.
