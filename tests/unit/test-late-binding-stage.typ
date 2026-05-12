// `stage(start, after-stat, after-scale)` composes all three lanes for
// a single aesthetic. `stash-stages` strips markers so stat application
// sees plain column refs; `apply-stages` reapplies the after-stat and
// after-scale lanes against the post-stat rows.

#import "../../src/utils/late-binding.typ": (
  apply-stages, is-late-binding, late-binding-kind, late-binding-name, stage,
  stash-stages,
)

// --- constructor + predicates ------------------------------------------

#let m = stage(
  start: "sp",
  after-stat: "_count",
  after-scale: (c, _) => c,
)
#assert.eq(m.kind, "stage")
#assert.eq(m.start, "sp")
#assert.eq(m.at("after-stat"), "_count")
#assert.eq(type(m.at("after-scale")), function)
#assert(is-late-binding(m))
#assert.eq(late-binding-kind(m), "stage")

// --- stash-stages replaces markers with their start column --------------

#let mapping = (
  x: "x",
  fill: stage(start: "sp", after-scale: (c, _) => c.transparentize(50%)),
)
#let stash = stash-stages(mapping)
#assert.eq(stash.mapping.x, "x")
#assert.eq(stash.mapping.fill, "sp")
#assert("fill" in stash.stages)
#assert.eq(stash.stages.fill.kind, "stage")

// --- apply-stages re-emits an after-scale marker carrying source --------

#let rows = ((sp: "a"), (sp: "b"))
#let after = apply-stages(rows, stash.mapping, stash.stages, (:))
#assert.eq(after.mapping.fill.kind, "after-scale")
#assert.eq(after.mapping.fill.source, "sp")

// --- after-stat string lane rewrites the column ref --------------------

#let m2 = stage(start: "x", after-stat: "_count")
#let stash2 = stash-stages((y: m2))
#assert.eq(stash2.mapping.y, "x")
#let r2 = apply-stages(((x: 1, _count: 5),), stash2.mapping, stash2.stages, (:))
#assert.eq(r2.mapping.y, "_count")

// --- after-stat closure lane synthesises an `_as_<channel>` column ----

#let m3 = stage(start: "x", after-stat: (row, _) => row.x * 10)
#let stash3 = stash-stages((y: m3))
#let r3 = apply-stages(
  ((x: 1), (x: 2)),
  stash3.mapping,
  stash3.stages,
  (:),
)
#assert.eq(r3.mapping.y, "_as_y")
#assert.eq(r3.rows.at(0)._as_y, 10)
#assert.eq(r3.rows.at(1)._as_y, 20)

// --- title resolution prefers the post-stat lane, then the start column

#assert.eq(late-binding-name(stage(start: "g", after-stat: "_count")), "Count")
#assert.eq(late-binding-name(stage(start: "g")), "g")
#assert.eq(late-binding-name(stage(start: "g", after-stat: (r, _) => r.g)), "g")
#assert.eq(late-binding-name(stage()), none)

// --- empty stages dict is a no-op --------------------------------------

#let r4 = apply-stages(rows, (x: "x"), (:), (:))
#assert.eq(r4.rows, rows)
#assert.eq(r4.mapping.x, "x")

late-binding stage tests passed.
