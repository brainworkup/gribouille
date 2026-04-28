// Penguins dataset loaded from CSV: flipper length vs body mass by species.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let penguins = csv("/examples/penguins.csv", row-type: dictionary)

#plot(
  data: penguins,
  mapping: aes(
    x: "flipper-len",
    y: "body-mass",
    colour: "species",
    shape: "species",
  ),
  layers: (
    geom-point(size: 2pt, stroke: 0.5pt, alpha: 0.5),
    geom-smooth(method: "lm", se: true, alpha: 0.2),
  ),
  scales: (
    scale-x-continuous(),
    scale-y-continuous(),
    scale-colour-discrete(palette: (rgb("#ff8c00"), rgb("#800080"), rgb("#008B8B"))),
  ),
  labs: labs(
    title: "Penguins Dataset",
    subtitle: "Flipper length vs body mass by species",
    caption: "Data from Palmer Archipelago (Antarctica) penguin dataset",
    colour: "Species",
    x: "Flipper length (mm)",
    y: "Body mass (g)",
  ),
  theme: theme-minimal(),
  width: 11cm,
  height: 7cm,
)
