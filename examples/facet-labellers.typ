// Facet labellers: strip text driven by `label-both()`.
// Each strip shows "cyl: <level>" rather than the bare level.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let cars = (
  (wt: 2.620, mpg: 21.0, cyl: "6"),
  (wt: 2.875, mpg: 21.0, cyl: "6"),
  (wt: 2.320, mpg: 22.8, cyl: "4"),
  (wt: 3.215, mpg: 21.4, cyl: "6"),
  (wt: 3.440, mpg: 18.7, cyl: "8"),
  (wt: 3.460, mpg: 18.1, cyl: "6"),
  (wt: 3.570, mpg: 14.3, cyl: "8"),
  (wt: 3.190, mpg: 24.4, cyl: "4"),
  (wt: 3.150, mpg: 22.8, cyl: "4"),
  (wt: 3.440, mpg: 19.2, cyl: "6"),
  (wt: 4.070, mpg: 16.4, cyl: "8"),
  (wt: 1.835, mpg: 33.9, cyl: "4"),
)

#plot(
  data: cars,
  mapping: aes(x: "wt", y: "mpg"),
  layers: (geom-point(size: 2pt),),
  facet: facet-wrap("cyl", ncol: 3, labeller: label-both()),
  scales: (
    scale-x-continuous(name: "Weight"),
    scale-y-continuous(name: "MPG"),
  ),
  width: 14cm,
  height: 6cm,
)
