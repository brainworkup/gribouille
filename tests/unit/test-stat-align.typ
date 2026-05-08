#import "../../src/stat/align.typ": apply, setup, stat-align
#import "../../src/stat/info.typ": stat-info, stat-names

#let s = stat-align()
#assert.eq(s.kind, "stat")
#assert.eq(s.name, "align")
#assert.eq(s.params, (:))

// Two groups on disjoint x ranges; setup builds the union grid.
#let d = (
  (x: 0, y: 1, k: "a"),
  (x: 2, y: 3, k: "a"),
  (x: 1, y: 2, k: "b"),
  (x: 3, y: 1, k: "b"),
)
#let mapping = (x: "x", y: "y", colour: "k")
#let resolved = setup(d, mapping, params: (:))
#assert.eq(type(resolved.unique-loc), array)
#assert(resolved.unique-loc.len() > 0)
#assert(0 in resolved.unique-loc)
#assert(1 in resolved.unique-loc)
#assert(2 in resolved.unique-loc)
#assert(3 in resolved.unique-loc)

// Group "a" gets interpolated values at x=1 (between 0 and 2).
#let group-a = ((x: 0, y: 1, k: "a"), (x: 2, y: 3, k: "a"))
#let r-a = apply(group-a, mapping, params: resolved)
// Output: leading zero, interpolated points (loc in [0, 2]), trailing zero.
// At x=1 (in unique-loc), interpolation gives y = 1 + (3-1)/(2-0)*(1-0) = 2.
#let interp-at-1 = r-a.data.filter(r => r.x == 1)
#assert.eq(interp-at-1.len(), 1)
#assert.eq(interp-at-1.first().y, 2.0)
#assert.eq(r-a.data.first().y, 0)
#assert.eq(r-a.data.last().y, 0)

// Group "b" interpolated at x=2 between (1,2) and (3,1) -> y = 2 + (1-2)/(3-1)*(2-1) = 1.5
#let group-b = ((x: 1, y: 2, k: "b"), (x: 3, y: 1, k: "b"))
#let r-b = apply(group-b, mapping, params: resolved)
#let interp-at-2 = r-b.data.filter(r => r.x == 2)
#assert.eq(interp-at-2.len(), 1)
#assert.eq(interp-at-2.first().y, 1.5)

// Out-of-range locs are dropped: group "a" range is [0, 2] so loc=3 not present.
#let above-2 = r-a.data.filter(r => r.x == 3)
#assert.eq(above-2.len(), 0)

// Trailing pad inherits per-row aesthetics from the LAST row, leading from
// the FIRST. Verified via the `k` aesthetic when the two rows differ.
#let mixed = ((x: 0, y: 1, tag: "head"), (x: 2, y: 3, tag: "tail"))
#let r-mixed = apply(
  mixed,
  (x: "x", y: "y"),
  params: resolved,
)
#assert.eq(r-mixed.data.first().tag, "head")
#assert.eq(r-mixed.data.last().tag, "tail")

// Zero-crossing inserted within a group with sign change.
#let crossing-data = (
  (x: 0, y: 1, k: "a"),
  (x: 1, y: -1, k: "a"),
  (x: 2, y: 1, k: "a"),
)
#let resolved-c = setup(
  crossing-data,
  (x: "x", y: "y", colour: "k"),
  params: (:),
)
#assert(0.5 in resolved-c.unique-loc)
#assert(1.5 in resolved-c.unique-loc)

// Duplicate-x rows are collapsed (mean y) before interpolation.
#let dup = ((x: 1, y: 2), (x: 1, y: 6), (x: 3, y: 0))
#let r-dup = apply(
  dup,
  (x: "x", y: "y"),
  params: (unique-loc: (1, 2, 3), adjust: 0.1),
)
// Collapsed: x=1 -> y=4 (mean of 2 and 6), x=3 -> y=0. At x=2: 4 + (0-4)/2 = 2.
#let r-2 = r-dup.data.filter(r => r.x == 2)
#assert.eq(r-2.first().y, 2.0)

#assert.eq(stat-info("align").outputs, ("x", "y"))
#assert("align" in stat-names())
