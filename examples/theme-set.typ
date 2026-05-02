// theme-set: install a global default once; subsequent plots inherit it
// unless they pass an explicit `theme:` argument.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.4cm)

#theme-set(theme-minimal())

#let d = range(0, 10).map(i => (x: i, y: i * 0.5))

// Inherits theme-minimal() from theme-set above.
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 2pt),),
  labs: labs(title: "Inherits global theme-minimal"),
  width: 10cm,
  height: 4cm,
)

// Explicit theme: argument takes precedence over the global state.
#plot(
  data: d,
  mapping: aes(x: "x", y: "y"),
  layers: (geom-point(size: 2pt),),
  labs: labs(title: "Explicit theme-dark overrides the global"),
  theme: theme-dark(),
  width: 10cm,
  height: 4cm,
)
