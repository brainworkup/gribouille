// stat-smooth: weighted OLS slope/intercept and prediction-band SE.

#import "../../src/stat/smooth.typ": apply

#let close(a, b, tol: 1e-6) = calc.abs(a - b) < tol

// Reference values from R for the 7-point cloud below.
//   fit  <- lm(y ~ x)
//   pr   <- predict(fit, newdata = data.frame(x = c(0, 3, 6)), se.fit = TRUE)
//   coef(fit)   # intercept = 0.06071428571428589, slope = 0.9892857142857144
//   pr$fit      # 0.0607143, 3.0285714, 5.9964286
//   pr$se.fit   # 0.08123724, 0.04506232, 0.08123724
// Gribouille reproduces predict.lm's variance form
//   sigma^2 * (1/n + (x - xbar)^2 / sxx)   (and 1/sum(w) when weighted).

#let unweighted = (
  (x: 0, y: 0.1),
  (x: 1, y: 1.0),
  (x: 2, y: 1.9),
  (x: 3, y: 3.2),
  (x: 4, y: 4.1),
  (x: 5, y: 4.9),
  (x: 6, y: 6.0),
)

#let r-uw = apply(unweighted, (x: "x", y: "y"))
// 80 steps + 1 = 81 sampled points per group.
#assert.eq(r-uw.data.len(), 81)

// Sampled rows at i = 0, 40, 80 land exactly on x = 0, 3, 6.
#let row0 = r-uw.data.at(0)
#let row40 = r-uw.data.at(40)
#let row80 = r-uw.data.at(80)
#assert(close(row0.x, 0.0, tol: 1e-12))
#assert(close(row40.x, 3.0, tol: 1e-12))
#assert(close(row80.x, 6.0, tol: 1e-12))

// Fitted y matches predict.lm.
#assert(close(row0.y, 0.06071428571428589))
#assert(close(row40.y, 3.0285714285714285))
#assert(close(row80.y, 5.996428571428572))

// Half-width = 1.96 * se.fit; full band = 2 * 1.96 * se.fit.
#let half0 = (row0.ymax - row0.ymin) / 2
#let half40 = (row40.ymax - row40.ymin) / 2
#let half80 = (row80.ymax - row80.ymin) / 2
#assert(close(half0, 1.96 * 0.08123724389661657, tol: 1e-4))
#assert(close(half40, 1.96 * 0.04506231513025002, tol: 1e-4))
#assert(close(half80, 1.96 * 0.08123724389661657, tol: 1e-4))

// SE is minimal at the data centroid x = 3 (smile shape).
#assert(half40 < half0)
#assert(half40 < half80)

// --- weighted variant ------------------------------------------------------
// Reference from `lm(y ~ x, weights = w)` and `predict.lm(..., se.fit = TRUE)`
// with w = (3, 1, 1, 1, 1, 1, 3):
//   coef(fit)   # intercept = 0.07855113636363495, slope = 0.9859375
//   pr$fit      # 0.0785511, 3.0363636, 5.9941761
//   pr$se.fit   # 0.05806081, 0.03638139, 0.05806081
// Gribouille's formula uses 1/sum(w), which matches predict.lm's output.

#let weighted = (
  (x: 0, y: 0.1, w: 3),
  (x: 1, y: 1.0, w: 1),
  (x: 2, y: 1.9, w: 1),
  (x: 3, y: 3.2, w: 1),
  (x: 4, y: 4.1, w: 1),
  (x: 5, y: 4.9, w: 1),
  (x: 6, y: 6.0, w: 3),
)
#let r-w = apply(weighted, (x: "x", y: "y", weight: "w"))
#assert.eq(r-w.data.len(), 81)
#let w0 = r-w.data.at(0)
#let w40 = r-w.data.at(40)
#let w80 = r-w.data.at(80)
#assert(close(w0.y, 0.07855113636363495))
#assert(close(w40.y, 3.0363636363636362))
#assert(close(w80.y, 5.994176136363636))

#let half-w0 = (w0.ymax - w0.ymin) / 2
#let half-w40 = (w40.ymax - w40.ymin) / 2
#let half-w80 = (w80.ymax - w80.ymin) / 2
#assert(close(half-w0, 1.96 * 0.05806080805121420, tol: 1e-4))
#assert(close(half-w40, 1.96 * 0.03638138771268675, tol: 1e-4))
#assert(close(half-w80, 1.96 * 0.05806080805121420, tol: 1e-4))

// --- edge cases ------------------------------------------------------------

// Fewer than two points: no rows emitted.
#assert.eq(apply(((x: 0, y: 1),), (x: "x", y: "y")).data.len(), 0)

// Constant x: zero variance in x makes sxx == 0; group dropped.
#let flat = range(0, 5).map(_ => (x: 1, y: 2))
#assert.eq(apply(flat, (x: "x", y: "y")).data.len(), 0)

// Zero-weight rows are excluded; if everything is zero-weighted, no rows.
#let zero-w = unweighted.map(r => (x: r.x, y: r.y, w: 0))
#assert.eq(apply(zero-w, (x: "x", y: "y", weight: "w")).data.len(), 0)

// se: false collapses the band to zero half-width.
#let r-no-se = apply(unweighted, (x: "x", y: "y"), params: (se: false))
#assert.eq(r-no-se.data.at(0).ymin, r-no-se.data.at(0).y)
#assert.eq(r-no-se.data.at(0).ymax, r-no-se.data.at(0).y)

stat-smooth tests passed.
