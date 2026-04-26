// Boxplot from raw data: stat-boxplot reduces each group to its
// five-number summary, then geom-boxplot draws the Tukey box.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

// Three groups with 24 observations each. Group "c" carries a couple of
// outliers near the high end so the dots show up beyond the fences.
#let groups = ("a", "b", "c")
#let raw-y = (
  a: (
    4.1,
    4.5,
    5.0,
    5.2,
    5.3,
    5.6,
    5.7,
    5.8,
    5.9,
    6.0,
    6.1,
    6.2,
    6.3,
    6.4,
    6.5,
    6.7,
    6.8,
    6.9,
    7.0,
    7.2,
    7.4,
    7.6,
    7.9,
    8.3,
  ),
  b: (
    6.8,
    7.0,
    7.2,
    7.4,
    7.5,
    7.6,
    7.8,
    7.9,
    8.0,
    8.1,
    8.2,
    8.3,
    8.4,
    8.5,
    8.6,
    8.7,
    8.8,
    9.0,
    9.1,
    9.3,
    9.5,
    9.8,
    10.1,
    10.5,
  ),
  c: (
    3.4,
    3.8,
    4.0,
    4.1,
    4.3,
    4.4,
    4.5,
    4.6,
    4.7,
    4.8,
    4.9,
    5.0,
    5.1,
    5.2,
    5.3,
    5.4,
    5.5,
    5.7,
    5.9,
    6.1,
    6.4,
    6.8,
    11.5,
    12.4,
  ),
)

#let data = ()
#for g in groups {
  for v in raw-y.at(g) {
    data.push((grp: g, y: v))
  }
}

#plot(
  data: data,
  mapping: aes(x: "grp", y: "y", fill: "grp"),
  layers: (geom-boxplot(),),
  scales: (
    scale-x-discrete(name: "Group"),
    scale-y-continuous(name: "Value"),
  ),
  width: 10cm,
  height: 7cm,
)
