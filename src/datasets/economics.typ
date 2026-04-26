///! Bundled economics dataset.
///!
///! A 24-row monthly subset spanning 2008-01-01 to 2009-12-01.
///! The window covers the 2008 recession so the trends are visibly
///! non-trivial in time-series demos.
///!
///! Values are synthetic but plausible: `pce` and `pop` rise broadly,
///! `psavert` climbs as households rebuild savings, and `unemploy`
///! and `uempmed` peak through 2009.

/// US monthly economic time series (subset).
///
/// Each row is a month from 2008-01-01 to 2009-12-01.
/// Columns:
/// - `date` (string `"YYYY-MM-DD"`).
/// - `pce` (personal consumption expenditures, billions of dollars).
/// - `pop` (total population, thousands).
/// - `psavert` (personal savings rate, percent).
/// - `uempmed` (median duration of unemployment, weeks).
/// - `unemploy` (number of unemployed, thousands).
///
/// @category Datasets
/// @stability stable
/// @since 0.0.1
///
/// @example
/// ```
/// #plot(
///   data: economics,
///   mapping: aes(x: "date", y: "unemploy"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-x-date(),),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
#let economics = (
  (
    date: "2008-01-01",
    pce: 9846,
    pop: 303516,
    psavert: 3.0,
    uempmed: 8.6,
    unemploy: 7685,
  ),
  (
    date: "2008-02-01",
    pce: 9870,
    pop: 303695,
    psavert: 3.2,
    uempmed: 8.9,
    unemploy: 7497,
  ),
  (
    date: "2008-03-01",
    pce: 9905,
    pop: 303881,
    psavert: 3.5,
    uempmed: 9.0,
    unemploy: 7822,
  ),
  (
    date: "2008-04-01",
    pce: 9935,
    pop: 304093,
    psavert: 3.6,
    uempmed: 8.9,
    unemploy: 7637,
  ),
  (
    date: "2008-05-01",
    pce: 9985,
    pop: 304322,
    psavert: 5.5,
    uempmed: 9.4,
    unemploy: 8395,
  ),
  (
    date: "2008-06-01",
    pce: 9988,
    pop: 304563,
    psavert: 4.7,
    uempmed: 10.1,
    unemploy: 8575,
  ),
  (
    date: "2008-07-01",
    pce: 9966,
    pop: 304809,
    psavert: 4.5,
    uempmed: 9.7,
    unemploy: 8937,
  ),
  (
    date: "2008-08-01",
    pce: 9923,
    pop: 305042,
    psavert: 4.0,
    uempmed: 9.7,
    unemploy: 9438,
  ),
  (
    date: "2008-09-01",
    pce: 9853,
    pop: 305259,
    psavert: 4.2,
    uempmed: 10.2,
    unemploy: 9494,
  ),
  (
    date: "2008-10-01",
    pce: 9728,
    pop: 305469,
    psavert: 5.4,
    uempmed: 10.4,
    unemploy: 10074,
  ),
  (
    date: "2008-11-01",
    pce: 9613,
    pop: 305680,
    psavert: 6.4,
    uempmed: 9.8,
    unemploy: 10538,
  ),
  (
    date: "2008-12-01",
    pce: 9561,
    pop: 305869,
    psavert: 6.4,
    uempmed: 10.5,
    unemploy: 11286,
  ),
  (
    date: "2009-01-01",
    pce: 9533,
    pop: 306051,
    psavert: 5.7,
    uempmed: 10.7,
    unemploy: 12058,
  ),
  (
    date: "2009-02-01",
    pce: 9555,
    pop: 306243,
    psavert: 5.0,
    uempmed: 11.7,
    unemploy: 12898,
  ),
  (
    date: "2009-03-01",
    pce: 9543,
    pop: 306437,
    psavert: 5.3,
    uempmed: 12.3,
    unemploy: 13426,
  ),
  (
    date: "2009-04-01",
    pce: 9551,
    pop: 306648,
    psavert: 6.7,
    uempmed: 13.1,
    unemploy: 13853,
  ),
  (
    date: "2009-05-01",
    pce: 9587,
    pop: 306871,
    psavert: 7.5,
    uempmed: 14.2,
    unemploy: 14499,
  ),
  (
    date: "2009-06-01",
    pce: 9608,
    pop: 307108,
    psavert: 6.4,
    uempmed: 17.2,
    unemploy: 14707,
  ),
  (
    date: "2009-07-01",
    pce: 9635,
    pop: 307354,
    psavert: 5.7,
    uempmed: 16.0,
    unemploy: 14601,
  ),
  (
    date: "2009-08-01",
    pce: 9678,
    pop: 307589,
    psavert: 4.9,
    uempmed: 16.3,
    unemploy: 14814,
  ),
  (
    date: "2009-09-01",
    pce: 9697,
    pop: 307795,
    psavert: 4.8,
    uempmed: 17.6,
    unemploy: 15009,
  ),
  (
    date: "2009-10-01",
    pce: 9737,
    pop: 308013,
    psavert: 5.0,
    uempmed: 18.9,
    unemploy: 15352,
  ),
  (
    date: "2009-11-01",
    pce: 9778,
    pop: 308222,
    psavert: 5.1,
    uempmed: 19.8,
    unemploy: 15219,
  ),
  (
    date: "2009-12-01",
    pce: 9821,
    pop: 308417,
    psavert: 5.0,
    uempmed: 20.1,
    unemploy: 15098,
  ),
)
