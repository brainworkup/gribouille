// element-geom() carries layer-default aesthetics consumed by supporting
// geoms via theme.geom. Default-theme should expose an empty record.

#import "../../src/theme/elements.typ": element-geom
#import "../../src/theme/defaults.typ": default-theme, merge-theme
#import "../../src/theme/theme.typ": geom-defaults, theme

#let g = element-geom()
#assert.eq(g.kind, "element-geom")
#assert.eq(g.fill, none)
#assert.eq(g.colour, none)
#assert.eq(g.linewidth, none)

#let g2 = element-geom(fill: red, colour: blue, linewidth: 1pt)
#assert.eq(g2.fill, red)
#assert.eq(g2.colour, blue)
#assert.eq(g2.linewidth, 1pt)

// default-theme carries an empty element-geom under `geom`.
#assert.eq(default-theme.geom.kind, "element-geom")
#assert.eq(default-theme.geom.fill, none)

// theme(geom: ...) merges through merge-theme cleanly.
#let t = merge-theme(theme(geom: element-geom(fill: rgb("#cc3333"))))
#assert.eq(t.geom.fill, rgb("#cc3333"))

// geom-defaults picks the resolved record off the merged theme.
#let d = geom-defaults(t)
#assert.eq(d.kind, "element-geom")
#assert.eq(d.fill, rgb("#cc3333"))

// geom-defaults on a theme without a `geom` slot returns an all-none record.
#let stripped = (kind: "theme", name: "x")
#let dd = geom-defaults(stripped)
#assert.eq(dd.kind, "element-geom")
#assert.eq(dd.fill, none)

Element-geom tests passed.
