// stat-bin: uniform-width histogram bins.

#import "../../src/stat/apply.typ": apply-stat

#let close(a, b, tol: 1e-12) = calc.abs(a - b) < tol

// --- bins parameter on integers 0..19 -------------------------------------
// Gribouille spans the data domain `[lo, hi] = [0, 19]` and splits into the
// requested number of buckets. Reference midpoints from R using the same
// rule:
//   width <- (hi - lo) / bins                           # 4.75
//   mids  <- lo + (seq_len(bins) - 0.5) * width
//          # 2.375, 7.125, 11.875, 16.625
// Counts come from `bin-of(x) = floor((x - lo) / width)` clamped to the last
// bucket; for 0..19 the buckets are 0..4, 5..9, 10..14, 15..19.

#let df = range(0, 20).map(v => (x: v))
#let r = apply-stat("bin", df, (x: "x"), (bins: 4, binwidth: none))

#assert.eq(r.data.len(), 4)
#assert(close(r.data.at(0).x, 2.375))
#assert(close(r.data.at(1).x, 7.125))
#assert(close(r.data.at(2).x, 11.875))
#assert(close(r.data.at(3).x, 16.625))

#for row in r.data {
  assert(close(row.width, 4.75))
  assert.eq(row.y, 5)
}
#assert.eq(r.data.fold(0, (acc, row) => acc + row.y), 20)

#assert.eq(r.mapping.x, "x")
#assert.eq(r.mapping.y, "y")

// --- binwidth parameter ----------------------------------------------------
// `binwidth = 5` and a domain of width 19 => nbins = ceil(19 / 5) = 4 and
// width = 19 / 4 = 4.75 (binwidth is a target, never the final width when it
// would leave a partial bin).

#let r-bw = apply-stat("bin", df, (x: "x"), (binwidth: 5, bins: 30))
#assert.eq(r-bw.data.len(), 4)
#assert(close(r-bw.data.at(0).width, 4.75))
#assert(close(r-bw.data.at(0).x, 2.375))
#assert.eq(r-bw.data.at(0).y, 5)

// --- weighted bin: counts reflect weight, not row count -------------------

#let wdata = (
  (x: 0, w: 1),
  (x: 1, w: 1),
  (x: 2, w: 2),
  (x: 3, w: 1),
  (x: 4, w: 1),
)
#let r-w = apply-stat(
  "bin",
  wdata,
  (x: "x", weight: "w"),
  (bins: 2, binwidth: none),
)
#assert.eq(r-w.data.len(), 2)
#assert(close(r-w.data.at(0).x, 1.0))
#assert(close(r-w.data.at(1).x, 3.0))
#assert.eq(r-w.data.at(0).y, 2)
#assert.eq(r-w.data.at(1).y, 4)

// --- constant data: domain spreads to (lo, lo + 1) -------------------------
// `bin-domain` widens a degenerate range to a unit interval so the histogram
// stays well-defined. All mass lands in the first bucket; subsequent buckets
// stay at zero.

#let const-data = range(0, 5).map(_ => (x: 7))
#let r-const = apply-stat(
  "bin",
  const-data,
  (x: "x"),
  (bins: 3, binwidth: none),
)
#assert.eq(r-const.data.len(), 3)
#assert.eq(r-const.data.at(0).y, 5)
#assert.eq(r-const.data.at(1).y, 0)
#assert.eq(r-const.data.at(2).y, 0)

// --- empty input emits no rows --------------------------------------------

#assert.eq(apply-stat("bin", (), (x: "x"), (bins: 4, binwidth: none)).data, ())

stat-bin tests passed.
