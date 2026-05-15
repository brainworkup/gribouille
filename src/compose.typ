#import "render.typ": render-plot-deferred
#import "legend.typ" as legend-mod
#import "theme/defaults.typ": merge-theme

// Compose multiple plots into a single grid or stack and hoist legends that
// describe the same scale across all panels into one shared block.
//
// Each positional argument must be the dictionary returned by `plot(..., defer:
// true)`; rendered plots are not accepted because compose needs the spec to
// re-render with hoisted aesthetics suppressed.
//
// Per-aesthetic collection:
//   collect: auto                  hoist every aesthetic mergeable across panels
//   collect: none                  no hoisting (each plot keeps its legends)
//   collect: ("colour", "fill")    restrict hoisting to the listed aesthetics
//
// The shared legend appears on `guides-placement` ("right" by default).
#let _is-plot-spec(x) = (
  type(x) == dictionary
    and "layers" in x
    and "data" in x
    and "width" in x
    and "height" in x
    and "guides" in x
)

#let _index-by-aesthetic(guides) = {
  let out = (:)
  for g in guides {
    for a in g.at("aesthetics", default: ()) {
      out.insert(a, g)
    }
  }
  out
}

#let _all-mergeable(per-panel, aes-name) = {
  let first = none
  for idx in per-panel {
    let g = idx.at(aes-name, default: none)
    if g == none { return false }
    if first == none {
      first = g
    } else if not legend-mod.can-merge-cross-panel(first, g) {
      return false
    }
  }
  first != none
}

#let _coerce-placement(g, side) = (
  ..g,
  placement: (
    ..g.placement,
    side: side,
    direction: if side == "top" or side == "bottom" {
      "horizontal"
    } else { "vertical" },
  ),
)

#let _legend-canvas-size(guides, side) = {
  let extents = legend-mod.estimate-extents(guides)
  if side == "right" or side == "left" {
    let height = 0.0
    for g in guides { height += g.at("height", default: 0.0) + 0.2 }
    (width: extents.at(side), height: height)
  } else {
    let width = 0.0
    for g in guides { width += g.at("width", default: 0.0) + 0.15 }
    (width: width, height: extents.at(side))
  }
}

#let compose(
  ..panels-positional,
  layout: "grid",
  columns: 2,
  dir: ttb,
  gutter: 0.5cm,
  collect: auto,
  guides-placement: "right",
) = {
  let panels = panels-positional.pos()
  if panels.len() == 0 {
    panic("compose: at least one deferred plot is required")
  }
  for p in panels {
    if not _is-plot-spec(p) {
      panic(
        "compose: every positional argument must be `plot(..., defer: true)`; "
          + "got "
          + repr(p),
      )
    }
  }
  if collect != auto and collect != none and type(collect) != array {
    panic(
      "compose: `collect` must be `auto`, `none`, or an array of aesthetic names",
    )
  }
  if not ("right", "left", "top", "bottom").contains(guides-placement) {
    panic(
      "compose: guides-placement must be \"right\", \"left\", \"top\", or "
        + "\"bottom\"; got "
        + repr(guides-placement),
    )
  }

  context {
    let probes = panels.map(spec => render-plot-deferred(spec))
    let per-panel = probes.map(p => _index-by-aesthetic(p.guides))

    let candidates = if collect == auto {
      let all = ()
      for idx in per-panel {
        for a in idx.keys() {
          if not all.contains(a) { all.push(a) }
        }
      }
      all
    } else if collect == none {
      ()
    } else {
      collect
    }

    let hoisted = ()
    let hoisted-guides = ()
    for a in candidates {
      if not _all-mergeable(per-panel, a) { continue }
      hoisted.push(a)
      let g = _coerce-placement(per-panel.first().at(a), guides-placement)
      // A merged guide (e.g., colour+fill on the same column) is reached
      // through every aesthetic it carries, so dedup by aesthetic mix.
      if not hoisted-guides.any(h => h.aesthetics == g.aesthetics) {
        hoisted-guides.push(g)
      }
    }

    let final-panels = if hoisted.len() == 0 {
      probes.map(p => p.content)
    } else {
      panels.map(spec => {
        render-plot-deferred(
          spec,
          suppress-aesthetics: hoisted,
        ).content
      })
    }

    let panel-block = if layout == "grid" {
      grid(columns: columns, gutter: gutter, ..final-panels)
    } else if layout == "stack" {
      stack(dir: dir, spacing: gutter, ..final-panels)
    } else {
      panic(
        "compose: layout must be \"grid\" or \"stack\"; got " + repr(layout),
      )
    }

    if hoisted-guides.len() == 0 {
      return panel-block
    }

    let theme = merge-theme(panels.first().theme)
    let trained = probes.first().trained
    let size = _legend-canvas-size(hoisted-guides, guides-placement)
    let legend-canvas = legend-mod.standalone(
      hoisted-guides,
      trained,
      theme,
      size.width,
      size.height,
    )

    if guides-placement == "right" {
      stack(dir: ltr, spacing: gutter, panel-block, legend-canvas)
    } else if guides-placement == "left" {
      stack(dir: ltr, spacing: gutter, legend-canvas, panel-block)
    } else if guides-placement == "bottom" {
      stack(dir: ttb, spacing: gutter, panel-block, legend-canvas)
    } else {
      stack(dir: ttb, spacing: gutter, legend-canvas, panel-block)
    }
  }
}
