// element-rect preserves `inset` and `outset` margin records, and the
// internal `_rect-style` resolver exposes them as separate per-side cm
// dicts: `inset-cm` for cetz draw sites (inner padding grows the rect
// outward), `outset-cm` for layout reservation (outer margin shrinks the
// panel canvas).

#import "../../lib.typ": element-rect, margin, theme
#import "../../src/theme/defaults.typ": merge-theme
#import "../../src/theme/theme.typ": _rect-outset-cm, _rect-style

#let approx-eq(a, b, tol: 1e-9) = {
  let diff = a - b
  if diff < 0 { diff = -diff }
  assert(diff < tol, message: "expected " + repr(a) + " ~= " + repr(b))
}

// Constructor stores both records as-is, with auto on missing sides.
#let er = element-rect(
  fill: rgb("#eeeeee"),
  inset: margin(top: 0.2cm, left: 1em),
  outset: margin(right: 0.5cm),
)
#assert.eq(er.kind, "element-rect")
#assert.eq(er.inset.kind, "margin")
#assert.eq(er.inset.top, 0.2cm)
#assert.eq(er.inset.left, 1em)
#assert.eq(er.inset.right, auto)
#assert.eq(er.inset.bottom, auto)
#assert.eq(er.outset.right, 0.5cm)
#assert.eq(er.outset.top, auto)

// Default inset is 5pt on every side so painted backgrounds (legend / plot)
// get implicit breathing room around their content; outset defaults to
// `none` (no outer reservation).
#let bare = element-rect(fill: rgb("#cccccc"))
#assert.eq(bare.inset.kind, "margin")
#assert.eq(bare.inset.top, 5pt)
#assert.eq(bare.inset.right, 5pt)
#assert.eq(bare.inset.bottom, 5pt)
#assert.eq(bare.inset.left, 5pt)
#assert.eq(bare.outset, none)

// `_rect-style` resolves each record to per-side cm floats. Em components
// scale against the surface font size (defaults: 9pt).
#let merged = merge-theme(theme(panel-background: er))
#let style = _rect-style(merged, "panel-background")
#assert.eq(style.fill, rgb("#eeeeee"))
// 1em at 9pt resolves to 9pt in cm; 1pt = 1/72in = 2.54/72 cm.
#let em-cm = 9 * (2.54 / 72)
#assert.eq(style.inset-cm.top, 0.2)
#assert.eq(style.inset-cm.left, em-cm)
#assert.eq(style.inset-cm.right, 0)
#assert.eq(style.inset-cm.bottom, 0)
#assert.eq(style.outset-cm.right, 0.5)
#assert.eq(style.outset-cm.top, 0)
#assert.eq(style.outset-cm.bottom, 0)
#assert.eq(style.outset-cm.left, 0)

// Bare element-rect ships a 5pt-per-side default inset; `_rect-style`
// converts the absolute length to cm independent of the ref dims.
// 1pt = 1/72in = 2.54/72 cm, so 5pt = 5 * (2.54/72) cm.
#let pt-cm = 2.54 / 72
#let plain = _rect-style(
  merge-theme(theme(panel-background: bare)),
  "panel-background",
  inset-ref-w: 5,
  inset-ref-h: 3,
)
#approx-eq(plain.inset-cm.top, 5 * pt-cm)
#approx-eq(plain.inset-cm.right, 5 * pt-cm)
#approx-eq(plain.inset-cm.bottom, 5 * pt-cm)
#approx-eq(plain.inset-cm.left, 5 * pt-cm)
#assert.eq(plain.outset-cm.right, 0)

// `_rect-outset-cm` is the leaner layout-side helper; `%` outsets
// reference the plot canvas (ref-w / ref-h here = 10 / 6).
#let out = _rect-outset-cm(merged, "panel-background", ref-w: 10, ref-h: 6)
#assert.eq(out.right, 0.5)
#assert.eq(out.top, 0)

// Explicit `%` and `relative` on inset resolve against the per-rect
// references; left / right use `inset-ref-w`, top / bottom use
// `inset-ref-h`.
#let rel = element-rect(
  inset: margin(top: 10%, right: 5% + 0.2cm, bottom: 0%, left: 1cm),
)
#let rel-style = _rect-style(
  merge-theme(theme(panel-background: rel)),
  "panel-background",
  inset-ref-w: 10,
  inset-ref-h: 8,
)
#approx-eq(rel-style.inset-cm.top, 0.8)
#approx-eq(rel-style.inset-cm.right, 0.7)
#approx-eq(rel-style.inset-cm.bottom, 0)
#approx-eq(rel-style.inset-cm.left, 1)

element-rect margin smoke test passed.
