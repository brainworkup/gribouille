// Binned shape and linetype scales: continuous variable cut into n bins, each bin gets one
// shape (point geom) or one dash pattern (line geom).

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let pts = range(0, 12).map(i => (x: i, y: i, w: i + 1))

#let lined = ()
#for q in range(1, 7) {
  for x in range(0, 6) {
    lined.push((x: x, y: x + q * 0.3, q: q))
  }
}

#let panel(title, body) = {
  set align(center)
  stack(dir: ttb, spacing: 0.2cm, text(weight: "bold", title), body)
}

#stack(
  dir: ttb,
  spacing: 0.4cm,
  panel(
    "scale-shape-binned(n-breaks: 4)",
    plot(
      data: pts,
      mapping: aes(x: "x", y: "y", shape: "w"),
      layers: (geom-point(size: 4pt),),
      scales: (scale-shape-binned(n-breaks: 4),),
      labs: labs(x: "x", y: "y", shape: "Bin"),
      theme: theme-minimal(),
      width: 9cm,
      height: 4cm,
    ),
  ),
  panel(
    "scale-shape-binned with custom palette",
    plot(
      data: pts,
      mapping: aes(x: "x", y: "y", shape: "w"),
      layers: (geom-point(size: 4pt),),
      scales: (
        scale-shape-binned(
          n-breaks: 6,
          palette: ("circle", "square", "triangle", "diamond", "cross", "x"),
        ),
      ),
      labs: labs(x: "x", y: "y", shape: "Bin"),
      theme: theme-minimal(),
      width: 9cm,
      height: 4cm,
    ),
  ),
  panel(
    "scale-linetype-binned(n-breaks: 3)",
    plot(
      data: lined,
      mapping: aes(x: "x", y: "y", linetype: "q", group: "q"),
      layers: (geom-line(stroke: 1pt),),
      scales: (scale-linetype-binned(n-breaks: 3),),
      labs: labs(x: "x", y: "y", linetype: "Bin"),
      theme: theme-minimal(),
      width: 9cm,
      height: 4cm,
    ),
  ),
)
