// Unit tests for the resolution helper.

#import "../../src/utils/resolution.typ": resolution

// With zero: true (default), zero is added to the values; sorted unique
// becomes (0, 1, 3, 7) and the smallest non-zero gap is 1.
#assert.eq(resolution((1, 3, 7)), 1)

// With zero: false, only consecutive diffs of (5, 10, 15) count -> 5.
#assert.eq(resolution((5, 10, 15), zero: false), 5)

// Single distinct value -> fallback resolution of 1.
#assert.eq(resolution((4,), zero: false), 1)

// Empty input -> fallback resolution of 1.
#assert.eq(resolution((), zero: false), 1)

// Repeated values are deduplicated; gaps come from unique sorted values.
#assert.eq(resolution((2, 2, 2, 5), zero: false), 3)

// Non-numeric and none entries are dropped.
#assert.eq(resolution((1, "x", none, 3, 7), zero: false), 2)

Resolution helper tests passed.
