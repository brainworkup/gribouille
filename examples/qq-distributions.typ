// Q-Q plots against three reference distributions: normal, uniform, and
// exponential. Each panel uses a sample drawn from the matching family so
// the IQR-fitted reference line follows the points closely.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let _lcg(seed) = {
  calc.rem(seed * 1103515245 + 12345, 2147483648)
}

#let _draw-normal(n) = {
  let seed = 1234567
  let out = ()
  let i = 0
  while i < n {
    let acc = 0.0
    let j = 0
    while j < 12 {
      seed = _lcg(seed)
      acc = acc + seed / 2147483648
      j = j + 1
    }
    out.push((v: acc - 6.0))
    i = i + 1
  }
  out
}

#let _draw-uniform(n) = {
  let seed = 2468013
  let out = ()
  let i = 0
  while i < n {
    seed = _lcg(seed)
    out.push((v: seed / 2147483648))
    i = i + 1
  }
  out
}

#let _draw-exponential(n) = {
  let seed = 9876543
  let out = ()
  let i = 0
  while i < n {
    seed = _lcg(seed)
    let u = (seed + 1) / 2147483649
    out.push((v: -calc.ln(1 - u)))
    i = i + 1
  }
  out
}

#let normal-data = _draw-normal(80)
#let uniform-data = _draw-uniform(80)
#let exponential-data = _draw-exponential(80)

#let make-panel(title, data, dist, x-name) = {
  set align(center)
  stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", title),
    plot(
      data: data,
      mapping: aes(y: "v"),
      layers: (
        geom-qq-line(stroke: 0.8pt, distribution: dist),
        geom-qq(size: 2pt, distribution: dist),
      ),
      scales: (
        scale-x-continuous(name: x-name),
        scale-y-continuous(name: "Sample quantile"),
      ),
      width: 6cm,
      height: 5cm,
    ),
  )
}

#grid(
  columns: 3,
  column-gutter: 0.5cm,
  row-gutter: 0.5cm,
  make-panel("normal", normal-data, "normal", "Normal quantile"),
  make-panel("uniform", uniform-data, "uniform", "Uniform quantile"),
  make-panel(
    "exponential",
    exponential-data,
    "exponential",
    "Exponential quantile",
  ),
)
