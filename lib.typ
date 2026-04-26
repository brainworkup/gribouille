// gribouille -- a layered grammar of graphics for Typst.
// Public API for @preview/gribouille.

// Core.
#import "src/plot.typ": get-alt-text, plot
#import "src/aes.typ": aes
#import "src/data.typ": as-factor, as-numeric
#import "src/annotate.typ": annotate

// Datasets.
#import "src/datasets/economics.typ": economics
#import "src/datasets/mpg.typ": mpg

// Labs.
#import "src/labs.typ": labs

// Guides.
#import "src/guide/legend.typ": guide-legend
#import "src/guide/none.typ": guide-none
#import "src/guide/axis.typ": guide-axis
#import "src/guides.typ": guides

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
#import "src/geom/errorbar.typ": geom-errorbar
#import "src/geom/linerange.typ": geom-linerange
#import "src/geom/crossbar.typ": geom-crossbar
#import "src/geom/pointrange.typ": geom-pointrange
#import "src/geom/hline.typ": geom-hline
#import "src/geom/vline.typ": geom-vline
#import "src/geom/abline.typ": geom-abline
#import "src/geom/text.typ": geom-text
#import "src/geom/label.typ": geom-label
#import "src/geom/jitter.typ": geom-jitter
#import "src/geom/blank.typ": geom-blank
#import "src/geom/rug.typ": geom-rug
#import "src/geom/function.typ": geom-function

// Stats.
#import "src/stat/identity.typ": stat-identity
#import "src/stat/count.typ": stat-count
#import "src/stat/bin.typ": stat-bin
#import "src/stat/smooth.typ": stat-smooth
#import "src/stat/boxplot.typ": stat-boxplot
#import "src/stat/summary.typ": stat-summary
#import "src/stat/summary-bin.typ": stat-summary-bin
#import "src/stat/ecdf.typ": stat-ecdf
#import "src/stat/unique.typ": stat-unique
#import "src/utils/summaries.typ": (
  mean-cl-normal, mean-sdl, mean-se, median-hilow,
)
#import "src/utils/cut.typ": cut-interval, cut-number, cut-width
#import "src/utils/resolution.typ": resolution

// Scales.
#import "src/scale/continuous.typ": scale-x-continuous, scale-y-continuous
#import "src/scale/continuous.typ": scale-x-log10, scale-y-log10
#import "src/scale/continuous.typ": scale-x-sqrt, scale-y-sqrt
#import "src/scale/continuous.typ": scale-x-reverse, scale-y-reverse
#import "src/scale/date.typ": scale-x-date, scale-y-date
#import "src/scale/date.typ": scale-x-datetime, scale-y-datetime
#import "src/scale/date.typ": scale-x-time, scale-y-time
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
#import "src/scale/colour.typ": scale-colour-brewer, scale-fill-brewer
#import "src/scale/colour.typ": (
  scale-colour-gradient, scale-colour-gradient2, scale-colour-gradientn,
)
#import "src/scale/colour.typ": (
  scale-fill-gradient, scale-fill-gradient2, scale-fill-gradientn,
)
#import "src/scale/colour.typ": scale-colour-grey, scale-fill-grey
#import "src/scale/colour.typ": scale-colour-hue, scale-fill-hue
#import "src/scale/colour.typ": scale-colour-distiller, scale-fill-distiller
#import "src/utils/palette.typ": brewer-palette
#import "src/scale/size.typ": scale-size-continuous
#import "src/scale/shape.typ": (
  scale-shape, scale-shape-identity, scale-shape-manual,
)
#import "src/scale/linetype.typ": (
  scale-linetype, scale-linetype-identity, scale-linetype-manual,
)
#import "src/utils/colour.typ": col-mix
#import "src/limits.typ": expand-limits, lims, xlim, ylim

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
