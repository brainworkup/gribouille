// position-jitter and position-nudge: jittered scatter plus offset labels.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = ()
#for x in (1, 2, 3, 4) {
  for _ in range(0, 14) {
    d.push((x: x, y: 1, lab: "x=" + str(x)))
  }
}

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-jitter(size: 2pt),),
  width: 9cm,
  height: 4cm,
)
