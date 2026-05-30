// `_resolve-alt`: plot(alt:) wins, else labs(alt:) fills in.

#import "../../src/plot.typ": _resolve-alt
#import "../../src/labs.typ": labs

// --- explicit plot alt wins over a labs alt -------------------------------

#assert.eq(_resolve-alt("explicit", labs(alt: "from labs")), "explicit")

// --- labs alt fills in when plot alt is unset -----------------------------

#assert.eq(_resolve-alt(none, labs(alt: "from labs")), "from labs")

// --- both unset resolves to none ------------------------------------------
// labs(alt:) defaults to `auto`, which counts as unset.

#assert.eq(_resolve-alt(none, labs(title: "t")), none)
#assert.eq(_resolve-alt(none, none), none)

Labs alt tests passed.
