// guide-axis-logticks() builds a guide spec carrying the logticks flag.

#import "../../src/guide/axis.typ": guide-axis, guide-axis-logticks
#import "../../src/guides.typ": guides

#let g = guide-axis-logticks()
#assert.eq(g.kind, "guide")
#assert.eq(g.angle, 0)
#assert.eq(g.n-dodge, 1)
#assert.eq(g.logticks, true)

#let g2 = guide-axis-logticks(angle: 45, n-dodge: 2)
#assert.eq(g2.angle, 45)
#assert.eq(g2.n-dodge, 2)
#assert.eq(g2.logticks, true)

// Plain guide-axis omits the flag (defaults to no minor ticks).
#let plain = guide-axis()
#assert.eq(plain.at("logticks", default: false), false)

// Bound to either x or y.
#let bound = guides(
  x: guide-axis-logticks(),
  y: guide-axis-logticks(angle: 30),
)
#assert.eq(bound.x.logticks, true)
#assert.eq(bound.y.angle, 30)

Guide-axis-logticks tests passed.
