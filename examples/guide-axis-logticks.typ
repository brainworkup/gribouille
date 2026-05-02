// guide-axis-logticks adds minor ticks at log-scale subdivisions on a
// log10-trans axis. Without it, only decade-aligned major ticks render.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#let d = (
  (x: 1, y: 1),
  (x: 3, y: 5),
  (x: 10, y: 25),
  (x: 30, y: 100),
  (x: 100, y: 500),
  (x: 300, y: 2500),
  (x: 1000, y: 10000),
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 3pt),),
  scales: (
    scale-x-continuous(trans: "log10"),
    scale-y-continuous(trans: "log10"),
  ),
  labs: labs(title: "Log10 axes, no logticks (decade ticks only)"),
  width: 10cm,
  height: 6cm,
)

#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 3pt),),
  scales: (
    scale-x-continuous(trans: "log10"),
    scale-y-continuous(trans: "log10"),
  ),
  guides: guides(
    x: guide-axis-logticks(),
    y: guide-axis-logticks(),
  ),
  labs: labs(title: "guide-axis-logticks() on x and y"),
  width: 10cm,
  height: 6cm,
)

// Logticks on a non-log axis is a no-op (silent fallback to plain ticks).
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 3pt),),
  guides: guides(x: guide-axis-logticks()),
  labs: labs(title: "logticks ignored on a linear axis"),
  width: 10cm,
  height: 6cm,
)
