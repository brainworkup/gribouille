# Visual tests

Two layers:

1. **Eyeball plots** (this directory, top-level `*.typ`).
   One file per geom or slice when the change is not adequately covered by `examples/`.
2. **Golden snapshots** (`golden/`).
   PNGs committed under `golden/examples/` and `golden/docstrings/`, diffed in CI against fresh compiles of `examples/*.typ` and `/// @examples` fences extracted from `src/`.

## Eyeball plots

Smallest plot that exercises the new behaviour: synthetic inline data, single layer, no theme override unless theming is the subject.

### Naming

`<area>-<feature>.typ`, where `<area>` is `geom`, `stat`, `position`, `scale`, `facet`, `coord`, `theme`, or `guide`.
For example: `geom-jitter.typ`, `position-dodge-variable-width.typ`, `scale-colour-brewer.typ`.

### Workflow

1. Add the `.typ` file under `tests/visual/`.
2. Compile locally with `tools/check.sh` (or `typst compile <path>`).
3. Open the resulting PDF and visually verify against the matching plotnine reference plot.
4. Note in the slice's worker report what was checked and against which reference.

PDFs are not committed; they are build artefacts and ignored.

## Golden snapshots

Harness: `tools/snapshot/run.lua`.
Reuses the typstdoc parser to extract every renderable `/// @examples` fence into a temporary wrapped `.typ`, compiles each file (plus every `examples/*.typ`) to a PNG at 144 ppi, and diffs the result against the committed golden with `magick compare -metric AE -fuzz 1%`.

Goldens live under `golden/examples/<name>.png` and `golden/docstrings/<fn>-<idx>.png`.

### Check mode (CI default)

```
lua tools/snapshot/run.lua --check
```

Exits non-zero if any compile fails, any golden is missing, or any image differs from its golden.
Diff PNGs are written to `build/snapshot/diff/` (gitignored).

### Update mode

```
lua tools/snapshot/run.lua --update
```

Recompiles everything and overwrites the goldens.
Run this when the visual change is intentional; commit the updated PNGs in the same commit as the code change.

### Reproducibility

Golden images are generated on Linux with a pinned Typst version (read from `typst.toml`) and a pinned font set installed in CI.
Local macOS or Windows renders will not match byte-for-byte; treat the harness as Linux-only and rely on CI as the source of truth.

### Bootstrap and refresh

To regenerate the goldens after a deliberate change, trigger the `Visual snapshots — refresh` workflow (`workflow_dispatch`).
It runs `--update`, commits the result, and pushes back to the branch.

### Useful flags

| Flag             | Default | Purpose                                                                       |
| ---------------- | ------- | ----------------------------------------------------------------------------- |
| `--check`        | on      | Compare current compile to golden.                                            |
| `--update`       | off     | Overwrite goldens with fresh compile.                                         |
| `--ppi <n>`      | 144     | Raster density passed to `typst compile`.                                     |
| `--tolerance <n>`| 0       | Max AE pixel count tolerated per image.                                       |
| `--fuzz <pct>`   | 1%      | ImageMagick `-fuzz` value; absorbs sub-byte rasterisation noise per pixel.    |
| `--only <key>`   | none    | Only run sources whose key contains the substring (e.g., `--only geom-bar`).  |
