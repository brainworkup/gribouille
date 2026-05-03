// element-text and element-typst preserve a margin record built with
// margin-part(). Sides default to auto so the renderer falls back to its
// own gap when the user has not set them.

#import "../../lib.typ": element-text, element-typst, margin-part

#let m = margin-part(top: 1.5em, right: 0.4cm)

#let et = element-text(size: 11pt, margin: m)
#assert.eq(et.kind, "element-text")
#assert.eq(et.size, 11pt)
#assert.eq(et.margin.kind, "margin")
#assert.eq(et.margin.top, 1.5em)
#assert.eq(et.margin.right, 0.4cm)
#assert.eq(et.margin.bottom, auto)
#assert.eq(et.margin.left, auto)

// Default margin is none so existing themes keep their defaults verbatim.
#let bare = element-text()
#assert.eq(bare.margin, none)

// element-typst stores the same margin field with kind: element-typst.
#let etpst = element-typst(margin: m)
#assert.eq(etpst.kind, "element-typst")
#assert.eq(etpst.margin.top, 1.5em)
#assert.eq(etpst.margin.right, 0.4cm)

element-text margin smoke test passed.
