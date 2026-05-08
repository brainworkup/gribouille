// guide-custom() builds a free-form guide spec consumed by the legend dispatch.

#import "../../src/guide/custom.typ": guide-custom
#import "../../src/guides.typ": guides

#let g = guide-custom([Hello])
#assert.eq(g.kind, "guide-custom")
#assert.eq(g.width, auto)
#assert.eq(g.height, auto)
#assert.eq(g.title, none)

#let sized = guide-custom(
  [Notes here],
  width: 4cm,
  height: 2cm,
  title: "Notes",
)
#assert.eq(sized.width, 4cm)
#assert.eq(sized.height, 2cm)
#assert.eq(sized.title, "Notes")

#let bound = guides(custom: guide-custom([x], width: 3cm))
#assert.eq(bound.custom.kind, "guide-custom")
#assert.eq(bound.custom.width, 3cm)

Guide-custom tests passed.
