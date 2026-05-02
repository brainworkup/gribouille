// facet-grid: panels arranged on a row × column grid of two discrete variables.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  data: penguins,
  mapping: aes(x: "flipper-len", y: "body-mass", colour: "species"),
  layers: (geom-point(size: 2pt, alpha: 0.85),),
  facet: facet-grid(rows: "sex", cols: "species", labeller: label-both()),
  scales: (scale-y-continuous(labels: label-comma()),),
  guides: guides(colour: guide-none()),
  labs: labs(
    title: "Penguin morphology by sex and species",
    x: "Flipper length (mm)",
    y: "Body mass (g)",
  ),
  theme: theme-minimal(),
  width: 14cm,
  height: 7.5cm,
)
