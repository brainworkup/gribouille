// Unit tests for the extra theme presets: bw, linedraw, light, dark, test.

#import "../../src/theme/bw.typ": theme-bw
#import "../../src/theme/linedraw.typ": theme-linedraw
#import "../../src/theme/light.typ": theme-light
#import "../../src/theme/dark.typ": theme-dark
#import "../../src/theme/test.typ": theme-test
#import "../../src/theme/grey.typ": theme-grey
#import "../../src/theme/minimal.typ": theme-minimal
#import "../../src/theme/classic.typ": theme-classic
#import "../../src/theme/void.typ": theme-void
#import "../../src/theme/elements.typ": (
  element-blank, element-line, element-rect, element-text,
)
#import "../../src/theme/defaults.typ": default-theme, merge-theme

// Keys that merge-theme consumes: every default-theme key must survive a merge.
#let _expected-keys = default-theme.keys()

#let _check-theme(t, expected-name) = {
  assert.eq(type(t), dictionary)
  assert.eq(t.kind, "theme")
  assert.eq(t.name, expected-name)
  let merged = merge-theme(t)
  for k in _expected-keys {
    assert(
      k in merged,
      message: "missing key " + k + " in merged " + expected-name,
    )
  }
  // Theme-supplied fields propagate through merge.
  for (k, v) in t.pairs() {
    assert.eq(merged.at(k), v)
  }
}

#_check-theme(theme-bw(), "bw")
#_check-theme(theme-linedraw(), "linedraw")
#_check-theme(theme-light(), "light")
#_check-theme(theme-dark(), "dark")
#_check-theme(theme-test(), "test")

// Each theme must define the structural surfaces the renderer reads via
// resolve-element.
#let _structural = (
  "ink",
  "paper",
  "accent",
  "panel-background",
  "panel-grid",
  "axis-line",
)
#for t in (
  theme-bw(),
  theme-linedraw(),
  theme-light(),
  theme-dark(),
  theme-test(),
) {
  for k in _structural {
    assert(k in t, message: "theme " + t.name + " missing " + k)
  }
}

// theme-bw: white panel, light grey grid, black axes.
#let bw = theme-bw()
#assert.eq(bw.panel-background.fill, white)
#assert.eq(bw.axis-line.colour, black)
#assert(bw.panel-grid.colour != none)

// theme-linedraw: white panel, very faint grid, black axes.
#let ld = theme-linedraw()
#assert.eq(ld.panel-background.fill, white)
#assert.eq(ld.axis-line.colour, black)

// theme-test: red axes for easy visual identification.
#let tst = theme-test()
#assert.eq(tst.axis-line.colour, rgb("#cc0000"))

// Custom ink/paper propagate.
#let custom = theme-bw(ink: rgb("#222222"), paper: rgb("#fafafa"))
#assert.eq(custom.ink, rgb("#222222"))
#assert.eq(custom.paper, rgb("#fafafa"))
#assert.eq(custom.panel-background.fill, rgb("#fafafa"))

// ── Spot-overrides on complete themes ───────────────────────────────────────

// Element override on top of a preset replaces the surface record.
#let m1 = theme-minimal(axis-text: element-text(size: 11pt))
#assert.eq(m1.axis-text.size, 11pt)
#assert.eq(m1.panel-grid.colour, rgb("#ebebeb"))
#assert.eq(m1.name, "minimal")

// Structured rect override on theme-bw.
#let bw1 = theme-bw(panel-background: element-rect(fill: rgb("#ff9900")))
#assert.eq(bw1.panel-background.fill, rgb("#ff9900"))
#assert.eq(bw1.axis-line.colour, black)
#assert.eq(bw1.name, "bw")

// Structured text override on theme-classic.
#let c1 = theme-classic(axis-title: element-text(size: 14pt))
#assert.eq(c1.axis-title.size, 14pt)
#assert.eq(c1.panel-background.fill, white)
#assert.eq(c1.name, "classic")

// element-blank zeroes the targeted line on a complete theme.
#let v1 = theme-void(panel-grid: element-blank())
#assert.eq(v1.panel-grid.kind, "element-blank")

// Overrides survive merge-theme: the user value wins against the default.
#let g1 = theme-grey(panel-background: element-rect(fill: rgb("#abcdef")))
#assert.eq(g1.panel-background.fill, rgb("#abcdef"))
#let g1-merged = merge-theme(g1)
#assert.eq(g1-merged.panel-background.fill, rgb("#abcdef"))
#assert.eq(g1-merged.name, "grey")

// Multiple overrides combined in one call.
#let m2 = theme-minimal(
  axis-title: element-text(size: 14pt),
  panel-background: element-rect(fill: rgb("#f7f0e7")),
  panel-grid: element-line(colour: rgb("#d9cfbf")),
)
#assert.eq(m2.axis-title.size, 14pt)
#assert.eq(m2.panel-background.fill, rgb("#f7f0e7"))
#assert.eq(m2.panel-grid.colour, rgb("#d9cfbf"))

Extra theme tests passed.
