# Gribouille internal glossary

Canonical expansions for the short identifiers used across `src/`.
Doc-only: this file does not change any name, it documents the names already in the code.
Run the survey command at the bottom before extending the table.

## Pipeline

| Term      | Expansion                              | Notes                                                                    |
| --------- | -------------------------------------- | ------------------------------------------------------------------------ |
| `geom`    | geometric layer                        | `geom_*` namespace; layer dict tagged `kind: "layer"`.                   |
| `aes`     | aesthetic mapping                      | `aes()` constructor; `(channel: column-name-or-marker, ...)`.            |
| `stat`    | statistical transform                  | `stat_*` namespace; dispatched via `src/stat/apply.typ`.                 |
| `pos`     | position adjustment                    | `position_*` namespace (stack, dodge, fill, jitter, …).                  |
| `spec`    | plot specification dict                | the user-built dict consumed by `render-plot`.                           |
| `ctx`     | per-draw context                       | dict passed to every geom's `draw(layer, ctx)`.                          |
| `mapping` | column-name dict                       | flattened `aes` (`(x: "col", y: "col", colour: "col", ...)`).            |
| `layer`   | one entry of `spec.layers`             | dict tagged `kind: "layer"` carrying `geom`, `mapping`, `data`, …        |
| `map`     | mapping (when shortened)               | local variable name; same shape as `mapping`.                            |
| `params`  | layer-specific parameters              | `layer.params.<channel>` carries pinned values (`stroke`, `colour`, …).  |
| `draw`    | per-geom render entry point            | every geom exports `draw(layer, ctx)`.                                   |
| `eval`    | evaluate (closure / late-binding lane) | `eval-after-stat`, `eval-stage`, …                                       |
| `args`    | arguments                              | Typst `..args` rest binding.                                             |
| `fun`     | function / closure                     | user-supplied closure passed via `fun:` (`stat-manual`, `stat-summary`). |

## Scale / training

| Term         | Expansion          | Notes                                                            |
| ------------ | ------------------ | ---------------------------------------------------------------- |
| `trained`    | scale-trained dict | `ctx.trained.<aes>`; carries `type`, `domain`, `range`, palette. |
| `dom`        | domain             | trained input range for an aesthetic.                            |
| `rng`        | range              | trained output range (often pixels or palette indices).          |
| `cont`       | continuous         | trained scale type for numeric aesthetics.                       |
| `disc`       | discrete           | trained scale type for categorical aesthetics.                   |
| `tr` / `trn` | transform          | scale transform name (`log10`, `sqrt`, `reverse`, …).            |
| `fwd`        | forward transform  | data → transformed value.                                        |
| `inv`        | inverse transform  | transformed value → data.                                        |
| `sec`        | secondary axis     | `sec-axis()` config bound to the primary scale.                  |
| `ref`        | mapping reference  | `mapping-ref` annotation (e.g., `as-factor()` forced-discrete).  |

## Geometry / panel

| Term   | Expansion             | Notes                                                              |
| ------ | --------------------- | ------------------------------------------------------------------ |
| `cx`   | canvas x              | post-scale pixel x in the panel coordinate system.                 |
| `cy`   | canvas y              | post-scale pixel y in the panel coordinate system.                 |
| `px`   | panel x               | panel x range (the `px-range` tuple in `ctx`).                     |
| `py`   | panel y               | panel y range.                                                     |
| `dx`   | delta x               | offset from `(cx, cy)` (e.g., `geom-text(dx: 4pt)`).               |
| `dy`   | delta y               | offset from `(cx, cy)`.                                            |
| `lo`   | lower bound           | endpoint of an interval (whisker, error bar, axis range).          |
| `hi`   | upper bound           | endpoint of an interval.                                           |
| `mid`  | midpoint              | midpoint of two values (`stat-connect("mid")`, `geom-boxplot`, …). |
| `pts`  | points                | array of `(x, y)` tuples passed to a path/polygon draw.            |
| `pair` | adjacent-row tuple    | `(prev, cur)` window over sorted rows.                             |
| `cap`  | cap length / cap mode | end-cap of a stroke or arc (radial axis arc).                      |
| `tick` | axis tick             | tick mark + label record.                                          |
| `cm`   | centimetres           | Typst length unit; used in numeric helpers (`length-to-cm`).       |
| `pt`   | points (typographic)  | Typst length unit.                                                 |

