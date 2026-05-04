// `_draw-axis-and-layers` clips geoms via a sibling `cetz.canvas` and a
// surrounding `box(clip: true, ...)`. The inner canvas's bounding box must
// match the panel rectangle, otherwise Typst's default top-start alignment
// inside the fixed-size box shifts every geom up-and-left within the panel.
//
// This is enforced by `hide(rect((0, 0), (panel-w, panel-h)), bounds: true)`:
// in cetz 0.5.0, `hide()` defaults to `bounds: false`, which tags the rect
// `no-bounds` and excludes it from the canvas's bounding box. We rely on
// `bounds: true` to keep the rect contributing to the bounding box.

#import "../../src/deps.typ": cetz

#import "../../lib.typ": *

#context {
  // Without `bounds: true`, an empty-but-bounded rect collapses the canvas:
  // only visible drawables count, so a `hide`d rect with the default flag
  // adds nothing.
  let empty = cetz.canvas({
    import cetz.draw: hide, rect
    hide(rect((0, 0), (5, 3)))
  })
  let m-empty = measure(empty)
  assert(m-empty.width < 5cm)
  assert(m-empty.height < 3cm)

  // With `bounds: true`, the same hidden rect pins the canvas to its size.
  let pinned = cetz.canvas({
    import cetz.draw: hide, rect
    hide(rect((0, 0), (5, 3)), bounds: true)
  })
  let m-pinned = measure(pinned)
  assert.eq(m-pinned.width, 5cm)
  assert.eq(m-pinned.height, 3cm)

  // End-to-end render: a plot through the public API produces non-empty
  // output, exercising the inner-canvas/clip path with `bounds: true`.
  let p = plot(
    data: ((x: 1, y: 1), (x: 2, y: 2), (x: 3, y: 3)),
    mapping: aes(x: "x", y: "y"),
    layers: (geom-point(),),
    width: 8cm,
    height: 5cm,
  )
  let m-plot = measure(p)
  assert(m-plot.width > 0cm)
  assert(m-plot.height > 0cm)
}

Render clip-bounds tests passed.
