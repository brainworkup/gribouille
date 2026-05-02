// guide-axis customises tick labels on either axis.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let months = (
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
)
#let d = months.enumerate().map(((i, m)) => (m: m, v: i + 1))

#plot(
  data: d,
  mapping: aes(x: "m", y: "v"),
  layers: (geom-col(),),
  labs: labs(title: "Default x-axis labels (overlap)"),
  width: 10cm,
  height: 4cm,
)

#plot(
  data: d,
  mapping: aes(x: "m", y: "v"),
  layers: (geom-col(),),
  guides: guides(x: guide-axis(angle: 30)),
  labs: labs(title: "x: guide-axis(angle: 30)"),
  width: 10cm,
  height: 4cm,
)

#plot(
  data: d,
  mapping: aes(x: "m", y: "v"),
  layers: (geom-col(),),
  guides: guides(x: guide-axis(n-dodge: 2)),
  labs: labs(title: "x: guide-axis(n-dodge: 2)"),
  width: 10cm,
  height: 4cm,
)

// y-axis: rotate or dodge discrete category labels.
#let cities = ("Anvers", "Bruxelles", "Charleroi", "Liège", "Mons")
#let d2 = cities.enumerate().map(((i, c)) => (v: i + 1, c: c))

#plot(
  data: d2,
  mapping: aes(x: "v", y: "c"),
  layers: (geom-point(size: 3pt),),
  guides: guides(y: guide-axis(angle: 30)),
  labs: labs(title: "y: guide-axis(angle: 30)"),
  width: 10cm,
  height: 4cm,
)

#plot(
  data: d2,
  mapping: aes(x: "v", y: "c"),
  layers: (geom-point(size: 3pt),),
  guides: guides(y: guide-axis(n-dodge: 2)),
  labs: labs(title: "y: guide-axis(n-dodge: 2)"),
  width: 10cm,
  height: 4cm,
)
