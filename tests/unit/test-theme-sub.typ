// theme-sub-* shortcuts expand into theme() dicts with the corresponding
// surface keys. `none` arguments must be dropped so they do not clobber
// the inherited cascade.

#import "../../src/theme/sub.typ": (
  theme-sub-axis, theme-sub-axis-bottom, theme-sub-axis-left,
  theme-sub-axis-right, theme-sub-axis-top, theme-sub-axis-x, theme-sub-axis-y,
  theme-sub-legend, theme-sub-panel, theme-sub-plot, theme-sub-strip,
)
#import "../../src/theme/elements.typ": (
  element-blank, element-line, element-rect, element-text, margin,
)
#import "../../src/theme/defaults.typ": merge-theme

#let red-text = element-text(colour: red)
#let red-line = element-line(colour: red)
#let red-rect = element-rect(fill: red)

// `none` arguments are dropped; surface keys for non-none args land in the
// dict.
#let t = theme-sub-axis(title: red-text, text: red-text)
#assert.eq(t.kind, "theme")
#assert.eq(t.at("axis-title"), red-text)
#assert.eq(t.at("axis-text"), red-text)
#assert.eq(t.at("axis-line", default: none), none)
#assert.eq(t.at("axis-ticks", default: none), none)

// Per-axis variants land on the matching prefixed keys.
#let tx = theme-sub-axis-x(text: red-text, line: red-line)
#assert.eq(tx.at("axis-text-x"), red-text)
#assert.eq(tx.at("axis-line-x"), red-line)
#assert.eq(tx.at("axis-text", default: none), none)

#let ty = theme-sub-axis-y(ticks: red-line)
#assert.eq(ty.at("axis-ticks-y"), red-line)

// Per-side variants.
#let tb = theme-sub-axis-bottom(text: red-text)
#assert.eq(tb.at("axis-text-x-bottom"), red-text)

#let tt = theme-sub-axis-top(line: red-line)
#assert.eq(tt.at("axis-line-x-top"), red-line)

#let tl = theme-sub-axis-left(title: red-text)
#assert.eq(tl.at("axis-title-y-left"), red-text)

#let tr = theme-sub-axis-right(ticks: red-line)
#assert.eq(tr.at("axis-ticks-y-right"), red-line)

// Legend, panel, plot, strip shortcuts.
#let tlg = theme-sub-legend(title: red-text)
#assert.eq(tlg.at("legend-title"), red-text)
#assert.eq(tlg.at("legend-text", default: none), none)

#let tp = theme-sub-panel(grid: element-blank(), background: red-rect)
#assert.eq(tp.at("panel-grid").kind, "element-blank")
#assert.eq(tp.at("panel-background"), red-rect)

#let tpl = theme-sub-plot(title: red-text, plot-margin: margin(left: 2cm))
#assert.eq(tpl.at("plot-title"), red-text)
#assert.eq(tpl.at("plot-margin").left, 2cm)

#let ts = theme-sub-strip(text: red-text)
#assert.eq(ts.at("strip-text"), red-text)

// Round-trip through merge-theme: surface keys survive merging.
#let merged = merge-theme(theme-sub-legend(title: red-text))
#assert.eq(merged.at("legend-title"), red-text)
