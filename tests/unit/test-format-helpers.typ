// Unit tests for the label-* formatter helpers.

#import "../../src/utils/format.typ": (
  label-comma, label-currency, label-lower, label-number, label-percent,
  label-scientific, label-title, label-upper, label-wrap,
)
#import "../../src/utils/typst-markup.typ": is-typst-markup

// label-number: thousands separator, decimal handling.
#let n = label-number()
#assert.eq(n(1234.56), "1,234.56")
#assert.eq(n(1000000), "1,000,000")
#assert.eq(n(0), "0")
#assert.eq(n(-1234), "-1,234")
#assert.eq(n(none), none)

// Custom marks (e.g. French).
#let n-fr = label-number(big-mark: " ", decimal-mark: ",")
#assert.eq(n-fr(1234.5), "1 234,5")

// Fixed digits.
#let n-2 = label-number(digits: 2)
#assert.eq(n-2(1.0), "1.00")
#assert.eq(n-2(1.235), "1.24")

// label-comma is a thin shorthand.
#let c = label-comma()
#assert.eq(c(1234), "1,234")

// label-percent.
#let p = label-percent()
#assert.eq(p(0.25), "25%")
#assert.eq(p(1), "100%")
#let p-d = label-percent(digits: 1)
#assert.eq(p-d(0.123), "12.3%")

// label-currency.
#let cur = label-currency()
#assert.eq(cur(12.5), "$12.50")
#assert.eq(cur(1234), "$1,234.00")
#let euro = label-currency(symbol: "€", big-mark: ".", decimal-mark: ",")
#assert.eq(euro(1234.5), "€1.234,50")

// label-scientific returns a typst()-tagged value for out-of-range
// magnitudes; in-range values format as plain numbers.
#let sci = label-scientific()
#assert.eq(is-typst-markup(sci(1.23e-5)), true)
#assert.eq(is-typst-markup(sci(1234567.89)), true)
// In-range still wraps with typst() (consistent type) but the math is plain.
#assert.eq(is-typst-markup(sci(12.34)), true)
#assert.eq(sci(0).source, "$0$")

// Case helpers.
#let title = label-title()
#assert.eq(title("hello world"), "Hello World")
#assert.eq(title("aLpHa"), "Alpha")
#assert.eq(title(""), "")
#assert.eq(title(none), none)

#let upper = label-upper()
#assert.eq(upper("hello"), "HELLO")
#assert.eq(upper("MiXeD"), "MIXED")

#let lower = label-lower()
#assert.eq(lower("HELLO"), "hello")
#assert.eq(lower("MiXeD"), "mixed")

// label-wrap inserts newlines at word boundaries.
#let wrap = label-wrap(width: 10)
#assert.eq(wrap("short"), "short")
#assert.eq(wrap("hello world foo"), "hello\nworld foo")

label formatter helper tests passed.
