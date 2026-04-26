// Trans-aware pretty break helpers.
//
// `pretty-log10` emits powers-of-10 breaks within the closed interval, falling
// back to 2x and 5x sub-decade breaks when fewer than three decades fit.
// `pretty-sqrt` mirrors linear pretty on the sqrt-transformed domain so ticks
// space evenly in display coordinates.

#import "../../src/utils/pretty.typ": pretty, pretty-log10, pretty-sqrt

// --- pretty-log10: full decades ---

#let span = pretty-log10(1, 1000)
#assert.eq(span.len(), 4)
#assert.eq(span.at(0), 1.0)
#assert.eq(span.at(1), 10.0)
#assert.eq(span.at(2), 100.0)
#assert.eq(span.at(3), 1000.0)

// --- pretty-log10: sub-decade fallback (less than three decades) ---

#let small = pretty-log10(1, 5)
#assert.eq(small, (1.0, 2.0, 5.0))

// Spans a single decade boundary: 1, 2, 5, 10, 20, 50 within [1, 50].
#let mid = pretty-log10(1, 50)
#assert.eq(mid, (1.0, 2.0, 5.0, 10.0, 20.0, 50.0))

// --- pretty-log10: undefined log domain falls back to linear ---

#let neg = pretty-log10(-1, 10)
#assert.eq(neg, pretty(-1, 10, n: 5))

// --- pretty-sqrt: ticks square back from sqrt-domain pretty ---

#let sq = pretty-sqrt(0, 100)
#assert.eq(sq.at(0), 0.0)
#assert.eq(sq.at(sq.len() - 1), 100.0)

// --- pretty-sqrt: negative lo falls back to linear ---

#let sq-neg = pretty-sqrt(-1, 9)
#assert.eq(sq-neg, pretty(-1, 9, n: 5))

Pretty log/sqrt tests passed.
