///! Bundled mpg dataset.
///!
///! A 30-row small fuel-economy reference dataset.
///! We ship only the columns used by current examples: `manufacturer`,
///! `model`, `displ`, `cyl`, `class`, `cty`, `hwy`.
///! Rows span several vehicle classes.

/// Fuel economy of 30 cars (small fuel-economy reference dataset).
///
/// Each row is one vehicle.
/// Columns:
///
/// - `manufacturer` (string).
/// - `model` (string).
/// - `displ` (engine displacement, litres).
/// - `cyl` (number of cylinders).
/// - `class` (vehicle class, e.g. `"compact"`, `"midsize"`, `"suv"`).
/// - `cty` (city miles per gallon).
/// - `hwy` (highway miles per gallon).
///
/// \@category Datasets
/// \@stability stable
/// \@since 0.0.1
///
/// \@examples Highway mpg vs engine displacement, coloured by vehicle class.
/// ```
/// #plot(
///   data: mpg,
///   mapping: aes(x: "displ", y: "hwy", colour: "class"),
///   layers: (geom-point(size: 3pt),),
///   width: 11cm,
///   height: 7cm,
/// )
/// ```
///
/// \@examples Facet by `class` and add a linear smoother per panel to
/// compare per-class trends.
/// ```
/// #plot(
///   data: mpg,
///   mapping: aes(x: "displ", y: "hwy"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-smooth(method: "lm", se: false),
///   ),
///   facet: facet-wrap("class", ncol: 3),
///   width: 12cm,
///   height: 7cm,
/// )
/// ```
#let mpg = (
  (
    manufacturer: "audi",
    model: "a4",
    displ: 1.8,
    cyl: 4,
    class: "compact",
    cty: 18,
    hwy: 29,
  ),
  (
    manufacturer: "audi",
    model: "a4",
    displ: 2.0,
    cyl: 4,
    class: "compact",
    cty: 21,
    hwy: 30,
  ),
  (
    manufacturer: "audi",
    model: "a4 quattro",
    displ: 2.0,
    cyl: 4,
    class: "compact",
    cty: 19,
    hwy: 27,
  ),
  (
    manufacturer: "audi",
    model: "a6 quattro",
    displ: 3.1,
    cyl: 6,
    class: "midsize",
    cty: 17,
    hwy: 25,
  ),
  (
    manufacturer: "chevrolet",
    model: "corvette",
    displ: 5.7,
    cyl: 8,
    class: "2seater",
    cty: 15,
    hwy: 23,
  ),
  (
    manufacturer: "chevrolet",
    model: "malibu",
    displ: 2.4,
    cyl: 4,
    class: "midsize",
    cty: 22,
    hwy: 30,
  ),
  (
    manufacturer: "chevrolet",
    model: "k1500 tahoe 4wd",
    displ: 5.3,
    cyl: 8,
    class: "suv",
    cty: 14,
    hwy: 19,
  ),
  (
    manufacturer: "dodge",
    model: "caravan 2wd",
    displ: 3.3,
    cyl: 6,
    class: "minivan",
    cty: 17,
    hwy: 24,
  ),
  (
    manufacturer: "dodge",
    model: "dakota pickup 4wd",
    displ: 3.7,
    cyl: 6,
    class: "pickup",
    cty: 14,
    hwy: 18,
  ),
  (
    manufacturer: "dodge",
    model: "durango 4wd",
    displ: 4.7,
    cyl: 8,
    class: "suv",
    cty: 13,
    hwy: 17,
  ),
  (
    manufacturer: "ford",
    model: "expedition 2wd",
    displ: 5.4,
    cyl: 8,
    class: "suv",
    cty: 13,
    hwy: 18,
  ),
  (
    manufacturer: "ford",
    model: "explorer 4wd",
    displ: 4.0,
    cyl: 6,
    class: "suv",
    cty: 14,
    hwy: 19,
  ),
  (
    manufacturer: "ford",
    model: "f150 pickup 4wd",
    displ: 4.6,
    cyl: 8,
    class: "pickup",
    cty: 13,
    hwy: 17,
  ),
  (
    manufacturer: "ford",
    model: "mustang",
    displ: 4.6,
    cyl: 8,
    class: "subcompact",
    cty: 15,
    hwy: 22,
  ),
  (
    manufacturer: "honda",
    model: "civic",
    displ: 1.8,
    cyl: 4,
    class: "subcompact",
    cty: 25,
    hwy: 36,
  ),
  (
    manufacturer: "hyundai",
    model: "sonata",
    displ: 2.4,
    cyl: 4,
    class: "midsize",
    cty: 21,
    hwy: 30,
  ),
  (
    manufacturer: "hyundai",
    model: "tiburon",
    displ: 2.0,
    cyl: 4,
    class: "subcompact",
    cty: 20,
    hwy: 28,
  ),
  (
    manufacturer: "jeep",
    model: "grand cherokee 4wd",
    displ: 4.7,
    cyl: 8,
    class: "suv",
    cty: 14,
    hwy: 17,
  ),
  (
    manufacturer: "nissan",
    model: "altima",
    displ: 2.5,
    cyl: 4,
    class: "midsize",
    cty: 23,
    hwy: 32,
  ),
  (
    manufacturer: "nissan",
    model: "maxima",
    displ: 3.5,
    cyl: 6,
    class: "midsize",
    cty: 19,
    hwy: 25,
  ),
  (
    manufacturer: "nissan",
    model: "pathfinder 4wd",
    displ: 4.0,
    cyl: 6,
    class: "suv",
    cty: 14,
    hwy: 20,
  ),
  (
    manufacturer: "subaru",
    model: "forester awd",
    displ: 2.5,
    cyl: 4,
    class: "suv",
    cty: 19,
    hwy: 25,
  ),
  (
    manufacturer: "subaru",
    model: "impreza awd",
    displ: 2.2,
    cyl: 4,
    class: "subcompact",
    cty: 21,
    hwy: 29,
  ),
  (
    manufacturer: "toyota",
    model: "4runner 4wd",
    displ: 4.0,
    cyl: 6,
    class: "suv",
    cty: 16,
    hwy: 20,
  ),
  (
    manufacturer: "toyota",
    model: "camry",
    displ: 2.4,
    cyl: 4,
    class: "midsize",
    cty: 21,
    hwy: 31,
  ),
  (
    manufacturer: "toyota",
    model: "corolla",
    displ: 1.8,
    cyl: 4,
    class: "compact",
    cty: 28,
    hwy: 37,
  ),
  (
    manufacturer: "toyota",
    model: "land cruiser wagon 4wd",
    displ: 5.7,
    cyl: 8,
    class: "suv",
    cty: 13,
    hwy: 18,
  ),
  (
    manufacturer: "volkswagen",
    model: "gti",
    displ: 2.0,
    cyl: 4,
    class: "compact",
    cty: 21,
    hwy: 29,
  ),
  (
    manufacturer: "volkswagen",
    model: "jetta",
    displ: 2.0,
    cyl: 4,
    class: "compact",
    cty: 21,
    hwy: 30,
  ),
  (
    manufacturer: "volkswagen",
    model: "passat",
    displ: 2.8,
    cyl: 6,
    class: "midsize",
    cty: 16,
    hwy: 26,
  ),
)
