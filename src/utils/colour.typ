/// Blend two colours.
///
/// Mirrors ggplot2's `col_mix(col1, col2, amount)`:
/// `amount` is the fraction of `col2` (0 = pure `col1`, 1 = pure `col2`).
///
/// @category Scales
/// @stability stable
/// @since 0.1.0
///
/// @param col1 Base colour.
/// @param col2 Colour to blend in.
/// @param amount Fraction of `col2` in the result (0–1).
/// @returns Blended colour.
#let col-mix(col1, col2, amount) = col1.mix((col2, amount * 100%))
