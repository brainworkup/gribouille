// element-geom() carries layer-default aesthetics consumed by supporting
// geoms via theme.geom. Default-theme should expose an empty record.

#import "../../src/theme/elements.typ": element-geom
#import "../../src/theme/defaults.typ": default-theme, merge-theme
#import "../../src/theme/theme.typ": (
  geom-accent, geom-colour-default, geom-defaults, geom-fill-default,
  geom-fill-tint-amount, geom-ink, geom-paper, theme,
)
#import "../../src/utils/colour.typ": col-mix

#let g = element-geom()
#assert.eq(g.kind, "element-geom")
#assert.eq(g.fill, none)
#assert.eq(g.colour, none)
#assert.eq(g.linewidth, none)
#assert.eq(g.font, none)

#let g2 = element-geom(fill: red, colour: blue, linewidth: 1pt, font: "Font A")
#assert.eq(g2.fill, red)
#assert.eq(g2.colour, blue)
#assert.eq(g2.linewidth, 1pt)
#assert.eq(g2.font, "Font A")

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

// Role helpers + default resolvers.

// Empty element-geom + bare default-theme: roles inherit theme scalars.
#let d0 = geom-defaults(default-theme)
#assert.eq(geom-ink(d0), default-theme.ink)
#assert.eq(geom-paper(d0), default-theme.paper)
#assert.eq(geom-accent(d0), default-theme.accent)
#assert.eq(geom-colour-default(d0), default-theme.ink)
#assert.eq(geom-colour-default(d0, role: "accent"), default-theme.accent)
#assert.eq(
  geom-fill-default(d0, role: "tint"),
  col-mix(default-theme.ink, default-theme.paper, geom-fill-tint-amount),
)
#assert.eq(geom-fill-default(d0, role: "paper"), default-theme.paper)
#assert.eq(geom-fill-default(d0, role: "ink"), default-theme.ink)

// Theme with no geom slot and no scalars: hard fallbacks black/white/#3366FF.
#let de = geom-defaults(stripped)
#assert.eq(geom-ink(de), black)
#assert.eq(geom-paper(de), white)
#assert.eq(geom-accent(de), rgb("#3366FF"))
#assert.eq(geom-colour-default(de), black)
#assert.eq(
  geom-fill-default(de, role: "tint"),
  col-mix(black, white, geom-fill-tint-amount),
)

// element-geom(ink: X): colour-default == X; the tint uses X as its dark stop.
#let di = geom-defaults(
  merge-theme(theme(geom: element-geom(ink: rgb("#112233")))),
)
#assert.eq(geom-colour-default(di), rgb("#112233"))
#assert.eq(
  geom-fill-default(di, role: "tint"),
  col-mix(rgb("#112233"), default-theme.paper, geom-fill-tint-amount),
)

// element-geom(paper: X): paper-role fill == X; tint uses X as its light stop.
#let dp = geom-defaults(
  merge-theme(theme(geom: element-geom(paper: rgb("#445566")))),
)
#assert.eq(geom-fill-default(dp, role: "paper"), rgb("#445566"))
#assert.eq(
  geom-fill-default(dp, role: "tint"),
  col-mix(default-theme.ink, rgb("#445566"), geom-fill-tint-amount),
)

// element-geom(colour: X): global override; wins over every colour role.
#let dc = geom-defaults(
  merge-theme(theme(geom: element-geom(colour: rgb("#778899")))),
)
#assert.eq(geom-colour-default(dc), rgb("#778899"))
#assert.eq(geom-colour-default(dc, role: "accent"), rgb("#778899"))

// element-geom(fill: X): global override; wins over every fill role.
#let df = geom-defaults(
  merge-theme(theme(geom: element-geom(fill: rgb("#aabbcc")))),
)
#assert.eq(geom-fill-default(df, role: "tint"), rgb("#aabbcc"))
#assert.eq(geom-fill-default(df, role: "paper"), rgb("#aabbcc"))
#assert.eq(geom-fill-default(df, role: "ink"), rgb("#aabbcc"))

// element-geom(accent: X): accent-role colour == X; ink role unaffected.
#let da = geom-defaults(
  merge-theme(theme(geom: element-geom(accent: rgb("#abcdef")))),
)
#assert.eq(geom-colour-default(da, role: "accent"), rgb("#abcdef"))
#assert.eq(geom-colour-default(da), default-theme.ink)

// role: none skips the role fallback (fill-only geoms): empty element-geom
// returns none; element-geom(colour: X) still wins.
#assert.eq(geom-colour-default(d0, role: none), none)
#assert.eq(geom-colour-default(dc, role: none), rgb("#778899"))

Element-geom tests passed.
