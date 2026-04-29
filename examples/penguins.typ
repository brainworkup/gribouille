// Bundled penguins dataset: flipper length vs body mass by species.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  data: penguins,
  mapping: aes(
    x: "flipper-len",
    y: "body-mass",
    colour: "species",
    fill: "species",
    shape: "species",
  ),
  layers: (
    geom-point(size: 2pt, alpha: 0.25, stroke: 0.5pt, colour: rgb("#ffffff")),
    geom-smooth(method: "lm", se: true, alpha: 0.2),
    geom-errorbar(stat: stat-summary(fun: "mean-sd"), width: 5pt),
    geom-errorbarh(stat: stat-summary(fun: "mean-sd"), height: 5pt),
  ),
  scales: (
    scale-x-continuous(),
    scale-y-continuous(),
    scale-colour-discrete(palette: (
      rgb("#ff8c00"),
      rgb("#800080"),
      rgb("#008B8B"),
    )),
    scale-fill-discrete(palette: (
      rgb("#ff8c00"),
      rgb("#800080"),
      rgb("#008B8B"),
    )),
  ),
  labs: labs(
    title: "Penguins Dataset",
    subtitle: "Flipper length vs body mass by species",
    caption: "Data from Palmer Archipelago (Antarctica) penguin dataset",
    colour: "Species",
    fill: "Species",
    x: "Flipper length (mm)",
    y: "Body mass (g)",
  ),
  theme: theme-minimal(),
  width: 11cm,
  height: 7cm,
)

#place(
  bottom + right,
  image("../docs/assets/images/logo-stacked.svg", height: 1cm),
)
