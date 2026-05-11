// scale-colour-okabe-ito and scale-fill-okabe-ito: CVD-safe discrete palette.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

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
    scale-colour-okabe-ito(),
    scale-fill-okabe-ito(),
    scale-y-continuous(labels: label-comma()),
  ),
  labs: labs(
    title: "Penguin Species with the Okabe-Ito Palette",
    x: "Flipper Length (mm)",
    y: "Body Mass (g)",
    colour: "Species",
    fill: "Species",
  ),
  theme: theme-minimal(),
  width: 12cm,
  height: 9cm,
)
