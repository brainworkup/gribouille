// `after-scale(expr)` runs after the channel's scale resolution and
// transforms the result. The closure receives the resolved value and a
// context dict that includes the row plus the renderer's resolvers.

#import "../../src/utils/late-binding.typ": (
  after-scale, is-late-binding, late-binding-kind,
)
#import "../../src/utils/colour-resolve.typ": resolve-stroke-colour
#import "../../src/utils/fill-resolve.typ": resolve-fill-colour

// --- constructor + predicates ------------------------------------------

#let m = after-scale((c, _) => c)
#assert.eq(m.kind, "after-scale")
#assert.eq(type(m.expr), function)
#assert(is-late-binding(m))
#assert.eq(late-binding-kind(m), "after-scale")

// --- shared scaffolding ------------------------------------------------

#let fake-trained = (type: "discrete", domain: ("a", "b"))
#let marker-resolve(trained, palette) = value => {
  if value == "a" { rgb("#ff0000") } else { rgb("#0000ff") }
}
#let make-ctx(trained-dict) = (
  trained: trained-dict,
  resolve-colour: marker-resolve,
  palette: (rgb("#111111"),),
  theme: (ink: black),
)
#let layer-of(params) = (geom: "point", params: params)

// --- after-scale on `colour` darkens the channel default ---------------

#let darken-half = after-scale((c, _) => c.darken(50%))
#assert.eq(
  resolve-stroke-colour(
    layer-of((colour: auto, alpha: 1)),
    (colour: darken-half),
    make-ctx((:)),
    (:),
    rgb("#888888"),
  ),
  rgb("#888888").darken(50%),
)

// --- closure can read other-channel resolved values via ctx ------------

#let mirror-fill = after-scale((_, ctx) => {
  let trained = ctx.trained.at("fill", default: none)
  ((ctx.resolve-colour)(trained, ctx.palette))(ctx.row.sp)
})
#assert.eq(
  resolve-stroke-colour(
    layer-of((colour: auto, alpha: 1)),
    (colour: mirror-fill, fill: "sp"),
    make-ctx((fill: fake-trained)),
    (sp: "a"),
    rgb("#cccccc"),
  ),
  rgb("#ff0000"),
)

// --- after-scale on `fill` transforms the channel default --------------

#let translucent = after-scale((c, _) => c.transparentize(50%))
#assert.eq(
  resolve-fill-colour(
    layer-of((fill: auto, alpha: 1)),
    (fill: translucent),
    make-ctx((:)),
    (:),
    rgb("#22aa22"),
  ),
  rgb("#22aa22").transparentize(50%),
)

// --- per-row alpha still composes on the after-scale result ------------

#assert.eq(
  resolve-stroke-colour(
    layer-of((colour: auto, alpha: 0.5)),
    (colour: darken-half),
    make-ctx((:)),
    (:),
    rgb("#888888"),
  ),
  rgb("#888888").darken(50%).transparentize(50%),
)

late-binding after-scale tests passed.
