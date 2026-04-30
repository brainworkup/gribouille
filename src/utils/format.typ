// Label formatter helpers for the `labels:` callback on scales.
//
// Each helper returns a closure suitable for `scale-*(labels: ...)`. The
// closure takes a single break value and returns either a plain string,
// content, or a `typst()`-tagged value when it produces math markup.
//
// Compose freely with `typst()` on the aes side: when the originating
// aesthetic mapping is typst-tagged, plain-string callback returns are
// wrapped automatically by the render path so they evaluate as markup.

#import "./types.typ": parse-number
#import "./typst-markup.typ": typst

#let _format-number-impl(n, big-mark: ",", decimal-mark: ".", digits: auto) = {
  if n == none { return none }
  let value = if type(n) == str { parse-number(n) } else { n }
  if value == none { return str(n) }
  let abs-val = if value < 0 { -value } else { value }
  let rounded = if digits == auto { value } else {
    calc.round(value, digits: int(digits))
  }
  let abs-rounded = if rounded < 0 { -rounded } else { rounded }
  let int-part = int(abs-rounded)
  let frac-part = abs-rounded - int-part
  let int-str = str(int-part)
  let with-sep = if big-mark == "" { int-str } else {
    let chars = int-str.clusters().rev()
    let groups = ()
    let buf = ""
    for (i, c) in chars.enumerate() {
      buf = c + buf
      if calc.rem(i + 1, 3) == 0 and i + 1 < chars.len() {
        groups.push(buf)
        buf = ""
      }
    }
    if buf != "" { groups.push(buf) }
    groups.rev().join(big-mark)
  }
  let frac-str = if (digits == auto and frac-part == 0) or digits == 0 {
    ""
  } else {
    let d = if digits == auto { 6 } else { int(digits) }
    let scaled = calc.round(frac-part * calc.pow(10, d))
    let s = str(int(scaled))
    while s.len() < d { s = "0" + s }
    if digits == auto {
      while s.len() > 0 and s.ends-with("0") {
        s = s.slice(0, s.len() - 1)
      }
      if s == "" { "" } else { decimal-mark + s }
    } else {
      decimal-mark + s
    }
  }
  let sign = if value < 0 { "-" } else { "" }
  sign + with-sep + frac-str
}

/// Format a numeric break with optional thousands separator and fixed
/// decimals.
///
/// Returns a closure suitable for `scale-*(labels: ...)`. Non-numeric
/// values pass through `str()`.
///
/// \@category Helpers
/// \@stability stable
/// \@since 0.1.0
///
/// \@param big-mark Thousands separator (e.g. `","` for English).
/// \@param decimal-mark Decimal separator (e.g. `"."` for English).
/// \@param digits Decimal digits to keep, or `auto` to drop trailing zeros.
/// \@param prefix String prepended to every formatted value.
/// \@param suffix String appended to every formatted value.
///
/// \@returns A closure `value => string`.
///
/// \@examples Format y-axis breaks with English thousands separators.
/// ```
/// #plot(
///   data: ((x: 1, y: 1234.5), (x: 2, y: 23456.7)),
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(),),
///   scales: (scale-y-continuous(labels: label-number()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
#let label-number(
  big-mark: ",",
  decimal-mark: ".",
  digits: auto,
  prefix: "",
  suffix: "",
) = value => {
  let formatted = _format-number-impl(
    value,
    big-mark: big-mark,
    decimal-mark: decimal-mark,
    digits: digits,
  )
  if formatted == none { return none }
  prefix + formatted + suffix
}

/// Shorthand for `label-number(big-mark: ",")`.
///
/// \@category Helpers
/// \@stability stable
/// \@since 0.1.0
#let label-comma(digits: auto, prefix: "", suffix: "") = label-number(
  big-mark: ",",
  decimal-mark: ".",
  digits: digits,
  prefix: prefix,
  suffix: suffix,
)

/// Format a numeric break as a percentage.
///
/// Multiplies the value by `scale` (default `100`) before formatting and
/// appends `suffix`.
///
/// \@category Helpers
/// \@stability stable
/// \@since 0.1.0
///
/// \@param scale Multiplier applied before formatting.
/// \@param suffix Trailing string (default `"%"`).
/// \@param big-mark Thousands separator.
/// \@param decimal-mark Decimal separator.
/// \@param digits Decimal digits to keep.
#let label-percent(
  scale: 100,
  suffix: "%",
  big-mark: "",
  decimal-mark: ".",
  digits: 0,
) = value => {
  if value == none { return none }
  let v = if type(value) == str { parse-number(value) } else { value }
  if v == none { return str(value) }
  (
    _format-number-impl(
      v * scale,
      big-mark: big-mark,
      decimal-mark: decimal-mark,
      digits: digits,
    )
      + suffix
  )
}

