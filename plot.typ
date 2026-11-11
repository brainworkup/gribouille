#import "@preview/gribouille:0.8.0": *

#plot(
  data: penguins,
  mapping: aes(
    x: "flipper-len",
    y: "body-mass",
    colour: "species",
  ),
  layers: (
    geom-point(size: 2pt, alpha: 0.65, colour: rgb("#1d4ed8")),
  ),
  scales: scales(
    x: scale-continuous(),
    y: scale-continuous(),
    colour: scale-discrete(
      limits: ("Adelie", "Chinstrap", "Gentoo"),
      palette: (rgb("#ff8c00"), rgb("#008B8B"), rgb("#800080")),
    ),
  ),
  guides: guides(default: none),
  theme: theme-minimal(),
  width: 12cm,
  height: 9cm,
)