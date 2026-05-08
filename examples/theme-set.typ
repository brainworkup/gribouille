// theme-set installs a global default once; subsequent plots inherit it
// unless they pass an explicit `theme:` argument.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#theme-set(theme-minimal())

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#stack(
  dir: ttb,
  spacing: 0.5cm,
  panel(
    "Inherits the global theme-minimal",
    plot(
      data: penguins,
      mapping: aes(x: "flipper-len", y: "body-mass", colour: "species"),
      layers: (geom-point(size: 2pt, alpha: 0.85),),
      scales: (scale-y-continuous(labels: label-comma()),),
      labs: labs(
        x: "Flipper length (mm)",
        y: "Body mass (g)",
        colour: "Species",
      ),
      width: 12cm,
      height: 9cm,
    ),
  ),
  panel(
    "Explicit theme-dark overrides the global",
    plot(
      data: penguins,
      mapping: aes(x: "flipper-len", y: "body-mass", colour: "species"),
      layers: (geom-point(size: 2pt, alpha: 0.85),),
      scales: (scale-y-continuous(labels: label-comma()),),
      labs: labs(
        x: "Flipper length (mm)",
        y: "Body mass (g)",
        colour: "Species",
      ),
      theme: theme-dark(),
      width: 12cm,
      height: 9cm,
    ),
  ),
)
