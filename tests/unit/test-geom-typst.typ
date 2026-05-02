// geom-typst smoke + annotate routing tests.

#import "../../src/geom/typst.typ": geom-typst
#import "../../src/annotate.typ": annotate
#import "../../src/utils/typst-markup.typ": is-typst-markup, typst

// Constructor returns a layer dict tagged with the right geom name.
#let g = geom-typst()
#assert.eq(g.kind, "layer")
#assert.eq(g.geom, "typst")
#assert.eq(g.stat, "identity")
#assert.eq(g.position, "identity")
#assert.eq(g.params.size, 10pt)
#assert.eq(g.params.anchor, "center")
#assert.eq(g.params.dx, 0)
#assert.eq(g.params.dy, 0)

// annotate("typst", ...) routes through geom-typst.
#let a-typst = annotate("typst", x: 1, y: 2, label: "*hello*", anchor: "west")
#assert.eq(a-typst.geom, "typst")
#assert.eq(a-typst.inherit-aes, false)
#assert.eq(a-typst.data.len(), 1)
#assert.eq(a-typst.data.at(0).label, "*hello*")
#assert.eq(a-typst.params.anchor, "west")

// annotate("text", label: typst("...")) preserves the typst tag on the column
// reference so geom-text knows to evaluate the value as Typst markup; the
// row stores the unwrapped source string.
#let a-text = annotate("text", x: 1, y: 2, label: typst("$alpha$"))
#assert.eq(a-text.geom, "text")
#assert.eq(a-text.data.at(0).label, "$alpha$")
#assert(is-typst-markup(a-text.mapping.label))

// Plain string label leaves the mapping untagged.
#let a-plain = annotate("text", x: 1, y: 2, label: "plain")
#assert.eq(a-plain.data.at(0).label, "plain")
#assert.eq(a-plain.mapping.label, "label")

geom-typst + annotate routing tests passed.
