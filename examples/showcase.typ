// Showcase used by docs/index.qmd: faceted penguins with a linear smoother.

#import "../lib.typ": *

#set page(width: 12cm)

#plot(
  data: penguins,
  mapping: aes(
    x: "flipper-len",
    y: "body-mass",
    colour: "species",
    fill: "species",
  ),
  layers: (
    geom-point(size: 2pt, alpha: 0.85),
    geom-smooth(method: "lm", alpha: 0.2),
  ),
  facet: facet-wrap("island", labeller: label-both()),
  scales: (scale-y-continuous(labels: label-comma()),),
  labs: labs(
    title: "Penguin morphology by island",
    subtitle: "Flipper length versus body mass with a per-species linear fit",
    x: "Flipper length (mm)",
    y: "Body mass (g)",
    colour: "Species",
    fill: "Species",
  ),
  theme: theme-minimal(),
  width: 12cm,
  height: 9cm,
)
