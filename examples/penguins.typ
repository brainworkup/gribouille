// Bundled penguins dataset: flipper length vs body mass by species.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  data: penguins,
  mapping: aes(
    x: "flipper-len",
    y: "body-mass",
    colour: "species",
    fill: "species",
    shape: "species",
  ),
  layers: (
    geom-point(size: 2pt, alpha: 0.25, stroke: 0.5pt, colour: rgb("#ffffff")),
    geom-smooth(method: "lm", se: true, alpha: 0.2),
    geom-errorbar(stat: stat-summary(fun: "mean-sd"), width: 5pt),
    geom-errorbarh(stat: stat-summary(fun: "mean-sd"), height: 5pt),
    geom-label(
      data: (
        "flipper-len": (180, 210, 205),
        "body-mass": (4250, 3250, 5750),
        "species": ("Adelie", "Chinstrap", "Gentoo"),
      ),
      // stat: stat-summary(fun: "mean"),
      mapping: aes(label: "species"),
      colour: rgb("#ffffff"),
      size: 8pt,
    ),
  ),
  scales: (
    scale-x-continuous(),
    scale-y-continuous(labels: label-comma()),
    scale-colour-discrete(palette: (
      rgb("#ff8c00"),
      rgb("#800080"),
      rgb("#008B8B"),
    )),
    scale-fill-discrete(palette: (
      rgb("#ff8c00"),
      rgb("#800080"),
      rgb("#008B8B"),
    )),
  ),
  labs: labs(
    title: typst("Penguins *Dataset*"),
    subtitle: typst([
      Flipper length vs body mass by species:
      #text(fill: rgb("#ff8c00"), weight: "bold")[Adelie],
      #text(fill: rgb("#008B8B"), weight: "bold")[Chinstrap],
      #text(fill: rgb("#800080"), weight: "bold")[Gentoo]
    ]),
    caption: "Data from Palmer Archipelago (Antarctica) penguin dataset.",
    colour: "Species",
    fill: "Species",
    shape: "Species",
    x: "Flipper Length (mm)",
    y: "Body Mass (g)",
  ),
  theme: theme-minimal(),
  width: 11cm,
  height: 7cm,
)

#place(
  bottom + right,
  dx: 0.5cm,
  dy: 0.5cm,
  context {
    let bg = page.fill
    let dark-bg = if bg == auto or bg == none {
      false
    } else if type(bg) == color {
      luma(bg).components().at(0) < 50%
    } else {
      false
    }
    image(
      if dark-bg {
        "../docs/assets/images/logo-stacked-dark.svg"
      } else {
        "../docs/assets/images/logo-stacked.svg"
      },
      height: 2cm,
    )
  },
)
