// Q-Q statistic and helper tests.

#import "../../src/utils/normal.typ": qnorm
#import "../../src/stat/apply.typ": apply-stat

// --- qnorm: classic 95 % quantile -----------------------------------------
// Acklam's approximation matches the standard z to about 1.15e-9.
#assert(calc.abs(qnorm(0.975) - 1.959964) < 1e-5)
#assert(calc.abs(qnorm(0.025) + 1.959964) < 1e-5)
#assert(calc.abs(qnorm(0.5)) < 1e-9)
#assert(calc.abs(qnorm(0.75) - 0.6744898) < 1e-5)

// --- stat-qq: 5 sorted rows with theoretical at (i + 0.5) / n -------------

#let df = (5, 3, 1, 4, 2).map(v => (v: v))
#let r = apply-stat("qq", df, (y: "v"), (:))

#assert.eq(r.data.len(), 5)
#assert.eq(r.mapping.x, "theoretical")
#assert.eq(r.mapping.y, "sample")

// Sample is sorted ascending.
#let samples = r.data.map(row => row.sample)
#assert.eq(samples, (1.0, 2.0, 3.0, 4.0, 5.0))

// Theoretical quantiles match qnorm at the plotting positions.
#let expected-ps = (0.1, 0.3, 0.5, 0.7, 0.9)
#for (i, p) in expected-ps.enumerate() {
  assert(calc.abs(r.data.at(i).theoretical - qnorm(p)) < 1e-9)
}

// --- stat-qq: falls back to y when sample is not mapped -------------------

#let r-y = apply-stat("qq", df, (y: "v"), (:))
#assert.eq(r-y.data.len(), 5)

// --- stat-qq: drops non-numeric and none values ---------------------------

#let df-mixed = (
  (v: 1),
  (v: none),
  (v: "oops"),
  (v: 2),
)
#let r-mixed = apply-stat("qq", df-mixed, (y: "v"), (:))
#assert.eq(r-mixed.data.len(), 2)

// --- stat-qq-line: two endpoints with intercept zero on (1..5) ------------
// On (1..5) sorted, q1 = 2, q3 = 4, so slope = 2 / (qnorm(0.75) - qnorm(0.25))
// and intercept = 2 - slope * qnorm(0.25) = 3.

#let r-line = apply-stat("qq-line", df, (y: "v"), (:))
#assert.eq(r-line.data.len(), 2)
#assert.eq(r-line.mapping.x, "theoretical")
#assert.eq(r-line.mapping.y, "sample")

#let slope = 2.0 / (qnorm(0.75) - qnorm(0.25))
#let intercept = 2.0 - slope * qnorm(0.25)
#assert(calc.abs(intercept - 3.0) < 1e-9)

#let t-lo = qnorm(0.5 / 5)
#let t-hi = qnorm(4.5 / 5)
#assert(calc.abs(r-line.data.at(0).theoretical - t-lo) < 1e-9)
#assert(calc.abs(r-line.data.at(1).theoretical - t-hi) < 1e-9)
#assert(calc.abs(r-line.data.at(0).sample - (intercept + slope * t-lo)) < 1e-9)
#assert(calc.abs(r-line.data.at(1).sample - (intercept + slope * t-hi)) < 1e-9)

QQ tests passed.
