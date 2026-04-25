// coord-fixed: spec dictionary shape.

#import "../../src/coord/fixed.typ": coord-fixed

#let c1 = coord-fixed()
#assert.eq(c1.kind, "coord")
#assert.eq(c1.coord, "fixed")
#assert.eq(c1.ratio, 1)

#let c2 = coord-fixed(ratio: 2)
#assert.eq(c2.coord, "fixed")
#assert.eq(c2.ratio, 2)

#let c3 = coord-fixed(ratio: 0.5)
#assert.eq(c3.ratio, 0.5)

coord-fixed tests passed.
