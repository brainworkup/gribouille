// stat-ellipse: per-group covariance ellipse from a 2D point cloud.

#import "../../src/stat/apply.typ": apply-stat
#import "../../src/stat/ellipse.typ": stat-ellipse

#let assert-close(a, b, tol: 1e-6) = {
  assert(
    calc.abs(a - b) < tol,
    message: "expected " + repr(a) + " ~= " + repr(b),
  )
}

// Constructor returns a stat dict with the documented defaults.
#let s = stat-ellipse()
#assert.eq(s.kind, "stat")
#assert.eq(s.name, "ellipse")
#assert.eq(s.params.level, 0.95)
#assert.eq(stat-ellipse(level: 0.5).params.level, 0.5)

// Single-group axis-aligned point cloud: covariance is diagonal so the
// ellipse rotation collapses to zero. The exact axes follow from
// chi-square(2 df) for the requested level: -2 * ln(1 - level).
#let df-axes = (
  (x: -2, y: -1),
  (x: 2, y: -1),
  (x: -2, y: 1),
  (x: 2, y: 1),
  (x: 0, y: 0),
)
// Variance of x = (4 + 4 + 4 + 4 + 0) / 4 = 4. Variance of y = (1+1+1+1) / 4 = 1.
#let r-axes = apply-stat(
  "ellipse",
  df-axes,
  (x: "x", y: "y"),
  (level: 0.95),
)
#assert.eq(r-axes.data.len(), 1)
#let row = r-axes.data.at(0)
#assert.eq(row.x0, 0)
#assert.eq(row.y0, 0)
// Off-diagonal covariance is zero, so a points along x; angle is 0.
#assert.eq(row.angle, 0.0)
#let chi95 = -2 * calc.ln(0.05)
#assert-close(row.a, calc.sqrt(4 * chi95))
#assert-close(row.b, calc.sqrt(1 * chi95))

// Two clusters split by `fill`: each emits its own ellipse, in input order.
#let df-two = (
  (x: 0, y: 0, k: "a"),
  (x: 2, y: 0, k: "a"),
  (x: 0, y: 2, k: "a"),
  (x: 2, y: 2, k: "a"),
  (x: 5, y: 5, k: "b"),
  (x: 7, y: 5, k: "b"),
  (x: 5, y: 7, k: "b"),
  (x: 7, y: 7, k: "b"),
)
#let r-two = apply-stat(
  "ellipse",
  df-two,
  (x: "x", y: "y", fill: "k"),
  (level: 0.95),
)
#assert.eq(r-two.data.len(), 2)
#assert.eq(r-two.data.at(0).x0, 1)
#assert.eq(r-two.data.at(0).y0, 1)
#assert.eq(r-two.data.at(1).x0, 6)
#assert.eq(r-two.data.at(1).y0, 6)
#assert.eq(r-two.data.at(0).k, "a")
#assert.eq(r-two.data.at(1).k, "b")

// Single-row group is dropped (need at least 2 points for a covariance).
#let r-thin = apply-stat(
  "ellipse",
  ((x: 1, y: 2, g: "x"),),
  (x: "x", y: "y", group: "g"),
  (level: 0.95),
)
#assert.eq(r-thin.data.len(), 0)

stat-ellipse tests passed.
