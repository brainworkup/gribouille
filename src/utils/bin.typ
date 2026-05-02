// Shared uniform-width binning helpers used by stat-bin and stat-bindot.
// Computes the canonical `(lo, hi, n-bins, width)` partition from a numeric
// vector and a `bins`/`binwidth` parameter pair, plus the per-value bin index.

// Compute `(lo, hi)` from a non-empty numeric vector. Spreads to `(lo, lo+1)`
// when all values are equal, so downstream computations don't divide by zero.
#let bin-domain(xs) = {
  let lo = calc.min(..xs)
  let hi = calc.max(..xs)
  if hi == lo { hi = lo + 1.0 }
  (lo, hi)
}

// Resolve `(n-bins, width)` from a domain and a `bins`/`binwidth` pair.
// `binwidth` wins when both are supplied; otherwise the domain is split into
// `bins` equal-width buckets.
#let bin-config(lo, hi, bins, binwidth) = {
  let n-bins = if binwidth != none and binwidth > 0 {
    calc.max(1, int(calc.ceil((hi - lo) / binwidth)))
  } else {
    bins
  }
  (n-bins: n-bins, width: (hi - lo) / n-bins)
}

// Assign `x` to the bin index containing it, clamped to `[0, n-bins - 1]`.
#let bin-of(x, lo, width, n-bins) = {
  let raw = int(calc.floor((x - lo) / width))
  calc.max(0, calc.min(n-bins - 1, raw))
}

// Midpoint of bin `i` over the partition starting at `lo` with bucket `width`.
#let bin-midpoint(lo, width, i) = lo + (i + 0.5) * width
