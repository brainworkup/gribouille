// guide-axis-theta() builds a spec consumed by the radial theta axis.

#import "../../src/guide/axis-theta.typ": guide-axis-theta
#import "../../src/guides.typ": guides

#let g = guide-axis-theta()
#assert.eq(g.kind, "guide")
#assert.eq(g.aesthetic, "theta")
#assert.eq(g.angle, 0)
#assert.eq(g.minor-ticks, false)
#assert.eq(g.cap, "none")

#let g2 = guide-axis-theta(angle: 30, minor-ticks: true, cap: "both")
#assert.eq(g2.angle, 30)
#assert.eq(g2.minor-ticks, true)
#assert.eq(g2.cap, "both")

#let bound = guides(theta: guide-axis-theta(angle: 45, cap: "upper"))
#assert.eq(bound.theta.angle, 45)
#assert.eq(bound.theta.cap, "upper")

Guide-axis-theta tests passed.
