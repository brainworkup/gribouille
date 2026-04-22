// Preamble prepended to every rendered @example block by typst-render.
#import "/lib.typ": *

#let _theme_grey = theme-grey
#let _theme_minimal = theme-minimal
#let _theme_classic = theme-classic
#let _theme_void = theme-void
#let _theme_custom = theme

#let _theme_with_document_colours(
  theme_fn,
  ink: auto,
  paper: auto,
  accent: rgb("#3366FF"),
) = {
  let args = (accent: accent)
  if ink != auto {
    args.insert("ink", ink)
  } else if _typst_render_foreground != none {
    args.insert("ink", _typst_render_foreground)
  }
  if paper != auto {
    args.insert("paper", paper)
  } else if _typst_render_background != none {
    args.insert("paper", _typst_render_background)
  }
  theme_fn(..args)
}

#let theme-grey(
  ink: auto,
  paper: auto,
  accent: rgb("#3366FF"),
) = _theme_with_document_colours(
  _theme_grey,
  ink: ink,
  paper: paper,
  accent: accent,
)

#let theme-minimal(
  ink: auto,
  paper: auto,
  accent: rgb("#3366FF"),
) = _theme_with_document_colours(
  _theme_minimal,
  ink: ink,
  paper: paper,
  accent: accent,
)

#let theme-classic(
  ink: auto,
  paper: auto,
  accent: rgb("#3366FF"),
) = _theme_with_document_colours(
  _theme_classic,
  ink: ink,
  paper: paper,
  accent: accent,
)

#let theme-void(
  ink: auto,
  paper: auto,
  accent: rgb("#3366FF"),
) = _theme_with_document_colours(
  _theme_void,
  ink: ink,
  paper: paper,
  accent: accent,
)

#let theme(..fields) = {
  let named = fields.named()
  if (
    named.at("ink", default: none) == none and _typst_render_foreground != none
  ) {
    named.insert("ink", _typst_render_foreground)
  }
  if (
    named.at("paper", default: none) == none
      and _typst_render_background != none
  ) {
    named.insert("paper", _typst_render_background)
  }
  _theme_custom(..named)
}
