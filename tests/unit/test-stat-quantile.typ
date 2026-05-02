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
#assert.eq(r.data.first().quantile, 0.5)

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

stat-quantile tests passed.
