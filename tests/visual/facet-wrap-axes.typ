// facet-wrap axes parameter and alone-facet axis rule.
//
// Three plots over the same 3-level data laid out as 2-by-2 (one
// trailing empty slot at row 1 col 1):
//   1. axes: "margins" (default): bottom-row panel C gets x axis, and
//      panel B at (row 0, col 1) gets x axis too because nothing sits
//      under it. Panel A (col 0) gets the only y axis.
//   2. axes: "all_x": every panel draws bottom x axis; y axis stays on
//      col 0 only.
//   3. axes: "all": every panel draws both bottom x axis and left y axis.

#import "../../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let data = (
  (x: 1, y: 1, g: "A"),
  (x: 2, y: 2, g: "A"),
  (x: 3, y: 3, g: "A"),
  (x: 1, y: 3, g: "B"),
  (x: 2, y: 2, g: "B"),
  (x: 3, y: 1, g: "B"),
  (x: 1, y: 2, g: "C"),
  (x: 2, y: 4, g: "C"),
  (x: 3, y: 3, g: "C"),
)

#stack(
  dir: ttb,
  spacing: 0.6cm,
  plot(
    data: data,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-point(),),
    facet: facet-wrap("g", ncolumn: 2),
    width: 9cm,
    height: 6cm,
  ),
  plot(
    data: data,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-point(),),
    facet: facet-wrap("g", ncolumn: 2, axes: "all_x"),
    width: 9cm,
    height: 6cm,
  ),
  plot(
    data: data,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-point(),),
    facet: facet-wrap("g", ncolumn: 2, axes: "all"),
    width: 9cm,
    height: 6cm,
  ),
)
