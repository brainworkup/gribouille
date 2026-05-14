// Unit tests for the format-* formatter helpers.

#import "../../src/utils/format.typ": (
  format-comma, format-currency, format-lower, format-number, format-percent,
  format-scientific, format-title, format-upper, format-wrap,
)
#import "../../src/utils/typst-markup.typ": is-typst-markup

// format-number: thousands separator, decimal handling.
#let n = format-number()
#assert.eq(n(1234.56), "1,234.56")
#assert.eq(n(1000000), "1,000,000")
#assert.eq(n(0), "0")
#assert.eq(n(-1234), "-1,234")
#assert.eq(n(none), none)

// Custom marks (e.g., French).
#let n-fr = format-number(big-mark: " ", decimal-mark: ",")
#assert.eq(n-fr(1234.5), "1 234,5")

// Fixed digits.
#let n-2 = format-number(digits: 2)
#assert.eq(n-2(1.0), "1.00")
#assert.eq(n-2(1.235), "1.24")

// format-comma is a thin shorthand.
#let c = format-comma()
#assert.eq(c(1234), "1,234")

// format-percent.
#let p = format-percent()
#assert.eq(p(0.25), "25%")
#assert.eq(p(1), "100%")
#let p-d = format-percent(digits: 1)
#assert.eq(p-d(0.123), "12.3%")

// format-currency.
#let cur = format-currency()
#assert.eq(cur(12.5), "$12.50")
#assert.eq(cur(1234), "$1,234.00")
#let euro = format-currency(symbol: "€", big-mark: ".", decimal-mark: ",")
#assert.eq(euro(1234.5), "€1.234,50")

// format-scientific returns a typst()-tagged value for out-of-range
// magnitudes; in-range values format as plain numbers.
#let sci = format-scientific()
#assert.eq(is-typst-markup(sci(1.23e-5)), true)
#assert.eq(is-typst-markup(sci(1234567.89)), true)
// In-range still wraps with typst() (consistent type) but the math is plain.
#assert.eq(is-typst-markup(sci(12.34)), true)
#assert.eq(sci(0).source, "$0$")

// Case helpers.
#let title = format-title()
#assert.eq(title("hello world"), "Hello World")
#assert.eq(title("aLpHa"), "Alpha")
#assert.eq(title(""), "")
#assert.eq(title(none), none)

#let upper = format-upper()
#assert.eq(upper("hello"), "HELLO")
#assert.eq(upper("MiXeD"), "MIXED")

#let lower = format-lower()
#assert.eq(lower("HELLO"), "hello")
#assert.eq(lower("MiXeD"), "mixed")

// format-wrap inserts newlines at word boundaries.
#let wrap = format-wrap(width: 10)
#assert.eq(wrap("short"), "short")
#assert.eq(wrap("hello world foo"), "hello\nworld foo")

format helper tests passed.
