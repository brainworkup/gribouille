// facet strip bands grow to fit wrapped labels.
//
// Long facet-level names wrapped with `label-wrap-gen` would otherwise
// overflow the fixed strip band and be cropped by the panel; the band is now
// sized to the rendered label height. Two plots: facet-wrap (top strips) and
// facet-grid (top strips plus rotated side strips, both wrapped).

#import "../../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let data = (
  (x: 1, y: 2, grp: "Northern Long-tailed Tit", side: "Upper Reaches"),
  (x: 2, y: 3, grp: "Northern Long-tailed Tit", side: "Lower Reaches"),
  (x: 3, y: 1, grp: "Eurasian Reed Warbler", side: "Upper Reaches"),
  (x: 1, y: 4, grp: "Eurasian Reed Warbler", side: "Lower Reaches"),
  (x: 2, y: 2, grp: "Common Whitethroat", side: "Upper Reaches"),
  (x: 3, y: 5, grp: "Common Whitethroat", side: "Lower Reaches"),
)

#stack(
  dir: ttb,
  spacing: 0.6cm,
  plot(
    data: data,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-point(),),
    facet: facet-wrap("grp", ncol: 3, labeller: label-wrap-gen(width: 10)),
    width: 12cm,
    height: 4cm,
  ),
  plot(
    data: data,
    mapping: aes(x: "x", y: "y"),
    layers: (geom-point(),),
    facet: facet-grid(
      rows: "side",
      cols: "grp",
      labeller: label-wrap-gen(width: 10),
    ),
    width: 12cm,
    height: 6cm,
  ),
)
