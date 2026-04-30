// Unit tests for the typst() helper and aes-resolve helpers.

#import "../../src/utils/typst-markup.typ": (
  eval-as-markup, is-typst-markup, resolve-prose, typst,
)
#import "../../src/utils/aes-resolve.typ": (
  aes-col, resolve-aes-value, resolve-break-display, unwrap-mapping-refs,
)
#import "../../src/data.typ": as-factor, as-numeric

// typst() returns the expected tagged dictionary shape.
#let t = typst("col")
#assert.eq(t.kind, "typst-markup")
#assert.eq(t.source, "col")

// Composition with as-factor is preserved as a chain.
#let composed = typst(as-factor("col"))
#assert.eq(composed.kind, "typst-markup")
#assert.eq(composed.source.kind, "mapping-ref")
#assert.eq(composed.source.var, "col")
#assert.eq(composed.source.type, "discrete")

// is-typst-markup detects the tag at any nesting depth.
#assert.eq(is-typst-markup("col"), false)
#assert.eq(is-typst-markup(none), false)
#assert.eq(is-typst-markup(typst("col")), true)
#assert.eq(is-typst-markup(as-factor("col")), false)
#assert.eq(is-typst-markup(typst(as-factor("col"))), true)
#assert.eq(is-typst-markup(as-factor(typst("col"))), true)

// unwrap-mapping-refs strips mapping-refs but keeps typst-markup intact.
#assert.eq(unwrap-mapping-refs("col"), "col")
#assert.eq(unwrap-mapping-refs(as-factor("col")), "col")
#let unwrapped = unwrap-mapping-refs(typst("col"))
#assert.eq(unwrapped.kind, "typst-markup")
#assert.eq(unwrapped.source, "col")

// Composed unwrapping: typst(as-factor("col")) -> typst("col").
#let unwrapped-c = unwrap-mapping-refs(typst(as-factor("col")))
#assert.eq(unwrapped-c.kind, "typst-markup")
#assert.eq(unwrapped-c.source, "col")

// And the reverse composition: as-factor(typst("col")) -> typst("col").
#let unwrapped-r = unwrap-mapping-refs(as-factor(typst("col")))
#assert.eq(unwrapped-r.kind, "typst-markup")
#assert.eq(unwrapped-r.source, "col")

// aes-col returns the underlying column name from any spec shape.
#assert.eq(aes-col("col"), "col")
#assert.eq(aes-col(none), none)
#assert.eq(aes-col(as-factor("col")), "col")
#assert.eq(aes-col(typst("col")), "col")
#assert.eq(aes-col(typst(as-factor("col"))), "col")
#assert.eq(aes-col(as-factor(typst("col"))), "col")
#assert.eq(aes-col(as-numeric("col")), "col")

// resolve-aes-value in raw mode returns the underlying value, even for
// typst-tagged specs.
#let row = (col: "alpha", lab: "$beta$", n: 42)
#assert.eq(resolve-aes-value("col", row), "alpha")
#assert.eq(resolve-aes-value(typst("col"), row), "alpha")
#assert.eq(resolve-aes-value(as-factor("col"), row), "alpha")
#assert.eq(resolve-aes-value(typst(as-factor("col")), row), "alpha")

// resolve-aes-value in display mode eval's the value when the spec is
// typst-tagged. The eval'd content compares equal to direct evaluation.
#assert.eq(
  resolve-aes-value(typst("lab"), row, mode: "display"),
  eval("$beta$", mode: "markup"),
)
#assert.eq(
  resolve-aes-value(typst(as-factor("lab")), row, mode: "display"),
  eval("$beta$", mode: "markup"),
)

// In display mode without a typst tag, the raw value passes through.
#assert.eq(resolve-aes-value("lab", row, mode: "display"), "$beta$")
#assert.eq(
  resolve-aes-value(as-factor("lab"), row, mode: "display"),
  "$beta$",
)

// Missing column resolves to none in either mode.
#assert.eq(resolve-aes-value("missing", row), none)
#assert.eq(resolve-aes-value(typst("missing"), row, mode: "display"), none)

// resolve-prose passes strings, content, and none through unchanged.
#assert.eq(resolve-prose(none), none)
#assert.eq(resolve-prose("plain"), "plain")
#assert.eq(resolve-prose([content]), [content])

// resolve-prose evals a typst-tagged string source as markup.
#assert.eq(resolve-prose(typst("$alpha$")), eval("$alpha$", mode: "markup"))

// resolve-break-display only evals when the spec is typst-tagged.
#assert.eq(resolve-break-display("col", "$x$"), "$x$")
#assert.eq(
  resolve-break-display(typst("col"), "$x$"),
  eval("$x$", mode: "markup"),
)
#assert.eq(
  resolve-break-display(typst(as-factor("col")), "$x$"),
  eval("$x$", mode: "markup"),
)
#assert.eq(resolve-break-display(typst("col"), none), none)

// eval-as-markup handles non-string scalars by coercing to string first.
#assert.eq(eval-as-markup(42), eval("42", mode: "markup"))
#assert.eq(eval-as-markup(none), none)

typst-markup helper tests passed.
