// stat-ecdf and stat-unique tests.

#import "../../src/stat/apply.typ": apply-stat, setup-stat

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

// --- stat-ecdf: preserves grouping aesthetics in output mapping ---

#let df-ecdf-grp = (1, 2, 3).map(v => (x: v, g: "a"))
#let r-ecdf-grp = apply-stat("ecdf", df-ecdf-grp, (x: "x", colour: "g"), (:))
#assert.eq(r-ecdf-grp.mapping.colour, "g")

// --- setup-stat shares a panel-wide bin grid across per-group apply calls ---
//
// Two groups with disjoint x-ranges would land on different per-group grids
// without setup; the panel-level grid forces both to share `(lo, n-bins,
// width)` so stacking can align by x.
#let df-panel = (
  (x: 0, g: "a"),
  (x: 1, g: "a"),
  (x: 2, g: "a"),
  (x: 8, g: "b"),
  (x: 9, g: "b"),
  (x: 10, g: "b"),
)
#let panel-mapping = (x: "x", fill: "g")
#let panel-params = setup-stat(
  "bin",
  df-panel,
  panel-mapping,
  (bins: 5),
)
#assert.eq(panel-params.grid.lo, 0.0)
#assert.eq(panel-params.grid.n-bins, 5)
#assert.eq(panel-params.grid.width, 2.0)

// Per-group applies now reuse the shared grid: midpoints align across groups.
#let group-a = df-panel.filter(r => r.g == "a")
#let group-b = df-panel.filter(r => r.g == "b")
#let r-a = apply-stat("bin", group-a, panel-mapping, panel-params)
#let r-b = apply-stat("bin", group-b, panel-mapping, panel-params)
#assert.eq(r-a.data.len(), 5)
#assert.eq(r-b.data.len(), 5)
#assert.eq(r-a.data.at(0).x, r-b.data.at(0).x)
#assert.eq(r-a.data.at(0).width, r-b.data.at(0).width)

Stat longtail tests passed.
