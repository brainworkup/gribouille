// Niche colour scale unit tests: grey, hue, distiller.

#import "../../src/utils/colour.typ": grey-palette, hue-palette
#import "../../src/utils/palette.typ": brewer-palette
#import "../../src/scale/colour.typ": (
  scale-colour-distiller, scale-colour-grey, scale-colour-hue,
  scale-fill-distiller, scale-fill-grey, scale-fill-hue,
)

// grey-palette steps evenly between start and end.
#let g5 = grey-palette(5, start: 0.0, end: 1.0)
#assert.eq(g5.len(), 5)
#assert.eq(g5.at(0), luma(0%))
#assert.eq(g5.at(1), luma(25%))
#assert.eq(g5.at(2), luma(50%))
#assert.eq(g5.at(3), luma(75%))
#assert.eq(g5.at(4), luma(100%))

// hue-palette returns the requested number of stops.
#let h4 = hue-palette(4)
#assert.eq(h4.len(), 4)
#for c in h4 {
  assert.eq(type(c), color)
}

// scale-colour-grey carries the right shape.
#let sg = scale-colour-grey()
#assert.eq(sg.kind, "scale")
#assert.eq(sg.aesthetic, "colour")
#assert.eq(sg.type, "discrete")
#assert.eq(sg.palette.len(), 10)

// scale-fill-grey mirrors with fill.
#let sgf = scale-fill-grey(start: 0.1, end: 0.9)
#assert.eq(sgf.aesthetic, "fill")
#assert.eq(sgf.type, "discrete")
#assert.eq(sgf.palette.len(), 10)

// scale-colour-hue carries the right shape and uses oklch colours.
#let sh = scale-colour-hue()
#assert.eq(sh.kind, "scale")
#assert.eq(sh.aesthetic, "colour")
#assert.eq(sh.type, "discrete")
#assert.eq(sh.palette.len(), 12)

#let shf = scale-fill-hue()
#assert.eq(shf.aesthetic, "fill")
#assert.eq(shf.type, "discrete")
#assert.eq(shf.palette.len(), 12)

// scale-colour-distiller resolves a Brewer palette as continuous stops.
#let sd = scale-colour-distiller(palette: "Spectral")
#assert.eq(sd.kind, "scale")
#assert.eq(sd.aesthetic, "colour")
#assert.eq(sd.type, "continuous")
#assert.eq(sd.palette, brewer-palette("Spectral"))

// direction: -1 reverses the palette.
#let sd-rev = scale-colour-distiller(palette: "Spectral", direction: -1)
#assert.eq(sd-rev.palette, brewer-palette("Spectral").rev())

#let sdf = scale-fill-distiller(palette: "Blues")
#assert.eq(sdf.aesthetic, "fill")
#assert.eq(sdf.type, "continuous")
#assert.eq(sdf.palette, brewer-palette("Blues"))

Niche colour scale tests passed.
