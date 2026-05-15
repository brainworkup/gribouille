#set page(width: auto, height: auto, margin: 1cm)
#import "../lib.typ": *

#let mtcars = (
  (mpg: 21.0, wt: 2.620, hp: 110, cyl: "6"),
  (mpg: 22.8, wt: 2.320, hp: 93, cyl: "4"),
  (mpg: 18.7, wt: 3.440, hp: 175, cyl: "8"),
  (mpg: 16.4, wt: 4.070, hp: 205, cyl: "8"),
  (mpg: 33.9, wt: 1.835, hp: 113, cyl: "4"),
  (mpg: 21.4, wt: 3.215, hp: 110, cyl: "6"),
)

= Per-plot legends (`collect: none`)

#compose(
  plot(
    data: mtcars,
    mapping: aes(x: "wt", y: "mpg", colour: as-factor("cyl")),
    layers: (geom-point(size: 3pt),),
    width: 6cm,
    height: 4cm,
    defer: true,
  ),
  plot(
    data: mtcars,
    mapping: aes(x: "hp", y: "mpg", colour: as-factor("cyl")),
    layers: (geom-point(size: 3pt),),
    width: 6cm,
    height: 4cm,
    defer: true,
  ),
  layout: "grid",
  columns: 2,
  collect: none,
)

= Auto-collect every mergeable aesthetic (default)

#compose(
  plot(
    data: mtcars,
    mapping: aes(x: "wt", y: "mpg", colour: as-factor("cyl")),
    layers: (geom-point(size: 3pt),),
    width: 6cm,
    height: 4cm,
    defer: true,
  ),
  plot(
    data: mtcars,
    mapping: aes(x: "hp", y: "mpg", colour: as-factor("cyl")),
    layers: (geom-point(size: 3pt),),
    width: 6cm,
    height: 4cm,
    defer: true,
  ),
  layout: "grid",
  columns: 2,
)

= Restrict hoisting to a subset of aesthetics

#compose(
  plot(
    data: mtcars,
    mapping: aes(x: "wt", y: "mpg", colour: as-factor("cyl"), size: "hp"),
    layers: (geom-point(),),
    width: 6cm,
    height: 4cm,
    defer: true,
  ),
  plot(
    data: mtcars,
    mapping: aes(x: "hp", y: "mpg", colour: as-factor("cyl"), size: "wt"),
    layers: (geom-point(),),
    width: 6cm,
    height: 4cm,
    defer: true,
  ),
  layout: "grid",
  columns: 2,
  collect: ("colour",),
  guides-placement: "right",
)
