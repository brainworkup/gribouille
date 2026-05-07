// `stat-info(name)` covers every stat the dispatcher knows about, and
// `stat-bin` publishes `_count` and `density` columns.

#import "../../src/stat/info.typ": stat-info, stat-names
#import "../../src/stat/bin.typ" as bin-stat
#import "../../src/aes.typ": aes

// --- coverage: the names consumed by `apply-stat` ----------------------

#let _DISPATCHER-NAMES = (
  "identity",
  "bin",
  "bin_2d",
  "bin_hex",
  "bindot",
  "contour",
  "contour_filled",
  "count",
  "sum",
  "smooth",
  "boxplot",
  "summary",
  "summary_bin",
  "summary_2d",
  "summary_hex",
  "ecdf",
  "unique",
  "qq",
  "qq-line",
  "function",
  "ellipse",
  "quantile",
)
#for n in _DISPATCHER-NAMES {
  assert(
    stat-names().contains(n),
    message: "stat-info missing entry for '" + n + "'",
  )
}

// --- bin publishes `_count` and `density` ------------------------------

#let info = stat-info("bin")
#assert(info.outputs.contains("_count"))
#assert(info.outputs.contains("density"))
#assert(info.outputs.contains("y"))
#assert(info.outputs.contains("x"))
#assert(info.outputs.contains("width"))

#let raw = range(0, 20).map(i => (x: i * 0.5))
#let r = bin-stat.apply(raw, aes(x: "x"), params: (bins: 4, binwidth: none))
#let row = r.data.at(0)
#assert("_count" in row)
#assert("density" in row)
#let total = r.data.fold(0, (acc, b) => acc + b._count)
#assert.eq(total, raw.len())
#let dens-sum = r.data.fold(
  0,
  (acc, b) => acc + b.density * b.width,
)
#assert(calc.abs(dens-sum - 1.0) < 1e-9)

// --- count publishes `_count` -----------------------------------------

#let info-count = stat-info("count")
#assert(info-count.outputs.contains("_count"))

// --- unknown stat falls back to empty contract ------------------------

#let unk = stat-info("not-a-stat")
#assert.eq(unk.outputs, ())

stat-info tests passed.
