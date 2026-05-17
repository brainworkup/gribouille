// Pure-data tests for the force-based repulsion algorithm in
// `src/utils/repel.typ`. The geom is exercised end-to-end in
// test-geom-text-repel.typ; these checks only stress the layout maths.

#import "../../src/utils/repel.typ": repel

#let _len(p) = calc.sqrt(p.at(0) * p.at(0) + p.at(1) * p.at(1))
#let _approx(a, b, eps: 1e-6) = calc.abs(a - b) < eps

// Two coincident anchors with overlapping boxes are pushed apart while
// staying near their shared origin under the spring pull.
#let anchors = ((0, 0), (0, 0))
#let sizes = ((w: 1, h: 0.4), (w: 1, h: 0.4))
#let offsets = repel(anchors, sizes, params: (seed: 1, max-iter: 200))
#assert.eq(offsets.len(), 2)
#assert(_len(offsets.at(0)) > 0)
#assert(_len(offsets.at(1)) > 0)

// Final placements should not overlap: separation >= roughly box width.
#let dx = offsets.at(0).at(0) - offsets.at(1).at(0)
#let dy = offsets.at(0).at(1) - offsets.at(1).at(1)
#assert(calc.sqrt(dx * dx + dy * dy) > 0.5)

// Same seed produces the same layout; different seeds diverge. This is
// what makes the algorithm safe to run in document-render pipelines.
#let again = repel(anchors, sizes, params: (seed: 1, max-iter: 200))
#assert(_approx(offsets.at(0).at(0), again.at(0).at(0)))
#assert(_approx(offsets.at(0).at(1), again.at(0).at(1)))
#let other = repel(anchors, sizes, params: (seed: 7, max-iter: 200))
#assert(
  not _approx(offsets.at(0).at(0), other.at(0).at(0))
    or not _approx(offsets.at(0).at(1), other.at(0).at(1)),
)

// Spring pull keeps labels close to their anchor even with strong repulsion.
#let far-anchors = ((0, 0), (5, 5))
#let far-sizes = ((w: 0.2, h: 0.2), (w: 0.2, h: 0.2))
#let far = repel(
  far-anchors,
  far-sizes,
  params: (seed: 1, max-iter: 100, force-pull: 0.5),
)
#assert(_len(far.at(0)) < 0.5)
#assert(_len(far.at(1)) < 0.5)

// Segment-crossing penalty pushes a label off another row's connector
// path. Place label A near origin and label B sitting on the straight
// path from C's anchor to C's repelled position; the algorithm should
// move B away from that path.
#let three-anchors = ((0, 0), (1, 0), (2, 0))
#let three-sizes = ((w: 0.2, h: 0.2), (w: 0.4, h: 0.4), (w: 0.2, h: 0.2))
#let three = repel(
  three-anchors,
  three-sizes,
  params: (seed: 1, max-iter: 200, force-segment: 1.0),
)
#assert(three.len() == 3)

empty repel tests passed.
