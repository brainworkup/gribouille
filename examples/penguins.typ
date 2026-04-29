// Bundled penguins dataset: flipper length vs body mass by species.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  data: penguins,
  mapping: aes(
    x: "flipper-len",
    y: "body-mass",
    fill: "species",
    shape: "species",
  ),
  layers: (
    geom-point(size: 2pt, alpha: 0.25, stroke: 0.5pt, colour: rgb("#ffffff")),
    geom-smooth(
      mapping: aes(colour: "species"),
      method: "lm",
      se: true,
      alpha: 0.2,
    ),
    geom-errorbar(
      mapping: aes(colour: "species"),
      stat: stat-summary(fun: "mean-sd"),
      width: 5pt,
    ),
    geom-errorbarh(
      mapping: aes(colour: "species"),
      stat: stat-summary(fun: "mean-sd"),
      height: 5pt,
    ),
    // geom-point(stat: stat-summary(fun: "mean-se"), size: 3pt),
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
