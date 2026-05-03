// measure-text-cm and measure-labels-cm wrap Typst's measure() and return
// cm-as-float. measure() requires a context block; the helpers don't add one
// so each call site stays explicit about where measurement happens.

#import "../../src/utils/measure.typ": measure-labels-cm, measure-text-cm

// Single-label measurement returns positive width and height for non-empty
// content. Exact values depend on the document font; only structure is
// asserted.
#context {
  let m = measure-text-cm("14.878", 8pt)
  assert(m.width > 0, message: "width should be positive")
  assert(m.height > 0, message: "height should be positive")
  // The legacy heuristic (6 chars * 0.18cm) overestimates significantly;
  // measured width should land well below 1.08cm.
  assert(m.width < 0.9, message: "width should be < legacy estimate")
}

// max-width tracks the longest label; max-height tracks the tallest ink box.
#context {
  let m = measure-labels-cm(("35", "14.878", "10.628"), 8pt)
  let single = measure-text-cm("14.878", 8pt)
  assert(m.width >= single.width - 1e-9, message: "max-width includes longest")
  assert(m.height >= single.height - 1e-9, message: "max-height tracks tallest")
}

// Empty input returns zero.
#context {
  let m = measure-labels-cm((), 8pt)
  assert.eq(m.width, 0.0)
  assert.eq(m.height, 0.0)
}

axis-label measure smoke test passed.
