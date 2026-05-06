///! Joint `(x, y) → (cx, cy)` projection helpers for `coord-radial`.

#import "../scale/train.typ": map-position

// "y" when theta is "x" (rose/radar) and "x" when theta is "y" (pie).
// Returns `none` for non-radial coords. Used during scale expansion, which
// runs before trained scales exist and so cannot route through `radial-ctx`.
#let radial-axis-of(coord) = if (
  coord != none and coord.at("coord", default: none) == "radial"
) {
  if coord.at("theta", default: "x") == "x" { "y" } else { "x" }
} else { none }

// `start = 0` plus `direction = 1` reproduce ggplot2's convention: the first
// slice opens at 12 o'clock and the sweep advances clockwise. Encoding the
// sweep as a `(theta-lo, theta-hi)` pair lets `map-position` produce angles
// directly through the existing scale-mapping routines.
#let radial-ctx(coord, x-trained, y-trained, px-range, py-range) = {
  if coord == none or coord.at("coord", default: none) != "radial" {
    return none
  }
  let (px-lo, px-hi) = px-range
  let (py-lo, py-hi) = py-range
  let centre = ((px-lo + px-hi) / 2, (py-lo + py-hi) / 2)
  let r-max = calc.max(
    0,
    calc.min((px-hi - px-lo) / 2, (py-hi - py-lo) / 2),
  )
  let start = coord.at("start", default: 0)
  let direction = coord.at("direction", default: 1)
  let end = coord.at("end", default: none)
  let end-eff = if end == none { start + direction * 2 * calc.pi } else { end }
  let theta-axis = coord.at("theta", default: "x")
  let theta-lo = calc.pi / 2 - start
  let theta-hi = calc.pi / 2 - end-eff
  (
    coord: "radial",
    centre: centre,
    r-max: r-max,
    theta-axis: theta-axis,
    cat-is-theta: theta-axis == "x",
    theta-range: (theta-lo, theta-hi),
    r-range: (0, r-max),
    clip: coord.at("clip", default: "off") != "off",
    x-trained: x-trained,
    y-trained: y-trained,
  )
}

#let _theta-trained(radial) = if radial.cat-is-theta {
  radial.x-trained
} else { radial.y-trained }

#let _r-trained(radial) = if radial.cat-is-theta {
  radial.y-trained
} else { radial.x-trained }

#let radial-theta(value, radial) = {
  let trained = _theta-trained(radial)
  if trained == none { return none }
  map-position(trained, value, radial.theta-range)
}

#let radial-r(value, radial) = {
  let trained = _r-trained(radial)
  if trained == none { return none }
  map-position(trained, value, radial.r-range)
}

#let radial-point(x-val, y-val, radial) = {
  let (ang-val, rad-val) = if radial.cat-is-theta {
    (x-val, y-val)
  } else { (y-val, x-val) }
  let theta = radial-theta(ang-val, radial)
  let r = radial-r(rad-val, radial)
  if theta == none or r == none { return none }
  let (cx, cy) = radial.centre
  (cx + r * calc.cos(theta), cy + r * calc.sin(theta))
}

// Single entry point for geoms: projects a row's `(x, y)` to canvas units
// via either the trained scales or the active radial bundle. Returns `none`
// when either coordinate fails to resolve.
#let project-point(ctx, xv, yv) = {
  let radial = ctx.at("radial", default: none)
  if radial != none { return radial-point(xv, yv, radial) }
  let xt = ctx.trained.at("x", default: none)
  let yt = ctx.trained.at("y", default: none)
  if xt == none or yt == none { return none }
  let cx = map-position(xt, xv, ctx.px-range)
  let cy = map-position(yt, yv, ctx.py-range)
  if cx == none or cy == none { return none }
  (cx, cy)
}

// Group break values by canvas angle modulo a full turn. `project` maps a
// break to canvas radians (or `none` to skip). Returns an array of groups,
// where each group is an array of `(idx, b, theta)` records sharing an
// angle. First-seen order is preserved so a full-sweep wrap renders as
// `<last>/<first>` (higher-domain break first).
#let group-theta-breaks(breaks, project) = {
  let groups = ()
  let seen = (:)
  for (idx, b) in breaks.enumerate() {
    let theta = project(b)
    if theta == none { continue }
    let r = calc.rem(theta, 2 * calc.pi)
    if r < 0 { r += 2 * calc.pi }
    // 6-digit rounding absorbs float noise from `map-position` round-trips
    // so theta-lo and theta-hi (mathematically 2π apart) collide on key.
    let key = str(calc.round(r, digits: 6))
    let rec = (idx: idx, b: b, theta: theta)
    if key in seen {
      groups.at(seen.at(key)).push(rec)
    } else {
      seen.insert(key, groups.len())
      groups.push((rec,))
    }
  }
  groups
}

// Closed wedge polygon (centre or annulus segment). `theta-lo` and
// `theta-hi` are math-space radians, `r-lo` and `r-hi` are canvas units.
// `n` defaults to one step per ~5° of arc with a floor of eight steps so
// even narrow wedges look round.
#let radial-wedge(theta-lo, theta-hi, r-lo, r-hi, radial, n: none) = {
  let (cx, cy) = radial.centre
  let span = calc.abs(theta-hi - theta-lo)
  let steps = if n != none { n } else {
    calc.max(8, int(calc.ceil(span / (calc.pi / 36))))
  }
  let pts = ()
  for i in range(steps + 1) {
    let t = theta-lo + (theta-hi - theta-lo) * i / steps
    pts.push((cx + r-hi * calc.cos(t), cy + r-hi * calc.sin(t)))
  }
  if r-lo > 0 {
    for i in range(steps + 1) {
      let t = theta-hi - (theta-hi - theta-lo) * i / steps
      pts.push((cx + r-lo * calc.cos(t), cy + r-lo * calc.sin(t)))
    }
  } else {
    pts.push((cx, cy))
  }
  pts
}
