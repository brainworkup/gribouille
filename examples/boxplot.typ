// stat-boxplot reduces each group to a five-number summary; geom-boxplot draws the Tukey box.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  data: mpg,
  mapping: aes(x: "class", y: "hwy", fill: "class"),
  layers: (geom-boxplot(),),
  guides: guides(fill: guide-none()),
  labs: labs(
    title: "Highway fuel economy by vehicle class",
    subtitle: "Boxes show the inter-quartile range; whiskers and dots flag outliers",
    x: "Class",
    y: "Highway mpg",
  ),
  theme: theme-minimal(),
  width: 11cm,
  height: 6.5cm,
)
