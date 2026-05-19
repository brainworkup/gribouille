// Standalone cascade figure for docs/guides/theming.qmd.
//
// Compile from the project root for debugging:
//
//   typst compile --root . docs/guides/_theme-cascade.typ docs/guides/_theme-cascade.pdf
//
// The .qmd page reuses this file via the `file: _theme-cascade.typ` chunk
// option; do not move or rename it without updating that reference.

#import "@preview/cetz:0.5.2": canvas, draw

#set page(width: auto, height: auto, margin: 0.5cm)

#let _ink = {
  let v = sys.inputs.at("typst-render-foreground", default: "")
  if v == "" { rgb("#1f2328") } else { rgb(v) }
}
#let _paper = {
  let v = sys.inputs.at("typst-render-background", default: "")
  if v == "" { rgb("#ffffff") } else { rgb(v) }
}
#let _muted = rgb("#666666")
#let _accent-text = rgb("#1f77b4")
#let _accent-line = rgb("#2ca02c")
#let _accent-rect = rgb("#d6604d")
#let _accent-axis = rgb("#7c3aed")

#let _node(label, stroke: _ink, txt: _ink, mono: true) = {
  let body = if mono {
    text(size: 7pt, font: "DejaVu Sans Mono", fill: txt)[#raw(label)]
  } else {
    text(size: 7pt, weight: "bold", fill: txt)[#label]
  }
  box(
    inset: (x: 4pt, y: 2.5pt),
    fill: _paper,
    stroke: 0.4pt + stroke,
    radius: 2pt,
    body,
  )
}

#let _base-fanout(origin, label, accent, children) = {
  import draw: *
  let (ox, oy) = origin
  let root = (ox, oy)
  content(root, anchor: "west", _node(
    label,
    stroke: accent,
    txt: accent,
    mono: false,
  ))

  let step = 0.55
  let cx = ox + 2.4
  let top = oy - 0.4
  for (i, child) in children.enumerate() {
    let cy = top - step * i
    line((ox + 0.55, oy), (cx - 0.1, cy), stroke: 0.3pt + accent)
    content(
      (cx, cy),
      anchor: "west",
      _node(child, stroke: _muted, txt: _muted),
    )
  }
}

#canvas(length: 1cm, {
  import draw: *
  set-style(content: (frame: none))

  // ===== Section 1 — Base element fan-out =====
  content(
    (-0.2, 0.7),
    anchor: "south-west",
    text(
      size: 9pt,
      weight: "bold",
      fill: _ink,
    )[Base records feed every descendant],
  )
  content(
    (-0.2, 0.15),
    anchor: "south-west",
    text(size: 7.5pt, fill: _muted)[
      Setting `text`, `line`, or `rect` cascades to every surface in its column.
      Fields unset on the child inherit from the parent.
    ],
  )

  _base-fanout(
    (-0.2, -1.0),
    "text",
    _accent-text,
    (
      "axis-text",
      "axis-title",
      "legend-text",
      "legend-title",
      "strip-text",
      "plot-title",
      "plot-subtitle",
      "plot-caption",
    ),
  )

  _base-fanout(
    (6.0, -1.0),
    "line",
    _accent-line,
    ("panel-grid", "axis-line", "axis-ticks", "legend-ticks"),
  )

  _base-fanout(
    (11.8, -1.0),
    "rect",
    _accent-rect,
    (
      "panel-background",
      "plot-background",
      "strip-background",
      "legend-background",
      "legend-bar",
    ),
  )

  // Divider.
  line((-0.2, -6.4), (17.6, -6.4), stroke: 0.3pt + _muted)

  // ===== Section 2 — Axis family cascade (single template) =====
  content(
    (-0.2, -6.9),
    anchor: "south-west",
    text(
      size: 9pt,
      weight: "bold",
      fill: _ink,
    )[Axis family cascade (one template, four families)],
  )
  content(
    (-0.2, -7.45),
    anchor: "south-west",
    text(size: 7.5pt, fill: _muted)[
      Replace `<family>` with `axis-line`, `axis-ticks`, `axis-text`, or `axis-title`.
      Per-side leaves cascade up to per-axis, then to the family root.
      `tick-length` follows the same three-step cascade with a Typst length value.
    ],
  )

  let root-pos = (8.8, -9.0)
  let ax-x = (4.4, -10.6)
  let ax-y = (13.2, -10.6)
  let xb = (1.4, -12.2)
  let xt = (6.6, -12.2)
  let yl = (10.6, -12.2)
  let yr = (15.8, -12.2)

  let edge(a, b) = line(a, b, stroke: 0.5pt + _accent-axis)

  edge(root-pos, ax-x)
  edge(root-pos, ax-y)
  edge(ax-x, xb)
  edge(ax-x, xt)
  edge(ax-y, yl)
  edge(ax-y, yr)

  content(root-pos, _node("<family>", stroke: _accent-axis, txt: _accent-axis))
  content(ax-x, _node("<family>-x", stroke: _accent-axis, txt: _ink))
  content(ax-y, _node("<family>-y", stroke: _accent-axis, txt: _ink))
  content(xb, _node("<family>-x-bottom", stroke: _muted, txt: _muted))
  content(xt, _node("<family>-x-top", stroke: _muted, txt: _muted))
  content(yl, _node("<family>-y-left", stroke: _muted, txt: _muted))
  content(yr, _node("<family>-y-right", stroke: _muted, txt: _muted))
})
