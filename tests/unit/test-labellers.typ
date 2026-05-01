// Labeller string formatting.
//
// Verifies that each labeller produces the expected strip text for a
// representative (var, level, count) input. Compound labellers route by
// variable name and fall back to a default for missing keys.

#import "../../src/facet/labellers.typ" as lab

// label-value: returns the level as-is, ignoring var and count.
#assert.eq(lab.format(lab.label-value(), "cyl", "6"), "6")
#assert.eq(lab.format(lab.label-value(), "cyl", "8", count: 11), "8")

// label-both: shows "var: level" with the configured separator.
#assert.eq(lab.format(lab.label-both(), "cyl", "6"), "cyl: 6")
#assert.eq(lab.format(lab.label-both(sep: " = "), "cyl", "6"), "cyl = 6")

// label-context: appends the row count when the renderer supplies one,
// otherwise falls back to the bare level.
#assert.eq(
  lab.format(lab.label-context(), "cyl", "6", count: 7),
  "6 (n = 7)",
)
#assert.eq(lab.format(lab.label-context(), "cyl", "6"), "6")

// label-wrap-gen: hard-splits on whitespace at or before the limit.
#let wrapped = lab.format(lab.label-wrap-gen(width: 5), "x", "hello world")
#assert.eq(wrapped, "hello\nworld")

// label-wrap-gen with no usable space: hard split at the width.
#let hard = lab.format(lab.label-wrap-gen(width: 4), "x", "abcdefgh")
#assert.eq(hard, "abcd\nefgh")

// label-wrap-gen with an inner labeller composes the two transformations.
#let composed = lab.format(
  lab.label-wrap-gen(width: 4, inner: lab.label-both()),
  "cyl",
  "8",
)
#assert.eq(composed, "cyl:\n8")

// labeller: routes by variable, falling back to its default.
#let comp = lab.labeller(
  rules: (cyl: lab.label-both(), gear: lab.label-value()),
)
#assert.eq(lab.format(comp, "cyl", "6"), "cyl: 6")
#assert.eq(lab.format(comp, "gear", "4"), "4")
// Variable not in rules: default labeller (label-value) wins.
#assert.eq(lab.format(comp, "vs", "1"), "1")

// labeller with explicit default still routes known variables.
#let comp2 = lab.labeller(
  rules: (cyl: lab.label-value()),
  default: lab.label-both(),
)
#assert.eq(lab.format(comp2, "cyl", "6"), "6")
#assert.eq(lab.format(comp2, "vs", "1"), "vs: 1")

Labeller tests passed.
