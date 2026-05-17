// Pure-data tests for the connector routing helpers used by text/label/typst
// geoms when `segment: true`.

#import "../../src/utils/segment-route.typ": (
  aabb-from-centre, project-onto-edge, route-segment, segment-crosses,
)

// AABB sanity: a unit-square box centred at the origin with padding 0.1 has
// edges at +/- 0.6.
#let box = aabb-from-centre((0, 0), 1, 1, pad: 0.1)
#assert.eq(box.x-lo, -0.6)
#assert.eq(box.x-hi, 0.6)
#assert.eq(box.y-lo, -0.6)
#assert.eq(box.y-hi, 0.6)

// project-onto-edge clips an anchor-to-centre ray at the box boundary.
#let edge = project-onto-edge((-2, 0), (0, 0), box)
#let _approx(a, b) = calc.abs(a - b) < 1e-9
#assert(_approx(edge.at(0), -0.6))
#assert(_approx(edge.at(1), 0))

// A segment that runs across the centre of an AABB is reported as crossing.
#let mid-box = aabb-from-centre((1, 0), 0.4, 0.4)
#assert(segment-crosses((0, 0), (2, 0), mid-box))

// A segment that only touches a box endpoint does NOT count as crossing.
// The anchor-end of a connector typically sits on its own label box edge.
#let edge-box = aabb-from-centre((0, 0), 0.4, 0.4)
#assert(not segment-crosses((0.2, 0), (1, 0), edge-box))

// Straight connector wins when nothing is in the way.
#let label = aabb-from-centre((1, 0), 0.4, 0.4, pad: 0.05)
#let r1 = route-segment((-1, 0), (1, 0), label, (label,), 0)
#assert.eq(r1.len(), 2)
#assert.eq(r1.at(0), (-1, 0))

// When the straight path crosses a sibling label, an L-bend takes over.
// `boxes` carries the layer's full AABB list; passing the index of the
// row's own box lets the router skip it without rebuilding the list.
#let obstacle = aabb-from-centre((0, 0), 0.4, 0.4, pad: 0.05)
#let target = aabb-from-centre((2, 0.6), 0.4, 0.4, pad: 0.05)
#let r2 = route-segment((-1, 0), (2, 0.6), target, (obstacle, target), 1)
#assert(r2 != none)
#assert.eq(r2.len(), 3)

// When every route is blocked the helper returns `none` so the caller can
// drop the connector for that row rather than draw a misleading line.
#let cage-left = aabb-from-centre((-0.5, 0), 1, 4, pad: 0.05)
#let cage-right = aabb-from-centre((1.5, 0), 1, 4, pad: 0.05)
#let trapped-target = aabb-from-centre((3, 0.3), 0.4, 0.4, pad: 0.05)
#let r3 = route-segment(
  (-2, 0.3),
  (3, 0.3),
  trapped-target,
  (cage-left, cage-right, trapped-target),
  2,
)
#assert.eq(r3, none)

segment-route helper tests passed.
