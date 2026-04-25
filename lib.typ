// gribouille -- a layered grammar of graphics for Typst.
// Public API for @preview/gribouille.

// Core.
#import "src/plot.typ": plot
#import "src/aes.typ": aes
#import "src/data.typ": as-factor, as-numeric

// Labs.
#import "src/labs.typ": labs

// Geoms.
#import "src/geom/point.typ": geom-point
#import "src/geom/line.typ": geom-line
#import "src/geom/path.typ": geom-path
#import "src/geom/step.typ": geom-step
#import "src/geom/area.typ": geom-area
#import "src/geom/rect.typ": geom-rect
#import "src/geom/tile.typ": geom-raster, geom-tile
#import "src/geom/segment.typ": geom-segment
#import "src/geom/polygon.typ": geom-polygon
#import "src/geom/col.typ": geom-col
#import "src/geom/bar.typ": geom-bar
#import "src/geom/histogram.typ": geom-histogram
#import "src/geom/freqpoly.typ": geom-freqpoly
#import "src/geom/smooth.typ": geom-smooth
#import "src/geom/ribbon.typ": geom-ribbon
#import "src/geom/boxplot.typ": geom-boxplot
#import "src/geom/hline.typ": geom-hline
#import "src/geom/vline.typ": geom-vline
#import "src/geom/abline.typ": geom-abline
#import "src/geom/text.typ": geom-text
#import "src/geom/label.typ": geom-label
#import "src/geom/jitter.typ": geom-jitter

// Stats.
#import "src/stat/identity.typ": stat-identity
#import "src/stat/count.typ": stat-count
#import "src/stat/bin.typ": stat-bin
#import "src/stat/smooth.typ": stat-smooth

// Scales.
#import "src/scale/continuous.typ": scale-x-continuous, scale-y-continuous
#import "src/scale/continuous.typ": scale-x-log10, scale-y-log10
#import "src/scale/continuous.typ": scale-x-sqrt, scale-y-sqrt
#import "src/scale/continuous.typ": scale-x-reverse, scale-y-reverse
#import "src/scale/discrete.typ": scale-x-discrete, scale-y-discrete
#import "src/scale/colour.typ": scale-colour-continuous, scale-colour-discrete
#import "src/scale/colour.typ": scale-fill-continuous, scale-fill-discrete
#import "src/scale/colour.typ": scale-colour-manual, scale-fill-manual
#import "src/scale/colour.typ": scale-colour-identity, scale-fill-identity
#import "src/scale/colour.typ": (
  scale-colour-viridis-b, scale-colour-viridis-c, scale-colour-viridis-d,
)
#import "src/scale/colour.typ": (
  scale-fill-viridis-b, scale-fill-viridis-c, scale-fill-viridis-d,
)
#import "src/scale/size.typ": scale-size-continuous
#import "src/scale/shape.typ": (
  scale-shape, scale-shape-identity, scale-shape-manual,
)
#import "src/scale/linetype.typ": (
  scale-linetype, scale-linetype-identity, scale-linetype-manual,
)
#import "src/utils/colour.typ": col-mix

// Coord.
#import "src/coord/cartesian.typ": coord-cartesian
#import "src/coord/fixed.typ": coord-fixed

// Positions.
#import "src/position/stack.typ": position-stack
#import "src/position/dodge.typ": position-dodge
#import "src/position/fill.typ": position-fill
#import "src/position/identity.typ": position-identity
#import "src/position/jitter.typ": position-jitter
#import "src/position/nudge.typ": position-nudge

// Facets.
#import "src/facet/wrap.typ": facet-wrap
#import "src/facet/grid.typ": facet-grid

// Themes.
#import "src/theme/grey.typ": theme-grey
#import "src/theme/minimal.typ": theme-minimal
#import "src/theme/classic.typ": theme-classic
#import "src/theme/void.typ": theme-void
#import "src/theme/bw.typ": theme-bw
#import "src/theme/linedraw.typ": theme-linedraw
#import "src/theme/light.typ": theme-light
#import "src/theme/dark.typ": theme-dark
#import "src/theme/test.typ": theme-test
#import "src/theme/theme.typ": theme
#import "src/theme/elements.typ": (
  element-blank, element-line, element-rect, element-text,
)
#import "src/theme/current.typ": theme-get, theme-set
