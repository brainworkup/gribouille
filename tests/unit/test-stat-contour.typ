// Marching-squares iso-line extraction. `stat-contour` reshapes a long
// `(x, y, z)` table into a regular grid and emits one segment per cell-edge
// crossing per level.

#import "../../src/aes.typ": aes
#import "../../src/stat/contour.typ": apply, stat-contour
#import "../../src/utils/marching-squares.typ": isolines

#let s = stat-contour(bins: 4)
#assert.eq(s.kind, "stat")
#assert.eq(s.name, "contour")
#assert.eq(s.params.bins, 4)

// --- isolines on a 2x2 grid (one cell) ---

// z(x, y) = x + y, level 1 cuts the diagonal of the unit cell.
#let segs = isolines((0.0, 1.0), (0.0, 1.0), ((0.0, 1.0), (1.0, 2.0)), 1.0)
#assert.eq(segs.len(), 1)
#let p0 = segs.at(0).at(0)
#let p1 = segs.at(0).at(1)
// Case 4 (NE only): segment runs T -> R. T crosses where x + 1 = 1 -> x = 0
// (so p0 = (0, 1)); R crosses where 1 + y = 1 -> y = 0 (so p1 = (1, 0)).
#assert.eq(p0, (0.0, 1.0))
#assert.eq(p1, (1.0, 0.0))

// --- empty grid ---

#assert.eq(isolines((0.0,), (0.0,), ((0.0,),), 0.5), ())

// --- saddle case 5 with centre below: connects L+B and T+R ---

// 2x2 cell with NE+SW above and NW+SE below.
//   NW=0, NE=2
//   SW=2, SE=0
// centre = 1, level = 1.5 -> centre below level, case 5.
#let saddle = isolines(
  (0.0, 1.0),
  (0.0, 1.0),
  ((2.0, 0.0), (0.0, 2.0)),
  1.5,
)
#assert.eq(saddle.len(), 2)

// --- apply() round-trips a 3x3 grid ---

#let raw = ()
#for i in range(3) {
  for j in range(3) {
    raw.push((x: i, y: j, z: i + j))
  }
}
#let r = apply(
  raw,
  aes(x: "x", y: "y", z: "z"),
  params: (bins: 2, binwidth: none, breaks: auto),
)
#assert.eq(r.mapping.x, "x")
#assert.eq(r.mapping.group, "group")
#assert(r.data.len() > 0)
// Every emitted row carries a `_level` and a `group`.
#assert("_level" in r.data.first())
#assert("group" in r.data.first())
// Rows come in pairs (one segment = two rows sharing a group).
#let groups = r.data.map(row => row.group)
#assert.eq(calc.rem(groups.len(), 2), 0)

// --- explicit breaks override bins ---

#let r-breaks = apply(
  raw,
  aes(x: "x", y: "y", z: "z"),
  params: (bins: 99, binwidth: none, breaks: (1.5, 2.5)),
)
#let levels = r-breaks.data.map(row => row._level).dedup().sorted()
#assert.eq(levels, (1.5, 2.5))

// --- missing z aesthetic returns nothing ---

#let r-noz = apply(
  raw,
  aes(x: "x", y: "y"),
  params: (bins: 2, binwidth: none, breaks: auto),
)
#assert.eq(r-noz.data, ())

stat-contour tests passed.
