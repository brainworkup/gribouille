#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#set page(foreground: context {
  let bg = page.fill
  let dark-bg = if bg == auto or bg == none {
    false
  } else if type(bg) == color {
    luma(bg).components().at(0) < 50%
  } else {
    false
  }
  place(
    top + right,
    dx: -0.25cm,
    dy: 0.25cm,
    image(
      if dark-bg {
        "/docs/assets/images/logo-stacked-dark.svg"
      } else {
        "/docs/assets/images/logo-stacked.svg"
      },
      height: 9cm,
    ),
  )
})

#let species-card(name, note, colour, ink, paper) = context {
  block(
    width: auto,
    inset: 0pt,
    radius: 4pt,
    fill: paper,
    stroke: (paint: colour, thickness: 0.6pt),
  )[
    #set block(spacing: 0pt)

    #block(
      inset: 2pt,
      radius: 4pt,
      fill: colour,
    )[
      #set text(size: 6pt, weight: "bold", fill: if luma(colour)
        .components()
        .at(0)
        < 50% { white } else { black })
      #set par(spacing: 0pt, leading: 0.85em)
      #name
    ]
    #block(inset: (x: 4pt, y: 3pt))[
      #set text(size: 5.4pt, fill: ink)
      #note
    ]
  ]
}

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
    geom-mark(method: "hull", expand: 5pt, alpha: 0.25),
    geom-errorbar(stat: stat-summary(fun: "mean-sd"), width: 5pt),
    geom-errorbarh(stat: stat-summary(fun: "mean-sd"), height: 5pt),
    geom-typst(
      data: (
        (
          x: 183,
          y: 5000,
          species: "Adelie",
          label: [
            #species-card(
              "Adelie",
              "Compact and stable mass profile.",
              rgb("#ff8c00"),
              black,
              white,
            )
          ],
        ),
        (
          x: 211,
          y: 2900,
          species: "Chinstrap",
          label: [
            #species-card(
              "Chinstrap",
              "Similar centre to Adelie, with tighter spread.",
              rgb("#008B8B"),
              black,
              white,
            )
          ],
        ),
        (
          x: 203,
          y: 6150,
          species: "Gentoo",
          label: [
            #species-card(
              "Gentoo",
              "Heavier birds and broader variability.",
              rgb("#800080"),
              black,
              white,
            )
          ],
        ),
      ),
      mapping: aes(
        x: "x",
        y: "y",
        label: "label",
      ),
      inherit-aes: false,
    ),
  ),
  scales: (
    scale-x-continuous(),
    scale-y-continuous(labels: label-comma()),
    scale-colour-discrete(
      limits: ("Adelie", "Chinstrap", "Gentoo"),
      palette: (
        rgb("#ff8c00"),
        rgb("#008B8B"),
        rgb("#800080"),
      ),
    ),
    scale-fill-discrete(
      limits: ("Adelie", "Chinstrap", "Gentoo"),
      palette: (
        rgb("#ff8c00"),
        rgb("#008B8B"),
        rgb("#800080"),
      ),
    ),
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
  theme: theme-minimal(
    axis-line: element-line(thickness: 0.5pt),
    tick-length: 0.05cm,
  ),
  guides: guides(
    colour: guide-none(),
    fill: guide-none(),
    shape: guide-none(),
  ),
  width: 12cm,
  height: 9cm,
)
