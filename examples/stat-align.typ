// stat-align resamples each group onto a shared x-grid so stacked areas
// share clean vertices even when the inputs use mismatched x values.

#import "../lib.typ": *

#set page(width: 14cm)

#let d = (
  (x: 0, y: 1, k: "a"),
  (x: 2, y: 3, k: "a"),
  (x: 4, y: 2, k: "a"),
  (x: 6, y: 1, k: "a"),
  (x: 1, y: 2, k: "b"),
  (x: 3, y: 1, k: "b"),
  (x: 5, y: 3, k: "b"),
  (x: 7, y: 2, k: "b"),
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", fill: "k"),
  layers: (geom-area(stat: stat-align(), position: "stack", alpha: 0.7),),
  labs: labs(title: "Stat-Align: Stacked Areas on a Shared X-Grid"),
  theme: theme-minimal(),
  width: 14cm,
  height: 8cm,
)
