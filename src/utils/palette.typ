// Default colour palettes.
// Discrete defaults avoid purple-ish hues.

#let default-discrete = (
  rgb("#1f77b4"),
  rgb("#2ca02c"),
  rgb("#d62728"),
  rgb("#ff7f0e"),
  rgb("#17becf"),
  rgb("#8c564b"),
  rgb("#e377c2"),
  rgb("#7f7f7f"),
)

// Shape palette: keywords resolved by geom-point's `_draw-shape`.
// Covers the most common shape indices without overlap.
#let default-shapes = (
  "circle",
  "square",
  "triangle",
  "diamond",
  "cross",
  "x",
  "star",
  "triangle-down",
)

// Linetype palette: dash patterns accepted by CeTZ stroke `dash` keyword.
#let default-linetypes = (
  "solid",
  "dashed",
  "dotted",
  "dash-dotted",
  "densely-dashed",
  "loosely-dashed",
)

// ColorBrewer palettes (Cynthia Brewer).
// Subset of the canonical tables: 8-class for qualitative palettes (or the
// largest available class where 8 is not defined), 7-class for sequential
// and diverging palettes. Hex codes match the official colorbrewer2.org
// values.
#let brewer-palettes = (
  // Qualitative.
  "Set1": (
    rgb("#e41a1c"),
    rgb("#377eb8"),
    rgb("#4daf4a"),
    rgb("#984ea3"),
    rgb("#ff7f00"),
    rgb("#ffff33"),
    rgb("#a65628"),
    rgb("#f781bf"),
  ),
  "Set2": (
    rgb("#66c2a5"),
    rgb("#fc8d62"),
    rgb("#8da0cb"),
    rgb("#e78ac3"),
    rgb("#a6d854"),
    rgb("#ffd92f"),
    rgb("#e5c494"),
    rgb("#b3b3b3"),
  ),
  "Set3": (
    rgb("#8dd3c7"),
    rgb("#ffffb3"),
    rgb("#bebada"),
    rgb("#fb8072"),
    rgb("#80b1d3"),
    rgb("#fdb462"),
    rgb("#b3de69"),
    rgb("#fccde5"),
  ),
  "Pastel1": (
    rgb("#fbb4ae"),
    rgb("#b3cde3"),
    rgb("#ccebc5"),
    rgb("#decbe4"),
    rgb("#fed9a6"),
    rgb("#ffffcc"),
    rgb("#e5d8bd"),
    rgb("#fddaec"),
  ),
  "Pastel2": (
    rgb("#b3e2cd"),
    rgb("#fdcdac"),
    rgb("#cbd5e8"),
    rgb("#f4cae4"),
    rgb("#e6f5c9"),
    rgb("#fff2ae"),
    rgb("#f1e2cc"),
    rgb("#cccccc"),
  ),
  "Dark2": (
    rgb("#1b9e77"),
    rgb("#d95f02"),
    rgb("#7570b3"),
    rgb("#e7298a"),
    rgb("#66a61e"),
    rgb("#e6ab02"),
    rgb("#a6761d"),
    rgb("#666666"),
  ),
  "Accent": (
    rgb("#7fc97f"),
    rgb("#beaed4"),
    rgb("#fdc086"),
    rgb("#ffff99"),
    rgb("#386cb0"),
    rgb("#f0027f"),
    rgb("#bf5b17"),
    rgb("#666666"),
  ),
  "Paired": (
    rgb("#a6cee3"),
    rgb("#1f78b4"),
    rgb("#b2df8a"),
    rgb("#33a02c"),
    rgb("#fb9a99"),
    rgb("#e31a1c"),
    rgb("#fdbf6f"),
    rgb("#ff7f00"),
  ),
  // Sequential.
  "Blues": (
    rgb("#f7fbff"),
    rgb("#deebf7"),
    rgb("#c6dbef"),
    rgb("#9ecae1"),
    rgb("#6baed6"),
    rgb("#4292c6"),
    rgb("#2171b5"),
    rgb("#084594"),
  ),
  "Greens": (
    rgb("#f7fcf5"),
    rgb("#e5f5e0"),
    rgb("#c7e9c0"),
    rgb("#a1d99b"),
    rgb("#74c476"),
    rgb("#41ab5d"),
    rgb("#238b45"),
    rgb("#005a32"),
  ),
  "Oranges": (
    rgb("#fff5eb"),
    rgb("#fee6ce"),
    rgb("#fdd0a2"),
    rgb("#fdae6b"),
    rgb("#fd8d3c"),
    rgb("#f16913"),
    rgb("#d94801"),
    rgb("#8c2d04"),
  ),
  "Reds": (
    rgb("#fff5f0"),
    rgb("#fee0d2"),
    rgb("#fcbba1"),
    rgb("#fc9272"),
    rgb("#fb6a4a"),
    rgb("#ef3b2c"),
    rgb("#cb181d"),
    rgb("#99000d"),
  ),
  "Purples": (
    rgb("#fcfbfd"),
    rgb("#efedf5"),
    rgb("#dadaeb"),
    rgb("#bcbddc"),
    rgb("#9e9ac8"),
    rgb("#807dba"),
    rgb("#6a51a3"),
    rgb("#4a1486"),
  ),
  "Greys": (
    rgb("#ffffff"),
    rgb("#f0f0f0"),
    rgb("#d9d9d9"),
    rgb("#bdbdbd"),
    rgb("#969696"),
    rgb("#737373"),
    rgb("#525252"),
    rgb("#252525"),
  ),
  "YlOrRd": (
    rgb("#ffffcc"),
    rgb("#ffeda0"),
    rgb("#fed976"),
    rgb("#feb24c"),
    rgb("#fd8d3c"),
    rgb("#fc4e2a"),
    rgb("#e31a1c"),
    rgb("#b10026"),
  ),
  "YlGnBu": (
    rgb("#ffffd9"),
    rgb("#edf8b1"),
    rgb("#c7e9b4"),
    rgb("#7fcdbb"),
    rgb("#41b6c4"),
    rgb("#1d91c0"),
    rgb("#225ea8"),
    rgb("#0c2c84"),
  ),
  // Diverging.
  "RdBu": (
    rgb("#b2182b"),
    rgb("#ef8a62"),
    rgb("#fddbc7"),
    rgb("#f7f7f7"),
    rgb("#d1e5f0"),
    rgb("#67a9cf"),
    rgb("#2166ac"),
  ),
  "RdYlBu": (
    rgb("#d73027"),
    rgb("#fc8d59"),
    rgb("#fee090"),
    rgb("#ffffbf"),
    rgb("#e0f3f8"),
    rgb("#91bfdb"),
    rgb("#4575b4"),
  ),
  "RdYlGn": (
    rgb("#d73027"),
    rgb("#fc8d59"),
    rgb("#fee08b"),
    rgb("#ffffbf"),
    rgb("#d9ef8b"),
    rgb("#91cf60"),
    rgb("#1a9850"),
  ),
  "Spectral": (
    rgb("#d53e4f"),
    rgb("#fc8d59"),
    rgb("#fee08b"),
    rgb("#ffffbf"),
    rgb("#e6f598"),
    rgb("#99d594"),
    rgb("#3288bd"),
  ),
  "BrBG": (
    rgb("#8c510a"),
    rgb("#d8b365"),
    rgb("#f6e8c3"),
    rgb("#f5f5f5"),
    rgb("#c7eae5"),
    rgb("#5ab4ac"),
    rgb("#01665e"),
  ),
  "PiYG": (
    rgb("#c51b7d"),
    rgb("#e9a3c9"),
    rgb("#fde0ef"),
    rgb("#f7f7f7"),
    rgb("#e6f5d0"),
    rgb("#a1d76a"),
    rgb("#4d9221"),
  ),
  "PuOr": (
    rgb("#b35806"),
    rgb("#f1a340"),
    rgb("#fee0b6"),
    rgb("#f7f7f7"),
    rgb("#d8daeb"),
    rgb("#998ec3"),
    rgb("#542788"),
  ),
  "PRGn": (
    rgb("#762a83"),
    rgb("#af8dc3"),
    rgb("#e7d4e8"),
    rgb("#f7f7f7"),
    rgb("#d9f0d3"),
    rgb("#7fbf7b"),
    rgb("#1b7837"),
  ),
)

