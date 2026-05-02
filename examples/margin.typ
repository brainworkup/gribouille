// margin family: theme(plot-margin: ...) shifts the plot canvas.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = range(0, 10).map(i => (x: i, y: i * 0.5))

// Default margin: dynamic, leaves room for axis title and (any) legend.
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 2pt),),
  labs: labs(title: "Default plot-margin"),
  width: 10cm,
  height: 4cm,
)

// Explicit fixed margin via margin().
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 2pt),),
  labs: labs(title: "margin(top: 0.6cm, left: 1.6cm)"),
  theme: theme(plot-margin: margin(
    top: 0.6cm,
    right: 0.6cm,
    bottom: 0.9cm,
    left: 1.6cm,
  )),
  width: 10cm,
  height: 4cm,
)

// Partial override: only top and left are pinned; right/bottom keep the
// renderer's auto-computed default.
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 2pt),),
  labs: labs(title: "margin-part(top: 0.6cm, left: 1.6cm)"),
  theme: theme(plot-margin: margin-part(top: 0.6cm, left: 1.6cm)),
  width: 10cm,
  height: 4cm,
)
