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
Reuses the typstdoc parser to extract every renderable `/// @examples` fence into a temporary wrapped `.typ`, compiles each file (plus every `examples/*.typ`) to a PNG at 144 ppi with `--ignore-system-fonts`, and diffs the result against the committed golden with `compare -metric AE -fuzz 1%` (ImageMagick).

Goldens live under `golden/examples/<name>.png` and `golden/docstrings/<fn>-<idx>.png`.

### Check mode (CI default)

```bash
lua tools/snapshot/run.lua --check
```

Exits non-zero if any compile fails, any golden is missing, or any image differs from its golden.
Diff PNGs are written to `build/snapshot/diff/` (gitignored).

### Update mode

```bash
lua tools/snapshot/run.lua --update
```

Recompiles everything and overwrites the goldens.
Run this when the visual change is intentional; commit the updated PNGs in the same commit as the code change.

### Reproducibility

The harness renders with `--ignore-system-fonts`, so output depends only on the pinned Typst version (read from `typst.toml`) and Typst's embedded fonts.
The deterministic face is the embedded Libertinus Serif.
Renders are byte-identical on Linux, macOS, and Windows; local `--check` and `--update` are authoritative and match CI.

### Bootstrap and refresh

To regenerate the goldens after a deliberate change, trigger the `Refresh visual snapshots` workflow (`workflow_dispatch`).
It runs `--update` and pushes the refreshed PNGs back to the dispatched branch.

### Useful flags

| Flag             | Default | Purpose                                                                       |
| ---------------- | ------- | ----------------------------------------------------------------------------- |
| `--check`        | on      | Compare current compile to golden.                                            |
| `--update`       | off     | Overwrite goldens with fresh compile.                                         |
| `--ppi <n>`      | 144     | Raster density passed to `typst compile`.                                     |
| `--tolerance <n>`| 0       | Max AE pixel count tolerated per image.                                       |
| `--fuzz <pct>`   | 1%      | ImageMagick `-fuzz` value; absorbs sub-byte rasterisation noise per pixel.    |
| `--only <key>`   | none    | Only run sources whose key contains the substring (e.g., `--only geom-bar`).  |

## Reviewing diffs between commits

`tools/snapshot/diff.lua` visualises how the committed goldens changed between two git refs, without recompiling anything (it diffs the golden PNGs straight out of git).
It writes a self-contained interactive HTML report to `build/snapshot/diff-report/` (gitignored) with, per changed snapshot, the base and head images, a red-pixel overlay, a side-by-side composite, an onion-skin opacity slider, and a flicker toggle.
A keyboard stepper walks only the changed snapshots and skips everything unchanged (`j`/`k` to step, `f` to flicker, `o` to cycle the onion-skin).

```bash
lua tools/snapshot/diff.lua --base main
```

Comparing against a branch resolves the merge-base, so the report shows only the snapshots the current branch changed.
Omitting `--head` compares the base against the on-disk goldens, so uncommitted `--update` results can be reviewed before committing.

| Flag            | Default                     | Purpose                                                                 |
| --------------- | --------------------------- | ----------------------------------------------------------------------- |
| `--base <ref>`  | `HEAD~1`                    | Base commit or branch; a branch resolves to its merge-base with head.   |
| `--head <ref>`  | working tree                | Head commit; omitted compares against the on-disk goldens.              |
| `--exact`       | off                         | Diff `<base>..<head>` literally, skipping merge-base resolution.        |
| `--only <key>`  | none                        | Restrict to golden keys containing the substring.                       |
| `--fuzz <pct>`  | 2%                          | ImageMagick `-fuzz` value for the overlay.                              |
| `--out <dir>`   | `build/snapshot/diff-report`| Report directory.                                                       |
| `--open`        | off                         | Open the report in the browser (macOS).                                 |
