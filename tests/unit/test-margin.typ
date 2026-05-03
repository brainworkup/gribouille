// margin() helper: defaults to auto on every side; explicit sides override.

#import "../../src/theme/elements.typ": margin
#import "../../src/theme/defaults.typ": default-theme

// Bare call: every side falls through to the renderer's default.
#let ma = margin()
#assert.eq(ma.kind, "margin")
#assert.eq(ma.top, auto)
#assert.eq(ma.right, auto)
#assert.eq(ma.bottom, auto)
#assert.eq(ma.left, auto)

// Mixed: explicit sides override; unspecified sides keep auto.
#let mp = margin(top: 1cm)
#assert.eq(mp.kind, "margin")
#assert.eq(mp.top, 1cm)
#assert.eq(mp.right, auto)
#assert.eq(mp.bottom, auto)
#assert.eq(mp.left, auto)

// Fully explicit: pass zeros on every side for an edge-to-edge canvas.
#let mz = margin(top: 0pt, right: 0pt, bottom: 0pt, left: 0pt)
#assert.eq(mz.top, 0pt)
#assert.eq(mz.right, 0pt)
#assert.eq(mz.bottom, 0pt)
#assert.eq(mz.left, 0pt)

// Default theme ships an auto plot-margin so legacy plots are unchanged.
#assert.eq(default-theme.plot-margin.kind, "margin")
#assert.eq(default-theme.plot-margin.top, auto)

margin tests passed.
