///! Global theme state.
///!
///! Mirrors ggplot2's `theme_set()` / `theme_get()`. Plots that do not
///! specify an explicit `theme:` argument inherit the global theme.

#let _theme-state = state("gribouille-theme", none)

/// Set the global default theme for all subsequent plots.
///
/// @category Themes
/// @stability stable
/// @since 0.1.0
///
/// @param t Theme dictionary from @theme-grey, @theme-minimal, @theme-classic, @theme-void, or @theme.
///
/// @returns None.
///
/// @example
/// ```
/// #theme-set(theme-minimal())
/// // All plots below use theme-minimal() by default.
/// ```
///
/// @see @theme-get, @theme
#let theme-set(t) = _theme-state.update(t)

/// Get the current global default theme.
///
/// Returns `none` if no global theme has been set.
///
/// @category Themes
/// @stability stable
/// @since 0.1.0
///
/// @returns The current global theme dictionary, or `none`.
///
/// @see @theme-set
#let theme-get() = context _theme-state.get()
