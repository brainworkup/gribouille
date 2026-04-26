// Q-Q plot: 80 samples drawn from the central-limit-theorem sum of 12
// uniform pseudo-random numbers, plotted against the standard-normal
// quantiles with the IQR-fitted reference line.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

// Linear-congruential generator: 80 normal-ish draws via the sum of 12
// uniforms minus 6. Seeded for reproducibility so the rendered example never
// drifts.
#let _draw-samples(n) = {
  let seed = 1234567
  let out = ()
  let i = 0
  while i < n {
    let acc = 0.0
    let j = 0
    while j < 12 {
      seed = calc.rem(seed * 1103515245 + 12345, 2147483648)
      acc = acc + seed / 2147483648
      j = j + 1
    }
    out.push((v: acc - 6.0))
    i = i + 1
  }
  out
}

#let raw = _draw-samples(80)

#plot(
  data: raw,
  mapping: aes(y: "v"),
  layers: (
    geom-qq-line(stroke: 0.8pt),
    geom-qq(size: 2pt),
  ),
  scales: (
    scale-x-continuous(name: "Theoretical quantile"),
    scale-y-continuous(name: "Sample quantile"),
  ),
  labs: labs(title: "Normal Q-Q plot of 80 simulated samples"),
  width: 10cm,
  height: 7cm,
)
