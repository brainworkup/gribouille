// `stat-summary-hex`: bin (x, y) into a hex grid and reduce z values
// inside each cell to a single scalar.

#import "../../src/aes.typ": aes
#import "../../src/stat/summary-hex.typ": apply, stat-summary-hex

#let s = stat-summary-hex(fun: "sum", bins: 4)
#assert.eq(s.kind, "stat")
#assert.eq(s.name, "summary_hex")
#assert.eq(s.params.fun, "sum")

// Two near-duplicate points fall in the same cell; their z values reduce.
#let raw = (
  (a: 0.1, b: 0.1, z: 1),
  (a: 0.12, b: 0.11, z: 4),
  (a: 2.0, b: 2.0, z: 7),
)
#let r = apply(
  raw,
  aes(x: "a", y: "b", z: "z"),
  params: (fun: "sum", bins: 4),
)
#assert.eq(r.mapping.fill, "_value")
#assert.eq(r.data.len(), 2)
#let total = r.data.fold(0, (acc, row) => acc + row._value)
#assert.eq(total, 12)
// Geom hint propagated.
#assert("_hex-dx" in r.data.first())

// Missing z -> empty result.
#let r-noz = apply(
  raw,
  aes(x: "a", y: "b"),
  params: (fun: "mean", bins: 4),
)
#assert.eq(r-noz.data, ())

// Callable fun.
#let r-fn = apply(
  raw,
  aes(x: "a", y: "b", z: "z"),
  params: (fun: xs => xs.len(), bins: 4),
)
#let counts = r-fn.data.map(row => row._value).sorted()
#assert.eq(counts, (1, 2))

stat-summary-hex tests passed.
