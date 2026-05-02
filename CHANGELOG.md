# Changelog

## Unreleased

- feat: initial version of Gribouille.
- feat(scale): `expand:` on positional scales now accepts Typst `ratio` (`5%`), `length` (`5pt`), or `relative` (`5pt + 5%`) values, plus a `(lo, hi)` 2-tuple for asymmetric padding.
  Lengths add canvas-space padding inside the panel rather than data-unit padding outside the domain.
- feat(geom-mark): `expand:` accepts a Typst length (`5pt`, `0.5cm`) and applies the padding in canvas space, so the halo is consistent across non-linear scales and aspect-ratio differences.
  The default changes from `0.1` data units to `0pt`.
- BREAKING(scale): `expansion()` helper removed.
  Replace `expansion(mult: 0.1)` with `10%`, `expansion(mult: (0, 0.1))` with `(0%, 10%)`, and `expansion(add: ...)` with the equivalent length form.
- BREAKING(geom-mark): `expand:` no longer accepts bare numbers; pass a length such as `5pt`.
