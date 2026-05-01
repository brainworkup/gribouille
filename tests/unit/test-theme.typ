// theme() stores element records verbatim; merge-theme overlays them on the
// defaults.

#import "../../src/theme/theme.typ": theme
#import "../../src/theme/elements.typ": (
  element-blank, element-line, element-rect, element-text,
)
#import "../../src/theme/defaults.typ": merge-theme

// Element records pass through verbatim.
#let t = theme(
  axis-text: element-text(size: 11pt),
  panel-background: element-rect(fill: rgb("#eeeeee")),
)
#assert.eq(t.axis-text.size, 11pt)
#assert.eq(t.panel-background.fill, rgb("#eeeeee"))

// Different sizing on a different surface.
#let t2 = theme(
  axis-text: element-text(size: 13pt),
  panel-background: element-rect(fill: rgb("#ff9900")),
)
#assert.eq(t2.axis-text.size, 13pt)
#assert.eq(t2.panel-background.fill, rgb("#ff9900"))

// Merging into the defaults produces a usable theme dict.
#let merged = merge-theme(t2)
#assert.eq(merged.axis-text.size, 13pt)
#assert.eq(merged.panel-background.fill, rgb("#ff9900"))

Theme tests passed.
