#import "../../src/stat/manual.typ": apply, stat-manual
#import "../../src/stat/apply.typ": apply-stat
#import "../../src/stat/info.typ": stat-info, stat-names

// Constructor shape.
#let s = stat-manual()
#assert.eq(s.kind, "stat")
#assert.eq(s.name, "manual")
#assert.eq(type(s.params.fun), function)

// Default closure passes data through unchanged.
#let d = ((x: 1, y: 2), (x: 2, y: 4))
#let r = apply(d, (x: "x", y: "y"))
#assert.eq(r.data, d)

// Custom closure transforms rows.
#let with-index = data => data.enumerate().map(((i, r)) => r + (idx: i + 1))
#let s2 = stat-manual(fun: with-index)
#let r2 = apply(d, (x: "x", y: "y"), params: s2.params)
#assert.eq(r2.data.at(0).idx, 1)
#assert.eq(r2.data.at(1).idx, 2)
#assert.eq(r2.mapping, (x: "x", y: "y"))

// Dispatched via apply-stat.
#let r3 = apply-stat("manual", d, (x: "x", y: "y"), s2.params)
#assert.eq(r3.data.at(1).idx, 2)

// Registered in stat-info / stat-names.
#assert.eq(stat-info("manual").outputs, ())
#assert("manual" in stat-names())
