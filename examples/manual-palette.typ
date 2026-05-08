// scale-colour-manual and scale-fill-manual: user-supplied palettes.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let palette = (rgb("#ff8c00"), rgb("#800080"), rgb("#008B8B"))

#plot(
  data: penguins,
  mapping: aes(
    x: "flipper-len",
    y: "body-mass",
    colour: "species",
    fill: "species",
  ),
  layers: (
    geom-point(size: 2pt, alpha: 0.7),
    geom-smooth(method: "lm", alpha: 0.15),
  ),
  scales: (
    scale-colour-manual(values: palette),
    scale-fill-manual(values: palette),
    scale-y-continuous(labels: label-comma()),
  ),
  labs: labs(
    title: "Penguin species drawn with a custom palette",
    x: "Flipper length (mm)",
    y: "Body mass (g)",
    colour: "Species",
    fill: "Species",
  ),
  theme: theme-minimal(),
  width: 12cm,
  height: 9cm,
)
