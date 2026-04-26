///! Temporal position scales: date, datetime, and time.
///!
///! These wrappers train a continuous numeric domain like @scale-x-continuous
///! and only differ at axis-label time, where the numeric break is converted
///! back to a Typst `datetime` against a fixed epoch and rendered through
///! `dt.display(date-format)`.
///!
///! Numeric input contract: column values must already be encoded as numbers
///! against the epoch documented on each scale. ISO-8601 string parsing is
///! intentionally not handled here.

/// Continuous x scale that formats axis labels as dates.
///
/// Column values must be numeric, expressed as days since 2000-01-01. Each
/// break is converted via
/// `datetime(year: 2000, month: 1, day: 1) + duration(days: int(n))` and
/// rendered with `dt.display(date-format)`.
///
/// @category Scales
/// @stability experimental
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain (in days), or `none` for automatic limits.
/// @param breaks Array of break values (in days), or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
/// @param date-format Typst `datetime.display` pattern used for break labels.
///
/// @returns Scale object consumed by @plot.
///
/// @example
/// ```
/// //| width: 12cm
/// //| height: 6cm
/// #let d = range(0, 12).map(i => (x: 8766 + 30 * i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(), geom-point(size: 2pt)),
///   scales: (scale-x-date(date-format: "[year]-[month repr:numerical]"),),
/// )
/// ```
///
/// @see @scale-y-date, @scale-x-datetime, @scale-x-continuous
#let scale-x-date(
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
  date-format: "[year]-[month repr:numerical]-[day]",
) = (
  kind: "scale",
  aesthetic: "x",
  type: "continuous",
  temporal: "date",
  date-format: date-format,
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Continuous y scale that formats axis labels as dates.
///
/// Column values must be numeric, expressed as days since 2000-01-01.
///
/// @category Scales
/// @stability experimental
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain (in days), or `none` for automatic limits.
/// @param breaks Array of break values (in days), or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
/// @param date-format Typst `datetime.display` pattern used for break labels.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-x-date, @scale-y-datetime
#let scale-y-date(
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
  date-format: "[year]-[month repr:numerical]-[day]",
) = (
  kind: "scale",
  aesthetic: "y",
  type: "continuous",
  temporal: "date",
  date-format: date-format,
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Continuous x scale that formats axis labels as datetimes.
///
/// Column values must be numeric, expressed as seconds since
/// 2000-01-01T00:00:00. Each break is converted via
/// `datetime(year: 2000, month: 1, day: 1, hour: 0, minute: 0, second: 0) + duration(seconds: int(n))`
/// and rendered with `dt.display(date-format)`.
///
/// @category Scales
/// @stability experimental
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain (in seconds), or `none` for automatic limits.
/// @param breaks Array of break values (in seconds), or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
/// @param date-format Typst `datetime.display` pattern used for break labels.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-y-datetime, @scale-x-date, @scale-x-time
#let scale-x-datetime(
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
  date-format: "[year]-[month repr:numerical]-[day] [hour]:[minute]",
) = (
  kind: "scale",
  aesthetic: "x",
  type: "continuous",
  temporal: "datetime",
  date-format: date-format,
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Continuous y scale that formats axis labels as datetimes.
///
/// Column values must be numeric, expressed as seconds since
/// 2000-01-01T00:00:00.
///
/// @category Scales
/// @stability experimental
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain (in seconds), or `none` for automatic limits.
/// @param breaks Array of break values (in seconds), or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
/// @param date-format Typst `datetime.display` pattern used for break labels.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-x-datetime, @scale-y-date
#let scale-y-datetime(
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
  date-format: "[year]-[month repr:numerical]-[day] [hour]:[minute]",
) = (
  kind: "scale",
  aesthetic: "y",
  type: "continuous",
  temporal: "datetime",
  date-format: date-format,
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Continuous x scale that formats axis labels as times of day.
///
/// Column values must be numeric, expressed as seconds since midnight (an
/// integer in `[0, 86400)`). Each break is converted via
/// `datetime(year: 2000, month: 1, day: 1, hour: 0, minute: 0, second: 0) + duration(seconds: int(n))`
/// and rendered with `dt.display(date-format)`; only the time portion of the
/// pattern should be used.
///
/// @category Scales
/// @stability experimental
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain (in seconds), or `none` for automatic limits.
/// @param breaks Array of break values (in seconds), or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
/// @param date-format Typst `datetime.display` pattern used for break labels.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-y-time, @scale-x-datetime
#let scale-x-time(
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
  date-format: "[hour]:[minute]",
) = (
  kind: "scale",
  aesthetic: "x",
  type: "continuous",
  temporal: "time",
  date-format: date-format,
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
)

/// Continuous y scale that formats axis labels as times of day.
///
/// Column values must be numeric, expressed as seconds since midnight (an
/// integer in `[0, 86400)`).
///
/// @category Scales
/// @stability experimental
/// @since 0.0.1
///
/// @param name Axis title. Overrides any name set via @labs when both are present.
/// @param limits Pair `(lo, hi)` clipping the trained domain (in seconds), or `none` for automatic limits.
/// @param breaks Array of break values (in seconds), or `auto` for automatic tick selection.
/// @param labels Array of tick labels aligned with `breaks`, or `auto`.
/// @param date-format Typst `datetime.display` pattern used for break labels.
///
/// @returns Scale object consumed by @plot.
///
/// @see @scale-x-time, @scale-y-datetime
#let scale-y-time(
  name: none,
  limits: none,
  breaks: auto,
  labels: auto,
  date-format: "[hour]:[minute]",
) = (
  kind: "scale",
  aesthetic: "y",
  type: "continuous",
  temporal: "time",
  date-format: date-format,
  name: name,
  limits: limits,
  breaks: breaks,
  labels: labels,
)
