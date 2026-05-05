///! Joint `(x, y) → (cx, cy)` projection helpers for `coord-polar`.

#import "../scale/train.typ": map-position

// `start = 0` plus `direction = 1` reproduce ggplot2's convention: the first
// slice opens at 12 o'clock and the sweep advances clockwise. Encoding the
// sweep as a `(theta-lo, theta-hi)` pair lets `map-position` produce angles
// directly through the existing scale-mapping routines.
#let polar-ctx(coord, x-trained, y-trained, px-range, py-range) = {
  if coord == none or coord.at("coord", default: none) != "polar" {
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
  let theta-axis = coord.at("theta", default: "x")
  let theta-lo = calc.pi / 2 - start
  let theta-hi = theta-lo - direction * 2 * calc.pi
  (
    coord: "polar",
    centre: centre,
    r-max: r-max,
    theta-axis: theta-axis,
    cat-is-theta: theta-axis == "x",
    theta-range: (theta-lo, theta-hi),
    r-range: (0, r-max),
    clip: coord.at("clip", default: "on") != "off",
    x-trained: x-trained,
    y-trained: y-trained,
  )
}

#let _theta-trained(polar) = if polar.cat-is-theta {
  polar.x-trained
} else { polar.y-trained }

#let _r-trained(polar) = if polar.cat-is-theta {
  polar.y-trained
} else { polar.x-trained }

#let polar-theta(value, polar) = {
  let trained = _theta-trained(polar)
  if trained == none { return none }
  map-position(trained, value, polar.theta-range)
}

#let polar-r(value, polar) = {
  let trained = _r-trained(polar)
  if trained == none { return none }
  map-position(trained, value, polar.r-range)
}

#let polar-point(x-val, y-val, polar) = {
  let (ang-val, rad-val) = if polar.cat-is-theta {
    (x-val, y-val)
  } else { (y-val, x-val) }
  let theta = polar-theta(ang-val, polar)
  let r = polar-r(rad-val, polar)
  if theta == none or r == none { return none }
  let (cx, cy) = polar.centre
  (cx + r * calc.cos(theta), cy + r * calc.sin(theta))
}

// Single entry point for geoms: projects a row's `(x, y)` to canvas units
// via either the trained scales or the active polar bundle. Returns `none`
// when either coordinate fails to resolve.
#let project-point(ctx, xv, yv) = {
  let polar = ctx.at("polar", default: none)
  if polar != none { return polar-point(xv, yv, polar) }
  let xt = ctx.trained.at("x", default: none)
  let yt = ctx.trained.at("y", default: none)
  if xt == none or yt == none { return none }
  let cx = map-position(xt, xv, ctx.px-range)
  let cy = map-position(yt, yv, ctx.py-range)
  if cx == none or cy == none { return none }
  (cx, cy)
}

// Closed wedge polygon (centre or annulus segment). `theta-lo` and
// `theta-hi` are math-space radians, `r-lo` and `r-hi` are canvas units.
// `n` defaults to one step per ~5° of arc with a floor of eight steps so
// even narrow wedges look round.
#let polar-wedge(theta-lo, theta-hi, r-lo, r-hi, polar, n: none) = {
  let (cx, cy) = polar.centre
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
