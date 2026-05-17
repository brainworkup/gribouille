///! Layer record helpers and default stat and position wiring.
///!
///! Every `geom-*` constructor returns the dict shape this module builds.
///! Centralising it here keeps the record's keys discoverable in one place
///! and stops drift between geoms when fields are added or renamed.

/// Build a layer record consumed by `plot()`.
///
/// \@internal
#let make-layer(
  geom,
  mapping: none,
  data: none,
  params: (:),
  stat: "identity",
  position: "identity",
  key: auto,
  inherit-aes: true,
) = (
  kind: "layer",
  geom: geom,
  mapping: mapping,
  data: data,
  params: params,
  key: key,
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)
