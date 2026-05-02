// Scatter with an OLS smoother and 95% CI band.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  data: mpg,
  mapping: aes(x: "displ", y: "hwy"),
  layers: (
    geom-point(size: 2.5pt, alpha: 0.75, colour: rgb("#1f77b4")),
    geom-smooth(
      method: "lm",
      colour: rgb("#1f77b4"),
      fill: rgb("#1f77b4"),
      alpha: 0.2,
    ),
  ),
  labs: labs(
    title: "Engine displacement versus highway fuel economy",
    subtitle: "Linear fit with 95% confidence band",
    x: "Displacement (L)",
    y: "Highway mpg",
  ),
  theme: theme-minimal(),
  width: 11cm,
  height: 6.5cm,
)
