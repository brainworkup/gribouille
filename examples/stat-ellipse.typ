// stat-ellipse: per-group covariance ellipse drawn through geom-ellipse.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  data: penguins,
  mapping: aes(
    x: "flipper-len",
    y: "body-mass",
    fill: "species",
    colour: "species",
  ),
  layers: (
    geom-ellipse(stat: stat-ellipse(level: 0.95), alpha: 0.2),
    geom-point(size: 2pt, alpha: 0.85),
  ),
  scales: (scale-y-continuous(labels: label-comma()),),
  labs: labs(
    title: "Penguin species clusters",
    subtitle: "stat-ellipse draws the 95% covariance ellipse around each group",
    x: "Flipper length (mm)",
    y: "Body mass (g)",
    colour: "Species",
    fill: "Species",
  ),
  theme: theme-minimal(),
  width: 12cm,
  height: 9cm,
)
