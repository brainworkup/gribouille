// _text-style surfaces the cascaded margin record. Surface-level margins
// override the parent `text` element; sides not set anywhere default to auto.

#import "../../lib.typ": element-text, margin-part, theme
#import "../../src/theme/defaults.typ": merge-theme
#import "../../src/theme/theme.typ": _text-style

// No theme override: every side is auto so the renderer's own default is used.
#let plain = merge-theme(none)
#let plain-style = _text-style(plain, "axis-title")
#assert.eq(plain-style.margin.kind, "margin")
#assert.eq(plain-style.margin.top, auto)
#assert.eq(plain-style.margin.right, auto)

// Surface-level margin: only the sides the user set are exposed; others stay
// auto so the renderer fallback remains in effect.
#let user = theme(
  axis-title: element-text(margin: margin-part(top: 1.5em)),
)
#let user-style = _text-style(merge-theme(user), "axis-title")
#assert.eq(user-style.margin.top, 1.5em)
#assert.eq(user-style.margin.right, auto)
#assert.eq(user-style.margin.bottom, auto)
#assert.eq(user-style.margin.left, auto)

// Parent `text` margin cascades to descendants when the surface itself does
// not set one.
#let parent = theme(
  text: element-text(margin: margin-part(bottom: 0.5cm)),
)
#let parent-style = _text-style(merge-theme(parent), "plot-title")
#assert.eq(parent-style.margin.bottom, 0.5cm)

// Surface margin wins over the inherited parent margin.
#let both = theme(
  text: element-text(margin: margin-part(bottom: 0.5cm)),
  plot-title: element-text(margin: margin-part(bottom: 1em)),
)
#let both-style = _text-style(merge-theme(both), "plot-title")
#assert.eq(both-style.margin.bottom, 1em)

text-style margin cascade test passed.
