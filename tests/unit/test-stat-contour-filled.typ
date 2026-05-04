// `stat-contour-filled` clips each grid cell against successive level pairs
// to emit one polygon per cell per band.

#import "../../src/aes.typ": aes
#import "../../src/stat/contour-filled.typ": apply, stat-contour-filled
#import "../../src/utils/isobands.typ": isoband-cell, isobands

#let s = stat-contour-filled(bins: 4)
#assert.eq(s.kind, "stat")
#assert.eq(s.name, "contour_filled")

// --- single cell, level fully inside ---

// Unit cell with z(NW)=0, z(NE)=2, z(SE)=2, z(SW)=0; band [0.5, 1.5] cuts
// two horizontal lines, leaving a hexagon strip across the cell.
#let strip = isoband-cell(0, 1, 0, 1, 0, 2, 2, 0, 0.5, 1.5)
#assert(strip.len() >= 4)

// --- band entirely above the cell ---

// All corners < lo: nothing emitted.
#let above = isoband-cell(0, 1, 0, 1, 0.1, 0.2, 0.3, 0.4, 1.0, 2.0)
#assert.eq(above, ())

// --- band entirely covers the cell ---

// All corners between lo and hi: cell preserved unchanged.
#let inside = isoband-cell(0, 1, 0, 1, 1, 1, 1, 1, 0.5, 1.5)
#assert.eq(inside.len(), 4)

// --- isobands across a 3x3 grid ---

#let xs = (0.0, 1.0, 2.0)
#let ys = (0.0, 1.0, 2.0)
#let z = (
  (0.0, 1.0, 2.0),
  (1.0, 2.0, 3.0),
  (2.0, 3.0, 4.0),
)
#let polys = isobands(xs, ys, z, 1.0, 3.0)
#assert(polys.len() > 0)
// Every emitted polygon has at least three vertices.
#assert(polys.all(p => p.len() >= 3))

// --- apply() emits per-cell rows tagged with `level` and `group` ---

#let raw = ()
#for i in range(4) {
  for j in range(4) {
    raw.push((x: i, y: j, z: i + j))
  }
}
#let r = apply(
  raw,
  aes(x: "x", y: "y", z: "z"),
  params: (bins: 3, binwidth: none, breaks: auto),
)
#assert.eq(r.mapping.fill, "level")
#assert.eq(r.mapping.group, "group")
#assert(r.data.len() > 0)
#assert("level" in r.data.first())

// Distinct bands -> distinct group prefixes.
#let bands = r.data.map(row => row.group.split(":").at(0)).dedup()
#assert(bands.len() >= 2)

// --- explicit breaks bound interior bands; outer bands extend to extents ---

#let r-breaks = apply(
  raw,
  aes(x: "x", y: "y", z: "z"),
  params: (bins: 99, binwidth: none, breaks: (2.0, 4.0)),
)
#let levels = r-breaks.data.map(row => row.level).dedup().sorted()
// Two break values + two extent edges -> three bands -> three lower bounds:
// z-lo (0), 2.0, and 4.0.
#assert.eq(levels, (0.0, 2.0, 4.0))

stat-contour-filled tests passed.