## Data

| Term        | Expansion           | Notes                                                                |
| ----------- | ------------------- | -------------------------------------------------------------------- |
| `row`       | row dictionary      | one element of the data array; user-defined column keys.             |
| `rows`      | row dictionaries    | array of row dictionaries.                                           |
| `col`       | column name         | the string key used to look up a value on a row.                     |
| `cols`      | column names        | array of column-name strings (e.g., group-cols).                     |
| `xs`        | parsed x values     | numeric x array post-`parse-number`.                                 |
| `ys`        | parsed y values     | numeric y array.                                                     |
| `xv` / `yv` | parsed x / y scalar | one parsed numeric value, typically inside a per-row map.            |
| `xa` / `xb` | endpoint x          | `a`/`b` for the two ends of a pair (`(a, b)` in adjacent-row walks). |
| `ya` / `yb` | endpoint y          | same.                                                                |
| `grp`       | group key           | discrete group identifier (string, joined by `\u{1}` for compounds). |
| `cat`       | category            | discrete level on a categorical scale.                               |
| `num`       | numeric             | parsed scalar.                                                       |
| `idx`       | index               | integer position in an array or palette.                             |
| `len`       | length / count      | array length or numeric count.                                       |
| `key`       | dict key            | bucket key in a partition dict.                                      |
| `raw`       | raw user value      | unparsed cell value before `parse-number`.                           |

## Colour / theme

| Term     | Expansion         | Notes                                                  |
| -------- | ----------------- | ------------------------------------------------------ |
| `pal`    | palette           | colour palette dict (discrete or continuous).          |
| `ink`    | foreground colour | theme primary text/line colour (defaults to `black`).  |
| `paper`  | background colour | theme canvas / panel background (defaults to `white`). |
| `accent` | highlight colour  | theme accent (used by some geom defaults).             |
| `tint`   | bar/area body fill | geom fill role: `col-mix(ink, paper, geom-fill-tint-amount)` (default `0.35`, equivalent to `grey35`). |

## Geometry helpers / misc

| Term   | Expansion                | Notes                                             |
| ------ | ------------------------ | ------------------------------------------------- |
| `band` | band                     | rectangular shaded region (utils/band.typ).       |
| `gap`  | gap between bins or bars | x-distance between adjacent bin centres.          |
| `pad`  | padding                  | breathing room (cm) around laid-out content (e.g., strip band text). |
| `sub`  | sub-record / sub-element | nested theme element (e.g., `theme-sub-axis`).    |
| `qq`   | quantile-quantile        | `geom-qq`, `stat-qq`, `stat-qq-line`.             |
| `se`   | standard error           | `mean-se`, `geom-errorbar` summary.               |
| `sp`   | species                  | example data column (penguins / iris-style).      |
| `mm`   | millimetres              | rare; example datasets (penguins flipper length). |
| `cb`   | callback                 | user-supplied closure passed through.             |

## Legend placement

| Term        | Expansion                  | Notes                                                                                                                          |
| ----------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `placement` | guide placement record     | `(side, align, dx, dy, direction, order, byrow)` attached to every guide; consumed by `legend.draw`.                           |
| `extents`   | per-side legend extents    | dict `(top, right, bottom, left, inside)` returned by `legend.estimate-extents`; cm totals plus inside-anchor records.         |
| `side`      | placement side             | `"top"` / `"right"` / `"bottom"` / `"left"` for margin slots, `"inside"` for panel-overlay placement, `"none"` to suppress.    |

## Survey

Re-run before extending the table:

```sh
grep -rhoE '\b[a-z]{1,4}\b' src --include='*.typ' \
  | sort | uniq -c | sort -rn | awk '$1 >= 50' | less
```

Filter out Typst keywords (`let`, `if`, `else`, `for`, `at`, `set`, …) and English words.
Anything left at frequency ≥ 50 should be either obviously domain-clear (`data`, `name`, `plot`, `axis`, `bin`, `text`, …) or listed above.
