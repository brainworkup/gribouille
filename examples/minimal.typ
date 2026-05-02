// Minimal scatter plot with inline data.

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5cm)

#let iris = (
  (sepal-length: 5.1, sepal-width: 3.5, species: "setosa"),
  (sepal-length: 4.9, sepal-width: 3.0, species: "setosa"),
  (sepal-length: 4.7, sepal-width: 3.2, species: "setosa"),
  (sepal-length: 7.0, sepal-width: 3.2, species: "versicolor"),
  (sepal-length: 6.4, sepal-width: 3.2, species: "versicolor"),
  (sepal-length: 6.9, sepal-width: 3.1, species: "versicolor"),
  (sepal-length: 6.3, sepal-width: 3.3, species: "virginica"),
  (sepal-length: 5.8, sepal-width: 2.7, species: "virginica"),
  (sepal-length: 7.1, sepal-width: 3.0, species: "virginica"),
)

#plot(
  data: iris,
  mapping: aes(x: "sepal-length", y: "sepal-width", fill: "species"),
  layers: (geom-point(size: 3pt),),
  labs: labs(
    title: "Iris sepal dimensions",
    x: "Sepal length (cm)",
    y: "Sepal width (cm)",
    fill: "Species",
  ),
  theme: theme-minimal(),
  width: 11cm,
  height: 6cm,
)
