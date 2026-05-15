// stat-quantile: linear quantile regression at user-supplied tau.

#import "../../src/stat/quantile.typ": apply, stat-quantile

#let s = stat-quantile()
#assert.eq(s.kind, "stat")
#assert.eq(s.name, "quantile")
#assert.eq(s.params.quantiles, (0.25, 0.5, 0.75))
#assert.eq(s.params.n-samples, 64)

#let s2 = stat-quantile(quantiles: (0.1, 0.9), n-samples: 32)
#assert.eq(s2.params.quantiles, (0.1, 0.9))
#assert.eq(s2.params.n-samples, 32)

// Collinear data y = 2x + 1: every pair fits exactly, loss is zero, the
// algorithm picks the first valid pair. All quantile fits coincide.
#let data = range(0, 5).map(i => (x: i, y: 2 * i + 1))
#let r = apply(
  data,
  (x: "x", y: "y"),
  params: (quantiles: (0.5,), n-samples: 4),
)

#assert.eq(r.mapping.x, "x")
#assert.eq(r.mapping.y, "y")
#assert.eq(r.mapping.group, "group")
// 5 samples (n-samples + 1) for a single tau.
#assert.eq(r.data.len(), 5)

// Endpoints: x=0 → y=1; x=4 → y=9.
#assert.eq(r.data.first().x, 0)
#assert.eq(r.data.first().y, 1)
#assert.eq(r.data.last().x, 4)
#assert.eq(r.data.last().y, 9)

// Group key reflects tau.
#assert.eq(r.data.first().group, "q0.5")
#assert.eq(r.data.first()._quantile, 0.5)

// Three quantiles → three groups → 3 * (n-samples + 1) rows.
#let r3 = apply(
  data,
  (x: "x", y: "y"),
  params: (quantiles: (0.25, 0.5, 0.75), n-samples: 4),
)
#assert.eq(r3.data.len(), 15)

// Shifted-y test: with the median, the line fits y = 2x + 1 exactly.
#let mid = r.data.at(2)
#assert.eq(mid.x, 2)
#assert.eq(mid.y, 5)

// Noisy linear cloud. References from R `quantreg::rq(y ~ x, tau)`:
//   tau = 0.25 -> intercept = 0, slope = 0.98   (line through (0,0)-(5,4.9))
//   tau = 0.50 -> intercept = 0, slope = 1.0    (line through (0,0)-(1,1))
//   tau = 0.75 -> intercept = 0, slope = 1.025  (line through (0,0)-(4,4.1))
#let close-q(a, b) = calc.abs(a - b) < 1e-9
#let noisy = (
  (x: 0, y: 0.0),
  (x: 1, y: 1.0),
  (x: 2, y: 1.8),
  (x: 3, y: 3.2),
  (x: 4, y: 4.1),
  (x: 5, y: 4.9),
  (x: 6, y: 6.0),
)
#let r-noisy = apply(
  noisy,
  (x: "x", y: "y"),
  params: (quantiles: (0.25, 0.5, 0.75), n-samples: 2),
)
// 3 quantiles * (n-samples + 1) rows.
#assert.eq(r-noisy.data.len(), 9)

// Per-tau slope from the first and last sampled points (x = 0 and x = 6).
#let line-of(rows, tau) = {
  let pts = rows.filter(p => p._quantile == tau)
  let lo = pts.first()
  let hi = pts.last()
  let slope = (hi.y - lo.y) / (hi.x - lo.x)
  (intercept: lo.y - slope * lo.x, slope: slope)
}

#let f25 = line-of(r-noisy.data, 0.25)
#assert(close-q(f25.intercept, 0.0))
#assert(close-q(f25.slope, 0.98))

#let f50 = line-of(r-noisy.data, 0.5)
#assert(close-q(f50.intercept, 0.0))
#assert(close-q(f50.slope, 1.0))

#let f75 = line-of(r-noisy.data, 0.75)
#assert(close-q(f75.intercept, 0.0))
#assert(close-q(f75.slope, 1.025))

// Slopes should rise monotonically through the central tau range on a
// roughly linear cloud.
#assert(f25.slope < f50.slope)
#assert(f50.slope < f75.slope)

stat-quantile tests passed.
