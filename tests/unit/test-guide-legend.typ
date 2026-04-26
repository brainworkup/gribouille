// guide-legend(), guide-none(), and guides() build the expected dictionaries.

#import "../../src/guide/legend.typ": guide-legend
#import "../../src/guide/none.typ": guide-none
#import "../../src/guides.typ": guides

#let g = guide-legend(reverse: true)
#assert.eq(g.kind, "guide")
#assert.eq(g.aesthetic, none)
#assert.eq(g.title, none)
#assert.eq(g.nrow, none)
#assert.eq(g.ncol, none)
#assert.eq(g.reverse, true)

#let g2 = guide-legend(title: "Group", ncol: 2)
#assert.eq(g2.title, "Group")
#assert.eq(g2.ncol, 2)
#assert.eq(g2.reverse, false)

#let n = guide-none()
#assert.eq(n.kind, "guide")
#assert.eq(n.suppress, true)

#let bound = guides(colour: guide-legend(reverse: true), fill: guide-none())
#assert.eq(type(bound), dictionary)
#assert.eq(bound.colour.reverse, true)
#assert.eq(bound.fill.suppress, true)

Guide-legend tests passed.
