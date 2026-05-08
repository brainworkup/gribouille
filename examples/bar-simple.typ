// Simple bar chart with discrete x.

#import "../lib.typ": *

#set page(width: 12cm)

#let fruits = (
  (fruit: "apple", count: 12),
  (fruit: "banana", count: 19),
  (fruit: "cherry", count: 7),
  (fruit: "date", count: 15),
)

#plot(
  data: fruits,
  mapping: aes(x: "fruit", y: "count", fill: "fruit"),
  layers: (geom-col(),),
  guides: guides(fill: guide-none()),
  labs: labs(title: "Counts per fruit", x: "Fruit", y: "Count"),
  theme: theme-grey(),
  width: 12cm,
  height: 9cm,
)
