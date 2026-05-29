// _text-style surfaces the cascaded `family` field as `font`. Unset stays
// `none` so no `font:` argument is emitted and the document font is kept;
// surface and parent records cascade like every other element field. The
// geom font role lives on `element-geom` as `font` and inherits the base
// `text` family when unset.

#import "../../lib.typ": element-geom, element-text, theme
#import "../../src/theme/defaults.typ": default-theme, merge-theme
#import "../../src/theme/theme.typ": _text-style, geom-defaults

// No override: font is none, so consumers omit `text(font: ...)` entirely.
#let plain = merge-theme(none)
#assert.eq(_text-style(plain, "plot-title").font, none)
#assert.eq(_text-style(plain, "axis-text-x-bottom").font, none)
#assert.eq(_text-style(plain, "legend-text").font, none)

// Surface-level family is surfaced verbatim under `font`.
#let user = theme(plot-caption: element-text(family: "Font A"))
#assert.eq(_text-style(merge-theme(user), "plot-caption").font, "Font A")

// Parent `text` family cascades to descendants that do not set one.
#let parent = theme(text: element-text(family: "Font B"))
#assert.eq(_text-style(merge-theme(parent), "plot-title").font, "Font B")
#assert.eq(
  _text-style(merge-theme(parent), "axis-title-x-bottom").font,
  "Font B",
)

// Surface family wins over the inherited parent family.
#let both = theme(
  text: element-text(family: "Font B"),
  plot-title: element-text(family: "Font C"),
)
#assert.eq(_text-style(merge-theme(both), "plot-title").font, "Font C")

// element-typst surfaces family the same way.
#let typst = theme(plot-title: element-text(family: "Font D"))
#assert.eq(_text-style(merge-theme(typst), "plot-title").font, "Font D")

// element-geom carries a `font` role, default none.
#assert.eq(element-geom().font, none)
#assert.eq(element-geom(font: "Geom Font").font, "Geom Font")

// geom-defaults.font: element-geom.font wins; else inherits the base `text`
// family. The text-drawing geoms read this field directly (no hard fallback,
// `none` simply omits the `font:` argument).
#assert.eq(geom-defaults(plain).font, none)

#let geom-themed = merge-theme(theme(geom: element-geom(font: "Geom Font")))
#assert.eq(geom-defaults(geom-themed).font, "Geom Font")

// Unset element-geom.font inherits the base text family.
#let base-themed = merge-theme(theme(text: element-text(family: "Base Font")))
#assert.eq(geom-defaults(base-themed).font, "Base Font")

// element-geom.font overrides the inherited base text family.
#let both-themed = merge-theme(theme(
  text: element-text(family: "Base Font"),
  geom: element-geom(font: "Geom Font"),
))
#assert.eq(geom-defaults(both-themed).font, "Geom Font")

text-style font cascade test passed.
