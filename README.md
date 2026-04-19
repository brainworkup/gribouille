# Gribouille <picture><source media="(prefers-color-scheme: dark)" srcset="docs/assets/images/logo-stacked-dark.svg"><source media="(prefers-color-scheme: light)" srcset="docs/assets/images/logo-stacked.svg"><img align="right" width="120" alt="Gribouille logo." src="docs/assets/images/logo-stacked.svg"></picture>

A layered grammar of graphics for Typst.

_Gribouille_ is French for "scribble".
The library implements Wilkinson's grammar of graphics in a declarative API for Typst documents, inspired by [`ggplot2`](https://ggplot2.tidyverse.org) (R) and [`plotnine`](https://plotnine.org) (Python).

Documentation: <https://m.canouil.dev/gribouille>.

> [!WARNING]
> _Gribouille_ is in active development.

## Quick look

```typst
#import "@preview/gribouille:0.0.1": *

#let df = csv("penguins.csv", row-type: dictionary)

#plot(
  data: df,
  mapping: aes(
    x: "flipper-len",
    y: "body-mass",
    colour: "species",
  ),
  layers: (
    geom-point(size: 2pt),
    geom-smooth(method: "lm"),
  ),
  facet: facet-wrap("island"),
  theme: theme-minimal(),
)
```

## Scope

- Geoms: `geom-point`, `geom-line`, `geom-col`, `geom-bar`, `geom-histogram`, `geom-smooth`, `geom-ribbon`, `geom-boxplot`, `geom-hline`, `geom-vline`, `geom-abline`, `geom-text`, `geom-label`.
- Aesthetics: `x`, `y`, `colour`, `fill`, `size`, `shape`, `linetype`, `group`, `alpha`.
- Stats: `stat-identity`, `stat-count`, `stat-bin`, `stat-smooth`.
- Scales: continuous and discrete for `x`, `y`, `colour`, `fill`, `size`, `shape`, and `linetype`, with Viridis and manual palettes.
- Coordinates: `coord-cartesian` with non-dropping limits.
- Positions: `position-identity`, `position-stack`, `position-dodge`, `position-fill`.
- Facets: `facet-wrap` and `facet-grid` with shared or free scales.
- Themes: `theme-grey`, `theme-minimal`, `theme-classic`, `theme-void`, plus `theme()` element overrides.
- Labels: `labs`.
- Automatic legends.

## Dependencies

See [`typst.toml`](typst.toml) and [`src/deps.typ`](src/deps.typ) for the authoritative Typst compiler and CeTZ versions.

## License

This project is licensed under the MIT License.
See the [LICENSE](LICENSE) file for details.
