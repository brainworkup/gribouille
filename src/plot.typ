#import "render.typ": render-plot
#import "theme/current.typ": _theme-state

/// Compose a layered plot from data, aesthetics, and geom layers.
///
/// `plot` is the entry point of the grammar: it resolves the dataset, wires up
/// the aesthetic mapping, trains scales against the data, applies coordinate,
/// facet, theme, and label choices, and dispatches to the internal renderer.
/// Call it once per figure, passing the layers you want to stack.
///
/// @category Core
/// @stability stable
/// @since 0.0.1
///
/// @param data Array of row dictionaries. Each row is a `(column: value, ...)` dict.
/// @param mapping Aesthetic mapping built with @aes. Maps column names to visual channels.
/// @param layers Array of geom layers (e.g. @geom-point, @geom-line). Drawn in order.
/// @param scales Array of scale objects overriding defaults (@scale-x-continuous, @scale-colour-viridis-d, etc.).
/// @param coord Coordinate system. Defaults to @coord-cartesian when `none`.
/// @param facet Faceting specification built with @facet-wrap or @facet-grid.
/// @param theme Theme object (e.g. @theme-grey, @theme-minimal, @theme-classic). Controls non-data ink.
/// @param labs Labels dictionary built with @labs (title, subtitle, caption, axis titles).
/// @param guides Per-aesthetic guide overrides built with @guides (e.g. `guides(colour: guide-legend(reverse: true))`).
/// @param width Total plot width, including axes and legends.
/// @param height Total plot height, including axes and legends.
/// @param alt Alt text describing the figure for accessibility tooling. Stored on the spec; not rendered.
///
/// @returns Typst content block containing the rendered figure.
///
/// @example
/// ```
/// #let mtcars = (
///   (mpg: 21.0, wt: 2.620, cyl: "6"),
///   (mpg: 22.8, wt: 2.320, cyl: "4"),
///   (mpg: 18.7, wt: 3.440, cyl: "8"),
///   (mpg: 16.4, wt: 4.070, cyl: "8"),
///   (mpg: 33.9, wt: 1.835, cyl: "4"),
/// )
/// #plot(
///   data: mtcars,
///   mapping: aes(x: "wt", y: "mpg", colour: "cyl"),
///   layers: (geom-point(size: 3pt),),
///   labs: labs(title: "Fuel economy vs. weight"),
///   width: 12cm,
///   height: 7cm,
/// )
/// ```
///
/// @see @aes, @geom-point, @coord-cartesian, @facet-wrap, @theme-grey, @labs
#let plot(
  data: none,
  mapping: none,
  layers: (),
  scales: (),
  coord: none,
  facet: none,
  theme: none,
  labs: none,
  guides: (:),
  width: 10cm,
  height: 7cm,
  alt: none,
) = {
  context {
    let effective-theme = if theme != none {
      theme
    } else {
      _theme-state.get()
    }
    let spec = (
      data: data,
      mapping: mapping,
      layers: layers,
      scales: scales,
      coord: coord,
      facet: facet,
      theme: effective-theme,
      labs: labs,
      guides: guides,
      width: width,
      height: height,
      alt: alt,
    )
    render-plot(spec)
  }
}

/// Read the alt text stored on a plot spec.
///
/// Returns whatever was passed to @plot via `alt:`, or `none` if the
/// spec was built without one. This lets renderers and accessibility
/// tooling pull the description out without parsing the rendered
/// figure.
///
/// @category Core
/// @stability stable
/// @since 0.0.1
///
/// @param spec Plot spec dictionary (the dict @plot builds internally).
///
/// @returns The alt string, or `none` if absent.
#let get-alt-text(spec) = spec.at("alt", default: none)
