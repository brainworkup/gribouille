// stat-ecdf: empirical cumulative distribution.

#import "../../src/stat/apply.typ": apply-stat

// --- unweighted ECDF on a duplicated sample --------------------------------
// Reference from R: ecdf(x)(unique_sorted_x) on x = c(1,2,2,3,4,4,4,5,6,7).
//   unique_sorted_x = c(1, 2, 3, 4, 5, 6, 7)
//   fractions       = c(0.1, 0.3, 0.4, 0.7, 0.8, 0.9, 1.0)

#let dups = (1, 2, 2, 3, 4, 4, 4, 5, 6, 7).map(v => (x: v))
#let r = apply-stat("ecdf", dups, (x: "x"), (:))

#assert.eq(r.data.len(), 7)
#assert.eq(r.data.at(0), (x: 1, y: 0.1))
#assert.eq(r.data.at(1), (x: 2, y: 0.3))
#assert.eq(r.data.at(2), (x: 3, y: 0.4))
#assert.eq(r.data.at(3), (x: 4, y: 0.7))
#assert.eq(r.data.at(4), (x: 5, y: 0.8))
#assert.eq(r.data.at(5), (x: 6, y: 0.9))
#assert.eq(r.data.at(6), (x: 7, y: 1.0))

// y is monotone non-decreasing; the curve ends at 1.
#let ys = r.data.map(p => p.y)
#for i in range(1, ys.len()) {
  assert(ys.at(i) >= ys.at(i - 1))
}
#assert.eq(ys.last(), 1.0)

#assert.eq(r.mapping.x, "x")
#assert.eq(r.mapping.y, "y")

// --- weighted ECDF ---------------------------------------------------------
// Same x as above; weights double the contribution of every 4. Cumulative
// weight at each unique value is (1, 3, 4, 10, 11, 12, 13); divide by total
// weight 13 to get the reference fractions.

#let close(a, b, tol: 1e-12) = calc.abs(a - b) < tol
#let wdata = (
  (x: 1, w: 1),
  (x: 2, w: 1),
  (x: 2, w: 1),
  (x: 3, w: 1),
  (x: 4, w: 2),
  (x: 4, w: 2),
  (x: 4, w: 2),
  (x: 5, w: 1),
  (x: 6, w: 1),
  (x: 7, w: 1),
)
#let rw = apply-stat("ecdf", wdata, (x: "x", weight: "w"), (:))
#assert.eq(rw.data.len(), 7)
#assert.eq(rw.data.at(0).x, 1)
#assert(close(rw.data.at(0).y, 1 / 13))
#assert(close(rw.data.at(1).y, 3 / 13))
#assert(close(rw.data.at(2).y, 4 / 13))
#assert(close(rw.data.at(3).y, 10 / 13))
#assert(close(rw.data.at(4).y, 11 / 13))
#assert(close(rw.data.at(5).y, 12 / 13))
#assert.eq(rw.data.at(6).y, 1.0)

// --- edge cases ------------------------------------------------------------

// Single observation collapses to one row at fraction 1.
#let r1 = apply-stat("ecdf", ((x: 42),), (x: "x"), (:))
#assert.eq(r1.data, ((x: 42, y: 1.0),))

// Empty input emits no rows.
#assert.eq(apply-stat("ecdf", (), (x: "x"), (:)).data, ())

// All-zero weight (no positive mass) emits no rows.
#let zero = (1, 2, 3).map(v => (x: v, w: 0))
#assert.eq(apply-stat("ecdf", zero, (x: "x", weight: "w"), (:)).data, ())

// Non-numeric x is dropped.
#let mixed = ((x: 1), (x: "no"), (x: 2), (x: none))
#let rmixed = apply-stat("ecdf", mixed, (x: "x"), (:))
#assert.eq(rmixed.data.len(), 2)
#assert.eq(rmixed.data.at(0).y, 0.5)
#assert.eq(rmixed.data.at(1).y, 1.0)

stat-ecdf tests passed.
