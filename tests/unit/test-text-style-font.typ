// _text-style surfaces the cascaded `font` field. Unset stays `none` so no
// `font:` argument is emitted and the document font is kept; surface and
// parent records cascade like every other element field. The geom font role
// lives on `element-geom` as `font` and inherits the base `text` font when
// unset.

#import "../../lib.typ": element-geom, element-text, theme
#import "../../src/theme/defaults.typ": default-theme, merge-theme
#import "../../src/theme/theme.typ": _text-style, geom-defaults

// No override: font is none, so consumers omit `text(font: ...)` entirely.
#let plain = merge-theme(none)
#assert.eq(_text-style(plain, "plot-title").font, none)
#assert.eq(_text-style(plain, "axis-text-x-bottom").font, none)
#assert.eq(_text-style(plain, "legend-text").font, none)

// Surface-level font is surfaced verbatim.
#let user = theme(plot-caption: element-text(font: "Font A"))
#assert.eq(_text-style(merge-theme(user), "plot-caption").font, "Font A")

// Parent `text` font cascades to descendants that do not set one.
#let parent = theme(text: element-text(font: "Font B"))
#assert.eq(_text-style(merge-theme(parent), "plot-title").font, "Font B")
#assert.eq(
  _text-style(merge-theme(parent), "axis-title-x-bottom").font,
  "Font B",
)

// Surface font wins over the inherited parent font.
#let both = theme(
  text: element-text(font: "Font B"),
  plot-title: element-text(font: "Font C"),
)
#assert.eq(_text-style(merge-theme(both), "plot-title").font, "Font C")

// element-typst surfaces font the same way.
#let typst = theme(plot-title: element-text(font: "Font D"))
#assert.eq(_text-style(merge-theme(typst), "plot-title").font, "Font D")

// element-geom carries a `font` role, default none.
#assert.eq(element-geom().font, none)
#assert.eq(element-geom(font: "Geom Font").font, "Geom Font")

// geom-defaults.font: element-geom.font wins; else inherits the base `text`
// font. The text-drawing geoms read this field directly (no hard fallback,
// `none` simply omits the `font:` argument).
#assert.eq(geom-defaults(plain).font, none)

#let geom-themed = merge-theme(theme(geom: element-geom(font: "Geom Font")))
#assert.eq(geom-defaults(geom-themed).font, "Geom Font")

// Unset element-geom.font inherits the base text font.
#let base-themed = merge-theme(theme(text: element-text(font: "Base Font")))
#assert.eq(geom-defaults(base-themed).font, "Base Font")

// element-geom.font overrides the inherited base text font.
#let both-themed = merge-theme(theme(
  text: element-text(font: "Base Font"),
  geom: element-geom(font: "Geom Font"),
))
#assert.eq(geom-defaults(both-themed).font, "Geom Font")

text-style font cascade test passed.
