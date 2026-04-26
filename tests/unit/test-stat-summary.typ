// stat-summary helpers and per-x reduction tests.

#import "../../src/stat/apply.typ": apply-stat
#import "../../src/utils/normal.typ": qnorm
#import "../../src/utils/summaries.typ": (
  mean-cl-normal, mean-sdl, mean-se, median-hilow, summarise,
)

// --- qnorm: Acklam's inverse-normal -----------------------------------------

#assert(calc.abs(qnorm(0.975) - 1.959964) < 1e-6)
#assert(calc.abs(qnorm(0.5)) < 1e-9)
#assert(calc.abs(qnorm(0.025) - (-1.959964)) < 1e-6)
// Tail symmetry: qnorm(1 - p) = -qnorm(p).
#assert(calc.abs(qnorm(0.99) + qnorm(0.01)) < 1e-6)

// --- mean-se on 1..5 -------------------------------------------------------
// mean = 3, sd (n-1) = sqrt(10/4) = sqrt(2.5) ≈ 1.5811
// se = sd / sqrt(5) ≈ 0.7071, so [ymin, ymax] ≈ [2.293, 3.707].

#let r-mse = mean-se((1, 2, 3, 4, 5))
#assert.eq(r-mse.y, 3.0)
#assert(calc.abs(r-mse.ymin - 2.292893) < 1e-4)
#assert(calc.abs(r-mse.ymax - 3.707107) < 1e-4)

// mult: 2 doubles the half-width.
#let r-mse2 = mean-se((1, 2, 3, 4, 5), mult: 2)
#assert.eq(r-mse2.y, 3.0)
#assert(
  calc.abs((r-mse2.ymax - r-mse2.ymin) - 2 * (r-mse.ymax - r-mse.ymin)) < 1e-9,
)

// --- mean-sdl on 1..5 ------------------------------------------------------
// Default mult = 2, sd ≈ 1.5811, so half-width ≈ 3.1623.

#let r-sdl = mean-sdl((1, 2, 3, 4, 5))
#assert.eq(r-sdl.y, 3.0)
#assert(calc.abs(r-sdl.ymin - (3 - 2 * 1.581139)) < 1e-4)
#assert(calc.abs(r-sdl.ymax - (3 + 2 * 1.581139)) < 1e-4)

// --- mean-cl-normal at 95 % ------------------------------------------------
// Half-width = 1.959964 * se.

#let r-cl = mean-cl-normal((1, 2, 3, 4, 5))
#assert.eq(r-cl.y, 3.0)
#assert(calc.abs(r-cl.ymax - (3 + 1.959964 * 0.707107)) < 1e-4)
#assert(calc.abs(r-cl.ymin - (3 - 1.959964 * 0.707107)) < 1e-4)

// conf = 0.99 must produce a strictly wider band than conf = 0.95.
#let r-cl-99 = mean-cl-normal((1, 2, 3, 4, 5), conf: 0.99)
#assert.eq(r-cl-99.y, 3.0)
#assert((r-cl-99.ymax - r-cl-99.ymin) > (r-cl.ymax - r-cl.ymin))
// Half-width matches z_{0.995} * se with z ≈ 2.5758.
#assert(calc.abs(r-cl-99.ymax - (3 + 2.5758293 * 0.707107)) < 1e-4)

// --- median-hilow with default conf = 0.5 (IQR) ----------------------------
// On 1..9 the type-7 quantiles are Q1=3, Q2=5, Q3=7.

#let r-mhl = median-hilow(range(1, 10))
#assert.eq(r-mhl.y, 5.0)
#assert.eq(r-mhl.ymin, 3.0)
#assert.eq(r-mhl.ymax, 7.0)

// conf = 0.25 -> tail = 0.375 -> ymin at sorted index 3 = 4, ymax at 5 = 6.
#let r-mhl-narrow = median-hilow(range(1, 10), conf: 0.25)
#assert.eq(r-mhl-narrow.ymin, 4.0)
#assert.eq(r-mhl-narrow.ymax, 6.0)

// --- empty input collapses to none ----------------------------------------

#let r-empty = mean-se(())
#assert.eq(r-empty.y, none)
#assert.eq(r-empty.ymin, none)
#assert.eq(r-empty.ymax, none)

#let r-non-numeric = median-hilow(("a", "b"))
#assert.eq(r-non-numeric.y, none)

// --- summarise dispatches by name (both spellings) ------------------------

#let r-dispatch-1 = summarise("mean_se", (1, 2, 3, 4, 5))
#assert.eq(r-dispatch-1.y, 3.0)
#let r-dispatch-2 = summarise("mean-se", (1, 2, 3, 4, 5))
#assert.eq(r-dispatch-2.y, 3.0)

// --- stat-summary: one row per x bucket -----------------------------------

#let df = (
  (g: "a", y: 1),
  (g: "a", y: 2),
  (g: "a", y: 3),
  (g: "a", y: 4),
  (g: "a", y: 5),
  (g: "b", y: 10),
  (g: "b", y: 12),
  (g: "b", y: 14),
)
#let r-stat = apply-stat(
  "summary",
  df,
  (x: "g", y: "y"),
  (fun: "mean_se", "fun-args": (:)),
)
#assert.eq(r-stat.data.len(), 2)
#assert.eq(r-stat.data.at(0).x, "a")
#assert.eq(r-stat.data.at(0).y, 3.0)
#assert(calc.abs(r-stat.data.at(0).ymin - 2.292893) < 1e-4)
#assert(calc.abs(r-stat.data.at(0).ymax - 3.707107) < 1e-4)
#assert.eq(r-stat.data.at(1).x, "b")
#assert.eq(r-stat.data.at(1).y, 12.0)

// Output mapping shape.
#assert.eq(r-stat.mapping.x, "x")
#assert.eq(r-stat.mapping.y, "y")
#assert.eq(r-stat.mapping.ymin, "ymin")
#assert.eq(r-stat.mapping.ymax, "ymax")

// --- stat-summary: numeric x is parsed -------------------------------------

#let df-num = range(0, 5).map(v => (x: 2, y: v))
#let r-stat-num = apply-stat(
  "summary",
  df-num,
  (x: "x", y: "y"),
  (fun: "mean_se", "fun-args": (:)),
)
#assert.eq(r-stat-num.data.at(0).x, 2.0)

// --- stat-summary-bin: per-bin reduction ----------------------------------

#let df-bin = range(0, 10).map(i => (x: i, y: i))
#let r-bin = apply-stat(
  "summary_bin",
  df-bin,
  (x: "x", y: "y"),
  (fun: "mean_se", bins: 2, binwidth: none, "fun-args": (:)),
)
#assert.eq(r-bin.data.len(), 2)
// First bin holds 0..4 with mean 2; second bin holds 5..9 with mean 7.
#assert.eq(r-bin.data.at(0).y, 2.0)
#assert.eq(r-bin.data.at(1).y, 7.0)

Stat summary tests passed.