// Index a palette with modulo wrap so out-of-range indices cycle.
#let palette-at(palette, idx) = palette.at(calc.rem(idx, palette.len()))

// Resolve the palette declared on a trained scale, falling back to `fallback`.
// Returns `fallback` when the scale is untrained, has no spec, or sets the
// palette to `auto` or `none`. Used by geoms (linetype, shape) and the
// level-driven legend kernel.
#let spec-palette(trained, fallback) = {
  if trained == none { return fallback }
  let spec = trained.at("spec", default: none)
  if spec == none { return fallback }
  let p = spec.at("palette", default: auto)
  if p == auto or p == none { fallback } else { p }
}

/// Look up a ColorBrewer palette by name.
///
/// Returns the canonical colour array for the named palette.
/// Panics with a clear message if the name is unknown.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.1.0
///
/// \@param name Palette name, e.g. `"Set1"`, `"Spectral"`, `"Blues"`.
/// \@returns Array of `color` values.
///
/// \@examples Look up the Set1 palette and feed it into a manual fill scale
/// rendered as swatches via \@geom-rect.
/// ```
/// #let pal = brewer-palette("Set1")
/// #let d = pal.enumerate().map(((i, _)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: str(i),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-manual(values: pal),),
///   guides: guides(fill: guide-none()),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
///
/// \@examples The diverging Spectral palette laid out as swatches; the same
/// pattern works for any qualitative, sequential, or diverging name.
/// ```
/// #let pal = brewer-palette("Spectral")
/// #let d = pal.enumerate().map(((i, _)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: str(i),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-manual(values: pal),),
///   guides: guides(fill: guide-none()),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
#let brewer-palette(name) = {
  let pal = brewer-palettes.at(name, default: none)
  if pal == none {
    let known = brewer-palettes.keys().join(", ")
    panic(
      "Unknown ColorBrewer palette '" + name + "'. Known palettes: " + known,
    )
  }
  pal
}
