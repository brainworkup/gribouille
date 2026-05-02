// stat-bindot: per-observation rows with stack index and bin midpoint.

#import "../../src/stat/bindot.typ": apply, stat-bindot

#let s = stat-bindot()
#assert.eq(s.kind, "stat")
#assert.eq(s.name, "bindot")
#assert.eq(s.params.bins, 30)
#assert.eq(s.params.binwidth, none)
#assert.eq(s.params.stackratio, 1.0)

#let s2 = stat-bindot(bins: 10, binwidth: 0.5, stackratio: 1.5)
#assert.eq(s2.params.bins, 10)
#assert.eq(s2.params.binwidth, 0.5)
#assert.eq(s2.params.stackratio, 1.5)

// Apply: one row per observation. Three rows fall into bin 0, one into bin 3.
#let data = (
  (x: 0.0),
  (x: 0.1),
  (x: 0.2),
  (x: 3.0),
)
#let r = apply(data, (x: "x"), params: (bins: 4, stackratio: 1.0))
#assert.eq(r.data.len(), 4)
// Bin 0 spans [0, 0.75), midpoint 0.375. Bin 3 spans [2.25, 3.0], midpoint 2.625.
#assert.eq(r.data.at(0).x, 0.375)
#assert.eq(r.data.at(0).y, 0.5)
#assert.eq(r.data.at(0).bin-count, 3)
#assert.eq(r.data.at(1).x, 0.375)
#assert.eq(r.data.at(1).y, 1.5)
#assert.eq(r.data.at(2).x, 0.375)
#assert.eq(r.data.at(2).y, 2.5)
#assert.eq(r.data.at(3).x, 2.625)
#assert.eq(r.data.at(3).y, 0.5)
#assert.eq(r.data.at(3).bin-count, 1)

// stackratio scales the y spacing.
#let r2 = apply(data, (x: "x"), params: (bins: 4, stackratio: 2.0))
#assert.eq(r2.data.at(0).y, 1.0)
#assert.eq(r2.data.at(1).y, 3.0)
#assert.eq(r2.data.at(2).y, 5.0)

// Width matches the bin span.
#assert.eq(r.data.at(0).width, 3.0 / 4)

stat-bindot tests passed.
