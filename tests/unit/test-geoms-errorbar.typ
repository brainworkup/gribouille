// Smoke tests for the errorbar family geoms.
// Each constructor must return a layer dict with the expected `geom` key
// and the documented defaults for `stat`, `position`, and `alpha`.

#import "../../src/geom/errorbar.typ": geom-errorbar
#import "../../src/geom/linerange.typ": geom-linerange
#import "../../src/geom/crossbar.typ": geom-crossbar
#import "../../src/geom/pointrange.typ": geom-pointrange

#let eb = geom-errorbar()
#assert.eq(eb.kind, "layer")
#assert.eq(eb.geom, "errorbar")
#assert.eq(eb.stat, "identity")
#assert.eq(eb.position, "identity")
#assert.eq(eb.params.width, 0.4)
#assert.eq(eb.params.alpha, auto)
#assert.eq(eb.params.linetype, "solid")

#let lr = geom-linerange()
#assert.eq(lr.kind, "layer")
#assert.eq(lr.geom, "linerange")
#assert.eq(lr.stat, "identity")
#assert.eq(lr.position, "identity")
#assert.eq(lr.params.alpha, auto)
#assert.eq(lr.params.linetype, "solid")

#let cb = geom-crossbar()
#assert.eq(cb.kind, "layer")
#assert.eq(cb.geom, "crossbar")
#assert.eq(cb.stat, "identity")
#assert.eq(cb.position, "identity")
#assert.eq(cb.params.width, 0.6)
#assert.eq(cb.params.alpha, auto)

#let pr = geom-pointrange()
#assert.eq(pr.kind, "layer")
#assert.eq(pr.geom, "pointrange")
#assert.eq(pr.stat, "identity")
#assert.eq(pr.position, "identity")
#assert.eq(pr.params.alpha, auto)
#assert.eq(pr.params.linetype, "solid")

// Layer params honour overrides.
#let eb2 = geom-errorbar(width: 0.2, colour: red, alpha: 0.5)
#assert.eq(eb2.params.width, 0.2)
#assert.eq(eb2.params.colour, red)
#assert.eq(eb2.params.alpha, 0.5)

Errorbar family smoke tests passed.
