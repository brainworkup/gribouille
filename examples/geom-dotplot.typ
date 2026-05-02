// geom-dotplot: stacked dots over a binned x-distribution.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let d = range(0, 80).map(i => (
  x: calc.sin(i * 0.27) * 3 + i * 0.06,
))

#plot(
  data: d,
  mapping: aes(x: "x"),
  layers: (geom-dotplot(bins: 14),),
  labs: labs(title: "geom-dotplot(bins: 14)"),
  theme: theme-minimal(),
  width: 11cm,
  height: 4cm,
)

#plot(
  data: d,
  mapping: aes(x: "x"),
  layers: (geom-dotplot(binwidth: 0.4, dotsize: 0.9),),
  labs: labs(title: "geom-dotplot(binwidth: 0.4, dotsize: 0.9)"),
  theme: theme-minimal(),
  width: 11cm,
  height: 4cm,
)

#plot(
  data: d,
  mapping: aes(x: "x"),
  layers: (geom-dotplot(bins: 14, stackratio: 1.4),),
  labs: labs(title: "geom-dotplot(stackratio: 1.4) leaves a gap between dots"),
  theme: theme-minimal(),
  width: 11cm,
  height: 4cm,
)
