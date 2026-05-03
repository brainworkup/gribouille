// `stat-summary-2d`: bin (x, y) into a rectangular grid and reduce z values
// inside each cell to a single scalar.

#import "../../src/aes.typ": aes
#import "../../src/stat/summary-2d.typ": apply, stat-summary-2d

#let s = stat-summary-2d(fun: "mean", bins: 2)
#assert.eq(s.kind, "stat")
#assert.eq(s.name, "summary_2d")
#assert.eq(s.params.fun, "mean")
#assert.eq(s.params.bins, 2)

// `mean` reduction averages z within each cell.
#let raw = (
  (a: 0.5, b: 0.5, z: 1),
  (a: 0.7, b: 0.7, z: 3),
  (a: 1.5, b: 1.5, z: 10),
  (a: 1.5, b: 1.5, z: 20),
)
#let r-mean = apply(
  raw,
  aes(x: "a", y: "b", z: "z"),
  params: (fun: "mean", bins: 2),
)
#assert.eq(r-mean.mapping.fill, "value")
#assert.eq(r-mean.data.len(), 2)
// Bin (0,0) holds (1, 3) -> mean 2; bin (1,1) holds (10, 20) -> mean 15.
#let cell-00 = r-mean.data.filter(row => row.y < 1.0).at(0)
#assert.eq(cell-00.value, 2.0)
#let cell-11 = r-mean.data.filter(row => row.y > 1.0).at(0)
#assert.eq(cell-11.value, 15.0)

// `sum` reduction.
#let r-sum = apply(
  raw,
  aes(x: "a", y: "b", z: "z"),
  params: (fun: "sum", bins: 2),
)
#assert.eq(r-sum.data.filter(row => row.y > 1.0).at(0).value, 30)

// Callable `fun`.
#let r-fn = apply(
  raw,
  aes(x: "a", y: "b", z: "z"),
  params: (fun: xs => xs.len(), bins: 2),
)
#assert.eq(r-fn.data.filter(row => row.y > 1.0).at(0).value, 2)

// Missing `z` aesthetic returns an empty result.
#let r-noz = apply(
  raw,
  aes(x: "a", y: "b"),
  params: (fun: "mean", bins: 2),
)
#assert.eq(r-noz.data, ())

stat-summary-2d tests passed.
