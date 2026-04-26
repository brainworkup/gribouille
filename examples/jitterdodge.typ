// position-jitterdodge: scatter over a numeric x with two colour groups dodged then jittered.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = ()
#for x in (1, 2, 3, 4) {
  for grp in ("treated", "control") {
    for _ in range(0, 10) {
      d.push((x: x, y: 1, grp: grp))
    }
  }
}

#plot(
  data: d,
  mapping: aes(x: "x", y: "y", colour: "grp"),
  layers: (
    geom-jitter(
      size: 2pt,
      position: position-jitterdodge(width: 0.15, dodge-width: 0.6),
    ),
  ),
  width: 10cm,
  height: 4cm,
)
