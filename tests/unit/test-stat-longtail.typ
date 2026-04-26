// stat-ecdf and stat-unique tests.

#import "../../src/stat/apply.typ": apply-stat

// --- stat-ecdf: cumulative fraction per unique x ---

#let df-ecdf = (3, 1, 2, 1).map(v => (x: v))
#let r-ecdf = apply-stat("ecdf", df-ecdf, (x: "x"), (:))

#assert.eq(r-ecdf.data.len(), 3)
#assert.eq(r-ecdf.data.at(0).x, 1.0)
#assert.eq(r-ecdf.data.at(0).y, 1 / 4)
#assert.eq(r-ecdf.data.at(1).x, 2.0)
#assert.eq(r-ecdf.data.at(1).y, 3 / 4)
#assert.eq(r-ecdf.data.at(2).x, 3.0)
#assert.eq(r-ecdf.data.at(2).y, 4 / 4)
#assert.eq(r-ecdf.mapping.x, "x")
#assert.eq(r-ecdf.mapping.y, "y")

// --- stat-ecdf: drops none and unparseable values ---

#let df-mixed = (
  (x: "1"),
  (x: none),
  (x: "abc"),
  (x: 2),
)
#let r-mixed = apply-stat("ecdf", df-mixed, (x: "x"), (:))
#assert.eq(r-mixed.data.len(), 2)
#assert.eq(r-mixed.data.at(0).y, 1 / 2)
#assert.eq(r-mixed.data.at(1).y, 2 / 2)

// --- stat-unique: collapses duplicate (x, y) pairs ---

#let df-unique = (
  (x: 1, y: 1),
  (x: 1, y: 1),
  (x: 2, y: 2),
)
#let r-unique = apply-stat("unique", df-unique, (x: "x", y: "y"), (:))
#assert.eq(r-unique.data.len(), 2)
#assert.eq(r-unique.data.at(0).x, 1)
#assert.eq(r-unique.data.at(0).y, 1)
#assert.eq(r-unique.data.at(1).x, 2)
#assert.eq(r-unique.data.at(1).y, 2)
#assert.eq(r-unique.mapping.x, "x")
#assert.eq(r-unique.mapping.y, "y")

// --- stat-unique: distinct y at same x is kept ---

#let df-distinct = (
  (x: 1, y: 1),
  (x: 1, y: 2),
  (x: 1, y: 1),
)
#let r-distinct = apply-stat("unique", df-distinct, (x: "x", y: "y"), (:))
#assert.eq(r-distinct.data.len(), 2)

Stat longtail tests passed.
