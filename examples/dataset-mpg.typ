// Bundled mpg dataset: highway mpg vs engine displacement, coloured by class.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  data: mpg,
  mapping: aes(x: "displ", y: "hwy", colour: "class"),
  layers: (
    geom-point(size: 3pt),
  ),
  scales: (
    scale-x-continuous(name: "Engine displacement (L)"),
    scale-y-continuous(name: "Highway mpg"),
  ),
  labs: labs(
    title: "Fuel economy by vehicle class",
    colour: "Class",
  ),
  alt: "Scatter plot of highway miles per gallon against engine displacement, with points coloured by vehicle class. Highway mpg falls as engine displacement rises.",
  width: 12cm,
  height: 7cm,
)
