// geom-polygon: closed filled polygons, one per group.

#import "../lib.typ": *

#set page(width: 12cm)

#let zones = (
  (x: 0, y: 0, zone: "Lowlands"),
  (x: 4, y: 0, zone: "Lowlands"),
  (x: 4, y: 1.5, zone: "Lowlands"),
  (x: 0, y: 1.5, zone: "Lowlands"),

  (x: 0.5, y: 1.5, zone: "Hills"),
  (x: 3.5, y: 1.5, zone: "Hills"),
  (x: 3, y: 3.5, zone: "Hills"),
  (x: 1, y: 3.5, zone: "Hills"),

  (x: 1.4, y: 3.5, zone: "Peak"),
  (x: 2.6, y: 3.5, zone: "Peak"),
  (x: 2, y: 5, zone: "Peak"),
)

#plot(
  data: zones,
  mapping: aes(x: "x", y: "y", fill: "zone"),
  layers: (geom-polygon(alpha: 0.6, stroke: 0.6pt),),
  scales: (
    scale-fill-manual(values: (
      rgb("#a1d99b"),
      rgb("#fdae6b"),
      rgb("#9ecae1"),
    )),
  ),
  coord: coord-fixed(),
  labs: labs(
    title: "Stylised altitude zones",
    subtitle: "One filled polygon per zone, drawn from row order",
    x: "x",
    y: "y",
    fill: "Zone",
  ),
  theme: theme-minimal(),
  width: 12cm,
  height: 9cm,
)
