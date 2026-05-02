// margin / margin-part / margin-auto helpers and theme integration.

#import "../../src/theme/elements.typ": margin, margin-auto, margin-part
#import "../../src/theme/defaults.typ": default-theme

// margin: explicit per-side lengths, defaults zero on each side.
#let m = margin(top: 0.5cm, right: 1pt)
#assert.eq(m.kind, "margin")
#assert.eq(m.top, 0.5cm)
#assert.eq(m.right, 1pt)
#assert.eq(m.bottom, 0pt)
#assert.eq(m.left, 0pt)

// margin-part: unspecified sides are auto so the renderer keeps its default.
#let mp = margin-part(top: 1cm)
#assert.eq(mp.kind, "margin")
#assert.eq(mp.top, 1cm)
#assert.eq(mp.right, auto)
#assert.eq(mp.bottom, auto)
#assert.eq(mp.left, auto)

// margin-auto: every side falls through to the renderer's default.
#let ma = margin-auto()
#assert.eq(ma.kind, "margin")
#assert.eq(ma.top, auto)
#assert.eq(ma.right, auto)
#assert.eq(ma.bottom, auto)
#assert.eq(ma.left, auto)

// Default theme ships an auto plot-margin so legacy plots are unchanged.
#assert.eq(default-theme.plot-margin.kind, "margin")
#assert.eq(default-theme.plot-margin.top, auto)

margin family tests passed.
