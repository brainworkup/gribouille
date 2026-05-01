// Theme-driven Typst-markup passthrough via element-typst().
//
// element-typst() is a drop-in replacement for element-text() at any
// text surface. When set, plain strings reaching that surface are
// evaluated as Typst markup. Per-call typst() and content (`[...]`)
// values still pass through unchanged.

#import "../../lib.typ": (
  aes, element-text, element-typst, geom-col, geom-point, labs, plot, theme,
  typst,
)
#import "../../src/theme/defaults.typ": merge-theme

// Theme unpacking sets the per-surface <key>-typst flag.
#let t = theme(
  plot-title: element-typst(size: 14pt, weight: "bold"),
  axis-text: element-typst(),
  legend-title: element-text(),
)
#let merged = merge-theme(t)
#assert.eq(merged.plot-title-typst, true)
#assert.eq(merged.plot-title-size, 14pt)
#assert.eq(merged.plot-title-weight, "bold")
#assert.eq(merged.axis-text-typst, true)
#assert.eq(merged.legend-title-typst, false)
#assert.eq(merged.plot-subtitle-typst, false)

// Defaults: every text surface starts with typst=false.
#let plain = merge-theme(none)
#assert.eq(plain.plot-title-typst, false)
#assert.eq(plain.axis-text-typst, false)
#assert.eq(plain.legend-text-typst, false)
#assert.eq(plain.strip-text-typst, false)

#let d = ((x: 1, y: 1), (x: 2, y: 4), (x: 3, y: 9))

// element-typst on plot-title: a plain-string title eval'd as markup.
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 3pt),),
  labs: labs(title: "Mean $bar(x)$ over time"),
  theme: theme(plot-title: element-typst(size: 14pt)),
  width: 10cm,
  height: 6cm,
)

// element-text fallback: same string renders literally (regression).
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 3pt),),
  labs: labs(title: "Mean $bar(x)$ over time"),
  theme: theme(plot-title: element-text(size: 14pt)),
  width: 10cm,
  height: 6cm,
)

// Per-call typst() wins regardless of theme element.
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 3pt),),
  labs: labs(title: typst("$alpha + beta$")),
  theme: theme(plot-title: element-text()),
  width: 10cm,
  height: 6cm,
)

// Content passes through unchanged when element-typst is set
// (no double-eval since resolve-prose already keeps content as content).
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 3pt),),
  labs: labs(title: [Bold *literal*]),
  theme: theme(plot-title: element-typst()),
  width: 10cm,
  height: 6cm,
)

// Mix and match: title is typst-eval'd, axis titles stay literal.
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 3pt),),
  labs: labs(
    title: "Result: $p < 0.001$",
    x: "Time (s)",
    y: "Distance (m)",
  ),
  theme: theme(
    plot-title: element-typst(),
    axis-title: element-text(),
  ),
  width: 10cm,
  height: 6cm,
)

// Discrete axis ticks with element-typst on axis-text.
#let groups = (
  (g: "$alpha$", n: 4),
  (g: "$beta$", n: 7),
  (g: "$gamma$", n: 3),
)
#plot(
  data: groups,
  mapping: aes(x: "g", y: "n", fill: "g"),
  layers: (geom-col(),),
  theme: theme(
    axis-text: element-typst(),
    legend-text: element-typst(),
  ),
  width: 10cm,
  height: 6cm,
)

element-typst smoke test passed.
