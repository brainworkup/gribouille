# Visual tests

Eyeball-checked plots, one `.typ` per geom or slice.

Workers drop a Typst file here when a slice introduces or changes a geom whose output is not adequately covered by `examples/`.
The file should be the smallest plot that exercises the new behaviour: synthetic inline data, single layer, no theme override unless theming is the subject.

## Naming

`<area>-<feature>.typ`, where `<area>` is `geom`, `stat`, `position`, `scale`, `facet`, `coord`, `theme`, or `guide`.
For example: `geom-jitter.typ`, `position-dodge-variable-width.typ`, `scale-colour-brewer.typ`.

## Workflow

1. Add the `.typ` file under `tests/visual/`.
2. Compile locally with `tools/check.sh` (or `typst compile <path>`).
3. Open the resulting PDF and visually verify against the matching plotnine reference plot.
4. Note in the slice's worker report what was checked and against which reference.

PDFs are not committed; they are build artefacts and ignored.

## Out of scope

Byte-for-byte golden-image diffing is not in place.
If a slice needs it, propose it as its own slice in the roadmap; do not add it ad hoc.
