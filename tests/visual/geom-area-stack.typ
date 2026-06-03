// Smoke render: stacked areas must not overlap.
//
// With `position: "stack"` each band's lower edge should sit at the
// cumulated top of the band below it, not at y = 0.

#import "../../lib.typ": *

#set page(width: auto, height: auto, margin: 0cm)

#let d = ()
#for grp in ("a", "b") {
  for i in range(0, 8) {
    d.push((x: i, y: 1.0 + i * 0.2, grp: grp))
  }
}

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", fill: "grp"),
  layers: (geom-area(position: "stack", alpha: 0.6),),
  labs: labs(title: "geom-area stacked"),
  theme: theme-minimal(),
  width: 10cm,
  height: 6cm,
)
