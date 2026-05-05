// coord-polar: spec dictionary shape and core projection helpers.

#import "../../src/coord/polar.typ": coord-polar
#import "../../src/utils/polar.typ": (
  polar-ctx, polar-point, polar-r, polar-theta, polar-wedge,
)

#let approx-eq(a, b, eps: 1e-6) = calc.abs(a - b) < eps

#let c = coord-polar()
#assert.eq(c.kind, "coord")
#assert.eq(c.coord, "polar")
#assert.eq(c.theta, "x")
#assert.eq(c.start, 0)
#assert.eq(c.direction, 1)

#let c2 = coord-polar(theta: "y", start: 0.5, direction: -1)
#assert.eq(c2.theta, "y")
#assert.eq(c2.start, 0.5)
#assert.eq(c2.direction, -1)

// Trained continuous scale stub: x in [0, 4], y in [0, 100].
#let cont-trained(domain) = (
  type: "continuous",
  domain: domain,
)

#let xt = cont-trained((0, 4))
#let yt = cont-trained((0, 100))
#let polar = polar-ctx(c, xt, yt, (0, 10), (0, 10))
#assert(polar != none)
#assert.eq(polar.centre, (5, 5))
#assert.eq(polar.r-max, 5)
#assert.eq(polar.theta-axis, "x")
#assert.eq(polar.r-range, (0, 5))

// Cartesian and other coords return `none`.
#assert.eq(polar-ctx(none, xt, yt, (0, 10), (0, 10)), none)
#assert.eq(
  polar-ctx(
    (kind: "coord", coord: "cartesian"),
    xt,
    yt,
    (0, 10),
    (0, 10),
  ),
  none,
)

// theta sweep runs from π/2 (12 o'clock) clockwise back to -3π/2 by default.
#assert(approx-eq(polar.theta-range.at(0), calc.pi / 2))
#assert(approx-eq(polar.theta-range.at(1), calc.pi / 2 - 2 * calc.pi))

// Cardinal angular positions for theta = "x" (x is angular).
// x = 0 → 12 o'clock; x = 1 (quarter sweep) → 3 o'clock; x = 2 → 6 o'clock.
#let p0 = polar-point(0, 50, polar)
#assert(approx-eq(p0.at(0), 5))
#assert(approx-eq(p0.at(1), 5 + 2.5))
#let p-quarter = polar-point(1, 50, polar)
#assert(approx-eq(p-quarter.at(0), 5 + 2.5))
#assert(approx-eq(p-quarter.at(1), 5))
#let p-half = polar-point(2, 50, polar)
#assert(approx-eq(p-half.at(0), 5))
#assert(approx-eq(p-half.at(1), 5 - 2.5))

// theta = "y" swaps which scale is angular vs radial. Pie-style projection:
// y is angular, x is radial. y = 0 → 12 o'clock at full r when x = 4.
#let pie-coord = coord-polar(theta: "y")
#let pie = polar-ctx(pie-coord, xt, yt, (0, 10), (0, 10))
#assert.eq(pie.theta-axis, "y")
#let pie-top = polar-point(4, 0, pie)
#assert(approx-eq(pie-top.at(0), 5))
#assert(approx-eq(pie-top.at(1), 5 + 5))
#let pie-bottom = polar-point(4, 50, pie)
#assert(approx-eq(pie-bottom.at(0), 5))
#assert(approx-eq(pie-bottom.at(1), 5 - 5))

// Wedge vertex count: outer arc has `steps + 1` points; closed at the centre
// when r-lo is 0, so total = steps + 2.
#let wedge = polar-wedge(0, calc.pi / 2, 0, 5, polar, n: 8)
#assert.eq(wedge.len(), 8 + 2)

// Annular wedge: both arcs sampled, total = 2 * (steps + 1).
#let annulus = polar-wedge(0, calc.pi / 2, 2, 5, polar, n: 8)
#assert.eq(annulus.len(), 2 * (8 + 1))

// direction = -1 inverts the sweep: x = 1 (quarter sweep) lands at 9 o'clock.
#let ccw-coord = coord-polar(direction: -1)
#let ccw = polar-ctx(ccw-coord, xt, yt, (0, 10), (0, 10))
#let ccw-quarter = polar-point(1, 50, ccw)
#assert(approx-eq(ccw-quarter.at(0), 5 - 2.5))
#assert(approx-eq(ccw-quarter.at(1), 5))

coord-polar tests passed.
