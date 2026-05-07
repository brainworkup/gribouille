// `after-stat` binds an aesthetic to a column produced by the layer's
// stat. Here `geom-bar` runs `stat-count`, publishing `_count` per
// category; we map y to the same column explicitly and scale the count
// with a closure form for emphasis.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let d = (
  (grp: "a"),
  (grp: "b"),
  (grp: "a"),
  (grp: "c"),
  (grp: "a"),
  (grp: "b"),
  (grp: "d"),
  (grp: "a"),
)

#plot(
  data: d,
  mapping: aes(
    x: "grp",
    y: after-stat((row, _) => row._count * 2),
    fill: "grp",
  ),
  layers: (geom-bar(),),
  guides: guides(fill: guide-none()),
  labs: labs(
    title: "Count × 2 via after-stat closure",
    x: "Group",
    y: "Count × 2",
  ),
  theme: theme-minimal(),
  width: 11cm,
  height: 6cm,
)
