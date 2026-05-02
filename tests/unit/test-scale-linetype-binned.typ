// scale-linetype-binned plus _continuous and _discrete aliases.

#import "../../src/scale/linetype.typ": (
  scale-linetype, scale-linetype-binned, scale-linetype-continuous,
  scale-linetype-discrete,
)
#import "../../src/utils/level-resolve.typ": resolve-level
#import "../../src/utils/palette.typ": default-linetypes

#let s = scale-linetype-binned()
#assert.eq(s.kind, "scale")
#assert.eq(s.aesthetic, "linetype")
#assert.eq(s.type, "continuous")
#assert.eq(s.binned, true)
#assert.eq(s.n-breaks, 4)
#assert.eq(s.palette, default-linetypes)

// _continuous delegates to _binned.
#let sc = scale-linetype-continuous()
#assert.eq(sc.type, "continuous")
#assert.eq(sc.binned, true)
#assert.eq(sc.n-breaks, 4)

// _discrete delegates to scale-linetype.
#let sd = scale-linetype-discrete()
#let sd-direct = scale-linetype()
#assert.eq(sd.type, "discrete")
#assert.eq(sd.aesthetic, "linetype")
#assert.eq(sd.palette, sd-direct.palette)

// resolve-level snaps to bin linetypes.
#let trained = (
  type: "continuous",
  domain: (0, 12),
  spec: (binned: true, n-breaks: 3, palette: default-linetypes),
)
#assert.eq(resolve-level("linetype", trained, 0), default-linetypes.at(0))
#assert.eq(resolve-level("linetype", trained, 6), default-linetypes.at(1))
#assert.eq(resolve-level("linetype", trained, 12), default-linetypes.at(2))

scale-linetype-binned tests passed.
