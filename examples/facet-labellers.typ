// Facet labellers: strip text driven by label-both() prefixes the variable name.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  data: mpg,
  mapping: aes(x: "displ", y: "hwy", colour: "class"),
  layers: (geom-point(size: 2.5pt, alpha: 0.85),),
  facet: facet-wrap("cyl", ncol: 3, labeller: label-both()),
  guides: guides(colour: guide-none()),
  labs: labs(
    title: "Highway mpg per cylinder count",
    subtitle: "label-both() prefixes each strip with the facet variable name",
    x: "Displacement (L)",
    y: "Highway mpg",
  ),
  theme: theme-minimal(),
  width: 14cm,
  height: 6cm,
)