/// Format a numeric break as currency.
///
/// Defaults to a leading dollar sign and English thousands separator.
///
/// \@category Helpers
/// \@stability stable
/// \@since 0.1.0
///
/// \@param symbol Currency symbol prepended to the value.
/// \@param big-mark Thousands separator.
/// \@param decimal-mark Decimal separator.
/// \@param digits Decimal digits to keep.
#let label-currency(
  symbol: "$",
  big-mark: ",",
  decimal-mark: ".",
  digits: 2,
) = value => {
  let formatted = _format-number-impl(
    value,
    big-mark: big-mark,
    decimal-mark: decimal-mark,
    digits: digits,
  )
  if formatted == none { return none }
  symbol + formatted
}

/// Format a numeric break in scientific notation as Typst math.
///
/// Returns a `typst()`-tagged string so the render path evaluates the
/// result as Typst math markup. Values within `[10^(-3), 10^3)` are
/// formatted as plain numbers via `label-number`.
///
/// \@category Helpers
/// \@stability stable
/// \@since 0.1.0
///
/// \@param digits Significant decimal digits in the mantissa.
#let label-scientific(digits: 2) = value => {
  if value == none { return none }
  let v = if type(value) == str { parse-number(value) } else { value }
  if v == none { return str(value) }
  if v == 0 { return typst("$0$") }
  let abs-v = if v < 0 { -v } else { v }
  if abs-v >= 1e-3 and abs-v < 1e3 {
    let formatted = _format-number-impl(v, digits: digits)
    return typst("$" + formatted + "$")
  }
  let exp = int(calc.floor(calc.log(abs-v, base: 10)))
  let mantissa = v / calc.pow(10, exp)
  let m-str = _format-number-impl(mantissa, digits: digits)
  typst("$" + m-str + " times 10^(" + str(exp) + ")$")
}

#let _ascii-upper = (
  ("a", "A"),
  ("b", "B"),
  ("c", "C"),
  ("d", "D"),
  ("e", "E"),
  ("f", "F"),
  ("g", "G"),
  ("h", "H"),
  ("i", "I"),
  ("j", "J"),
  ("k", "K"),
  ("l", "L"),
  ("m", "M"),
  ("n", "N"),
  ("o", "O"),
  ("p", "P"),
  ("q", "Q"),
  ("r", "R"),
  ("s", "S"),
  ("t", "T"),
  ("u", "U"),
  ("v", "V"),
  ("w", "W"),
  ("x", "X"),
  ("y", "Y"),
  ("z", "Z"),
)

#let _to-upper(s) = {
  let out = s
  for (lo, hi) in _ascii-upper { out = out.replace(lo, hi) }
  out
}

#let _to-lower(s) = {
  let out = s
  for (lo, hi) in _ascii-upper { out = out.replace(hi, lo) }
  out
}

/// Title-case a string break: capitalise the first letter of each
/// space-separated word.
///
/// \@category Helpers
/// \@stability stable
/// \@since 0.1.0
#let label-title() = value => {
  if value == none { return none }
  let s = str(value)
  if s == "" { return s }
  let words = s.split(" ")
  let out = words.map(w => {
    if w == "" { return w }
    let first = w.first()
    let rest = w.slice(1)
    _to-upper(first) + _to-lower(rest)
  })
  out.join(" ")
}

/// Upper-case a string break (ASCII letters only).
///
/// \@category Helpers
/// \@stability stable
/// \@since 0.1.0
#let label-upper() = value => {
  if value == none { return none }
  _to-upper(str(value))
}

/// Lower-case a string break (ASCII letters only).
///
/// \@category Helpers
/// \@stability stable
/// \@since 0.1.0
#let label-lower() = value => {
  if value == none { return none }
  _to-lower(str(value))
}

/// Soft-wrap a long string break by inserting a newline every `width`
/// characters at word boundaries.
///
/// \@category Helpers
/// \@stability stable
/// \@since 0.1.0
///
/// \@param width Maximum line width in characters.
#let label-wrap(width: 20) = value => {
  if value == none { return none }
  let s = str(value)
  if s.len() <= width { return s }
  let words = s.split(" ")
  let lines = ()
  let line = ""
  for w in words {
    if line == "" {
      line = w
    } else if line.len() + 1 + w.len() <= width {
      line = line + " " + w
    } else {
      lines.push(line)
      line = w
    }
  }
  if line != "" { lines.push(line) }
  lines.join("\n")
}
