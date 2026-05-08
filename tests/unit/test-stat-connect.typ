#import "../../src/stat/connect.typ": apply, stat-connect
#import "../../src/stat/info.typ": stat-info, stat-names

// Constructor shape.
#let s = stat-connect()
#assert.eq(s.kind, "stat")
#assert.eq(s.name, "connect")
#assert.eq(s.params.connection, "hv")

// Invalid mode panics.
// (cannot test panics directly; rely on compile-time mode validation in
// stat-connect signature - omitted here, smoke-tested via examples.)

#let d = (
  (x: 0, y: 0),
  (x: 1, y: 2),
  (x: 2, y: 1),
)
#let mapping = (x: "x", y: "y")

// hv: each gap inserts (x_{i+1}, y_i). 3 input -> 5 output.
#let r-hv = apply(d, mapping, params: (connection: "hv", na-rm: false))
#assert.eq(r-hv.data.len(), 5)
#assert.eq(r-hv.data.at(0), (x: 0, y: 0))
#assert.eq(r-hv.data.at(1), (x: 1, y: 0))
#assert.eq(r-hv.data.at(2), (x: 1, y: 2))
#assert.eq(r-hv.data.at(3), (x: 2, y: 2))
#assert.eq(r-hv.data.at(4), (x: 2, y: 1))

// vh: each gap inserts (x_i, y_{i+1}). 3 -> 5.
#let r-vh = apply(d, mapping, params: (connection: "vh", na-rm: false))
#assert.eq(r-vh.data.len(), 5)
#assert.eq(r-vh.data.at(1), (x: 0, y: 2))
#assert.eq(r-vh.data.at(3), (x: 1, y: 1))

// mid: each gap inserts (mid, y_i) and (mid, y_{i+1}). 3 -> 7.
#let r-mid = apply(d, mapping, params: (connection: "mid", na-rm: false))
#assert.eq(r-mid.data.len(), 7)
#assert.eq(r-mid.data.at(1), (x: 0.5, y: 0))
#assert.eq(r-mid.data.at(2), (x: 0.5, y: 2))
#assert.eq(r-mid.data.at(4), (x: 1.5, y: 2))
#assert.eq(r-mid.data.at(5), (x: 1.5, y: 1))

// linear: pass-through. 3 -> 3.
#let r-linear = apply(d, mapping, params: (connection: "linear", na-rm: false))
#assert.eq(r-linear.data.len(), 3)
#assert.eq(r-linear.data, d)

// Sorts by x before expansion.
#let unsorted = ((x: 2, y: 1), (x: 0, y: 0), (x: 1, y: 2))
#let r-sorted = apply(unsorted, mapping, params: (
  connection: "hv",
  na-rm: false,
))
#assert.eq(r-sorted.data.first().x, 0)
#assert.eq(r-sorted.data.last().x, 2)

// Other columns inherited from preceding row.
#let coloured = (
  (x: 0, y: 0, grp: "a"),
  (x: 1, y: 2, grp: "a"),
)
#let r-c = apply(coloured, mapping, params: (connection: "hv", na-rm: false))
#assert.eq(r-c.data.at(1).grp, "a")

// Single row passes through.
#let r-1 = apply(((x: 0, y: 0),), mapping, params: (
  connection: "hv",
  na-rm: false,
))
#assert.eq(r-1.data.len(), 1)

// Registered in stat-info / stat-names.
#assert.eq(stat-info("connect").outputs, ("x", "y"))
#assert("connect" in stat-names())
