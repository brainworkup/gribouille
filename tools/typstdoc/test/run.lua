-- Stdlib-only test runner for typstdoc.
-- Usage (from repo root): lua tools/typstdoc/test/run.lua

local function script_dir()
  local source = debug.getinfo(1, "S").source
  if source:sub(1, 1) == "@" then source = source:sub(2) end
  return source:match("^(.*)/[^/]+$") or "."
end

local TEST_DIR = script_dir()
local ROOT = TEST_DIR:match("^(.*)/test$") or TEST_DIR
package.path = ROOT .. "/?.lua;" .. TEST_DIR .. "/?.lua;" .. package.path

local T = { passed = 0, failed = 0, errors = {} }

local function describe(name, fn)
  io.write(string.format("\n== %s ==\n", name))
  fn()
end

local function it(name, fn)
  local ok, err = xpcall(fn, debug.traceback)
  if ok then
    T.passed = T.passed + 1
    io.write(string.format("  ok  %s\n", name))
  else
    T.failed = T.failed + 1
    table.insert(T.errors, { name = name, err = err })
    io.write(string.format("  FAIL %s\n%s\n", name, err))
  end
end

local function assert_eq(actual, expected, msg)
  if actual ~= expected then
    error(string.format("%s\n  expected: %s\n  actual:   %s",
      msg or "values differ", tostring(expected), tostring(actual)), 2)
  end
end

local function assert_true(cond, msg)
  if not cond then error(msg or "expected true, got falsy", 2) end
end

local function assert_contains(haystack, needle, msg)
  if not haystack:find(needle, 1, true) then
    error(string.format("%s\n  expected to contain: %s\n  got:\n%s",
      msg or "missing substring", needle, haystack), 2)
  end
end

local function assert_throws(fn, pattern, msg)
  local ok, err = pcall(fn)
  if ok then error(msg or "expected an error, got none", 2) end
  if pattern and not tostring(err):find(pattern) then
    error(string.format("%s\n  expected error matching: %s\n  got: %s",
      msg or "wrong error", pattern, tostring(err)), 2)
  end
end

local parser = require("parser")
local model = require("model")
local resolve = require("resolve")
local util = require("util")

local function tmpfile(name, body)
  local path = string.format("%s/_tmp_%s.typ", TEST_DIR, name)
  util.write_file(path, body)
  return path
end

local function cleanup()
  os.execute(string.format("rm -f %q/_tmp_*.typ", TEST_DIR))
end

-- -----------------------------------------------------------------------
describe("parser: doc block basics", function()
  it("accepts a minimal doc block with summary", function()
    local f = tmpfile("min", [[
/// A minimal function.
///
/// @category Core
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    assert_eq(#parsed.functions, 1)
    assert_eq(parsed.functions[1].name, "foo")
    assert_eq(parsed.functions[1].doc.summary, "A minimal function.")
    assert_eq(parsed.functions[1].doc.category, "Core")
  end)

  it("rejects a block with no summary", function()
    local f = tmpfile("nosummary", [[
///
/// @category Core
#let foo() = none
]])
    assert_throws(function() parser.parse_file(f) end, "missing summary")
  end)

  it("preserves paragraphs across blank /// lines", function()
    local f = tmpfile("paras", [[
/// Summary line.
///
/// First paragraph.
/// Still first paragraph.
///
/// Second paragraph.
///
/// @category Core
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    local desc = parsed.functions[1].doc.description
    assert_eq(#desc, 2, "expected two paragraphs")
    assert_contains(desc[1], "First paragraph")
    assert_contains(desc[1], "Still first paragraph")
    assert_contains(desc[2], "Second paragraph")
  end)

  it("rejects unknown tags", function()
    local f = tmpfile("unknown", [[
/// Summary.
///
/// @nosuchtag boom
#let foo() = none
]])
    assert_throws(function() parser.parse_file(f) end, "unknown tag")
  end)

  it("unescapes \\@ to @ in /// and ///! comment lines", function()
    local f = tmpfile("escaped_at", [[
///! Module summary mentioning \@aes and \@plot.

/// Summary referencing \@aes inline.
///
/// Body that links \@geom-line and \@plot too.
///
/// @category Core
/// \@param x The x value, see \@aes.
/// @see \@geom-line, \@aes
#let foo(x: 1) = none
]])
    local parsed = parser.parse_file(f)
    local fn = parsed.functions[1]
    assert_eq(fn.name, "foo")
    assert_eq(fn.doc.summary, "Summary referencing @aes inline.")
    assert_contains(fn.doc.description[1], "@geom-line")
    assert_contains(fn.doc.description[1], "@plot")
    assert_eq(#fn.doc.params, 1)
    assert_eq(fn.doc.params[1].name, "x")
    assert_contains(fn.doc.params[1].description, "@aes")
    assert_eq(#fn.doc.see, 2)
    assert_eq(fn.doc.see[1], "@geom-line")
    assert_eq(fn.doc.see[2], "@aes")
    assert_true(parsed.module ~= nil, "expected module block")
    local mod = table.concat(parsed.module.lines, "\n")
    assert_contains(mod, "@aes")
    assert_contains(mod, "@plot")
  end)
end)

-- -----------------------------------------------------------------------
describe("parser: signature + @param matching", function()
  it("parses named params with defaults", function()
    local f = tmpfile("named", [[
/// Summary.
///
/// @category Core
/// @param x The x.
/// @param y The y.
#let foo(x: 1, y: 2) = none
]])
    local parsed = parser.parse_file(f)
    local fn = parsed.functions[1]
    assert_eq(#fn.signature_params, 2)
    assert_eq(fn.signature_params[1].name, "x")
    assert_eq(fn.signature_params[1].default, "1")
    assert_eq(fn.signature_params[2].name, "y")
    assert_eq(fn.signature_params[2].default, "2")
  end)

  it("parses variadic ..args", function()
    local f = tmpfile("variadic", [[
/// Summary.
///
/// @category Core
/// @param ..args All extras.
#let foo(..args) = none
]])
    local parsed = parser.parse_file(f)
    local fn = parsed.functions[1]
    assert_eq(fn.signature_params[1].name, "args")
    assert_true(fn.signature_params[1].variadic)
    assert_true(fn.doc.params[1].variadic)
  end)

  it("parses @arity entries", function()
    local f = tmpfile("arity", [[
/// Summary.
///
/// @category Core
/// @param ..args Variadic.
/// @arity (data, col): Two-arg form.
/// @arity (col): One-arg form.
#let foo(..args) = none
]])
    local parsed = parser.parse_file(f)
    local doc = parsed.functions[1].doc
    assert_eq(#doc.arities, 2)
    assert_eq(doc.arities[1].signature, "(data, col)")
    assert_eq(doc.arities[1].description, "Two-arg form.")
    assert_eq(doc.arities[2].signature, "(col)")
  end)

  it("handles multi-line signatures with nested parens", function()
    local f = tmpfile("multiline", [[
/// Summary.
///
/// @category Core
/// @param x X.
/// @param layers Layers.
#let foo(
  x: rgb("#888888"),
  layers: (a: 1, b: (1, 2, 3)),
) = none
]])
    local parsed = parser.parse_file(f)
    local fn = parsed.functions[1]
    assert_eq(#fn.signature_params, 2)
    assert_eq(fn.signature_params[1].name, "x")
    assert_contains(fn.signature_params[1].default, "rgb")
    assert_eq(fn.signature_params[2].name, "layers")
  end)

  it("ignores underscore-prefixed helpers", function()
    local f = tmpfile("underscore", [[
#let _helper(x) = x
#let _other() = none
]])
    local parsed = parser.parse_file(f)
    assert_eq(#parsed.functions, 0)
  end)

  it("ignores pipeline hooks (draw, apply)", function()
    local f = tmpfile("hooks", [[
#let draw(ctx) = none
#let apply(ctx) = none
]])
    local parsed = parser.parse_file(f)
    assert_eq(#parsed.functions, 0)
  end)

  it("treats `#let name = expr(...)` as a value binding", function()
    local f = tmpfile("valueparen", [[
/// Default swatch.
///
/// @category Core
#let swatch = rgb("#1f77b4")
]])
    local parsed = parser.parse_file(f)
    assert_eq(#parsed.functions, 1)
    assert_true(parsed.functions[1].is_value, "should be value, not function")
    assert_eq(#parsed.functions[1].signature_params, 0)
  end)

  it("parses a function after a multi-line value binding", function()
    local f = tmpfile("valuethenfn", [[
#let palette = (
  rgb("#1f77b4"),
  rgb("#2ca02c"),
)

/// Summary.
///
/// @category Core
/// @param x X.
#let foo(x: 1) = x
]])
    local parsed = parser.parse_file(f)
    assert_eq(#parsed.functions, 2)
    assert_true(parsed.functions[1].is_value)
    assert_eq(parsed.functions[2].name, "foo")
    assert_eq(parsed.functions[2].is_value, false)
  end)
end)

-- -----------------------------------------------------------------------
describe("parser: validate_function", function()
  local function lib_info(exports_list)
    local exports = {}
    for _, e in ipairs(exports_list) do
      exports[e.name] = e
    end
    return { exports = exports, category_order = {} }
  end

  it("errors when exported function has no doc block", function()
    local f = tmpfile("noblock", [[
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    local info = lib_info({ { name = "foo", category = "Core" } })
    assert_throws(function() parser.validate_function(parsed.functions[1], info) end,
      "no doc block")
  end)

  it("errors when @param list misses a signature param", function()
    local f = tmpfile("missparam", [[
/// Summary.
///
/// @category Core
/// @param x X.
#let foo(x: 1, y: 2) = none
]])
    local parsed = parser.parse_file(f)
    local info = lib_info({ { name = "foo", category = "Core" } })
    assert_throws(function() parser.validate_function(parsed.functions[1], info) end,
      "missing from doc block")
  end)

  it("errors when @param names a non-existent signature param", function()
    local f = tmpfile("extraparam", [[
/// Summary.
///
/// @category Core
/// @param x X.
/// @param z Z.
#let foo(x: 1) = none
]])
    local parsed = parser.parse_file(f)
    local info = lib_info({ { name = "foo", category = "Core" } })
    assert_throws(function() parser.validate_function(parsed.functions[1], info) end,
      "not in signature")
  end)

  it("errors when @category disagrees with lib.typ banner", function()
    local f = tmpfile("wrongcat", [[
/// Summary.
///
/// @category Core
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    local info = lib_info({ { name = "foo", category = "Geoms" } })
    assert_throws(function() parser.validate_function(parsed.functions[1], info) end,
      "does not match lib.typ banner")
  end)

  it("accepts a correct block without throwing", function()
    local f = tmpfile("good", [[
/// Summary.
///
/// @category Core
/// @param x X.
/// @returns A thing.
#let foo(x: 1) = none
]])
    local parsed = parser.parse_file(f)
    local info = lib_info({ { name = "foo", category = "Core" } })
    parser.validate_function(parsed.functions[1], info)
  end)
end)

-- -----------------------------------------------------------------------
describe("parser: @examples handling", function()
  it("captures renderable example with //| attributes", function()
    local f = tmpfile("example", [[
/// Summary.
///
/// @category Core
/// @examples
/// ```
/// //| width: 10cm
/// //| height: 6cm
/// #plot(data: d, mapping: aes(x: "x", y: "y"))
/// ```
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    local exs = parsed.functions[1].doc.examples
    assert_eq(#exs, 1)
    assert_true(exs[1].render)
    assert_eq(#exs[1].segments, 1)
    assert_eq(exs[1].segments[1].kind, "code")
    assert_eq(exs[1].segments[1].attributes.width, "10cm")
    assert_eq(exs[1].segments[1].attributes.height, "6cm")
    assert_contains(exs[1].segments[1].source, "#plot")
  end)

  it("distinguishes @examples from @examples-static", function()
    local f = tmpfile("static", [[
/// Summary.
///
/// @category Core
/// @examples-static
/// ```
/// foo()
/// ```
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    local exs = parsed.functions[1].doc.examples
    assert_eq(#exs, 1)
    assert_eq(exs[1].render, false)
  end)

  it("errors when example fence is unterminated", function()
    local f = tmpfile("badfence", [[
/// Summary.
///
/// @category Core
/// @examples
/// ```
/// foo()
#let foo() = none
]])
    assert_throws(function() parser.parse_file(f) end, "fence never closes")
  end)

  it("errors when @examples block has no code fence", function()
    local f = tmpfile("nofence", [[
/// Summary.
///
/// @category Core
/// @examples Just prose, no fence.
/// @returns Nothing.
#let foo() = none
]])
    assert_throws(function() parser.parse_file(f) end, "must contain at least one code fence")
  end)

  it("captures inline caption on the tag line", function()
    local f = tmpfile("inlinecap", [[
/// Summary.
///
/// @category Core
/// @examples Default invocation.
/// ```
/// foo()
/// ```
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    local exs = parsed.functions[1].doc.examples
    assert_eq(#exs[1].segments, 2)
    assert_eq(exs[1].segments[1].kind, "prose")
    assert_eq(exs[1].segments[1].text, "Default invocation.")
    assert_eq(exs[1].segments[2].kind, "code")
  end)

  it("captures multi-line caption between tag and fence", function()
    local f = tmpfile("multilinecap", [[
/// Summary.
///
/// @category Core
/// @examples
/// First sentence of the caption.
/// Second sentence on the next line.
///
/// A second paragraph.
/// ```
/// foo()
/// ```
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    local exs = parsed.functions[1].doc.examples
    assert_eq(exs[1].segments[1].kind, "prose")
    assert_contains(exs[1].segments[1].text, "First sentence of the caption.")
    assert_contains(exs[1].segments[1].text, "Second sentence on the next line.")
    assert_contains(exs[1].segments[1].text, "\n\nA second paragraph.")
  end)

  it("collects multiple fences and prose into one block of segments", function()
    local f = tmpfile("blockmulti", [[
/// Summary.
///
/// @category Core
/// @examples
/// First step prose.
/// ```
/// foo()
/// ```
///
/// Second step prose.
/// ```
/// bar()
/// ```
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    local exs = parsed.functions[1].doc.examples
    assert_eq(#exs, 1)
    assert_true(exs[1].render)
    assert_eq(#exs[1].segments, 4)
    assert_eq(exs[1].segments[1].kind, "prose")
    assert_eq(exs[1].segments[1].text, "First step prose.")
    assert_eq(exs[1].segments[2].kind, "code")
    assert_contains(exs[1].segments[2].source, "foo()")
    assert_eq(exs[1].segments[3].kind, "prose")
    assert_eq(exs[1].segments[3].text, "Second step prose.")
    assert_eq(exs[1].segments[4].kind, "code")
    assert_contains(exs[1].segments[4].source, "bar()")
  end)

  it("closes @examples block at the next @tag", function()
    local f = tmpfile("blockclose", [[
/// Summary.
///
/// @category Core
/// @examples
/// Setup.
/// ```
/// foo()
/// ```
/// @returns A thing.
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    local doc = parsed.functions[1].doc
    assert_eq(doc.returns, "A thing.")
    assert_eq(#doc.examples, 1)
    assert_eq(#doc.examples[1].segments, 2)
    assert_eq(doc.examples[1].segments[1].text, "Setup.")
  end)

  it("treats @examples-static as a block with non-rendered code", function()
    local f = tmpfile("staticblock", [[
/// Summary.
///
/// @category Core
/// @examples-static
/// Step 1.
/// ```
/// foo()
/// ```
///
/// Step 2.
/// ```
/// bar()
/// ```
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    local exs = parsed.functions[1].doc.examples
    assert_eq(#exs, 1)
    assert_eq(exs[1].render, false)
    assert_eq(#exs[1].segments, 4)
    assert_eq(exs[1].segments[2].kind, "code")
    assert_eq(exs[1].segments[4].kind, "code")
  end)

  it("rejects unknown legacy @example tag", function()
    local f = tmpfile("legacy", [[
/// Summary.
///
/// @category Core
/// @example
/// ```
/// foo()
/// ```
#let foo() = none
]])
    assert_throws(function() parser.parse_file(f) end, "unknown tag")
  end)
end)

-- -----------------------------------------------------------------------
describe("parser: indented continuation lines", function()
  it("merges indented continuation into @param description", function()
    local f = tmpfile("paramcont", [[
/// Summary.
///
/// @category Core
/// @param x The x value
///   continues on a second line
///   and ends here.
#let foo(x: 1) = none
]])
    local parsed = parser.parse_file(f)
    local p = parsed.functions[1].doc.params[1]
    assert_eq(p.name, "x")
    assert_eq(p.description, "The x value continues on a second line and ends here.")
  end)

  it("keeps a leading @ref on an indented line as part of the description", function()
    local f = tmpfile("paramref", [[
/// Summary.
///
/// @category Core
/// @param x The x value, see
///   \@bar for more info.
#let foo(x: 1) = none
]])
    local parsed = parser.parse_file(f)
    local p = parsed.functions[1].doc.params[1]
    assert_eq(p.description, "The x value, see @bar for more info.")
  end)

  it("merges indented continuation into @returns", function()
    local f = tmpfile("returnscont", [[
/// Summary.
///
/// @category Core
/// @returns A dictionary
///   with several fields.
#let foo() = none
]])
    local parsed = parser.parse_file(f)
    assert_eq(parsed.functions[1].doc.returns, "A dictionary with several fields.")
  end)

  it("starts a new tag on a non-indented @param line", function()
    local f = tmpfile("twoparams", [[
/// Summary.
///
/// @category Core
/// @param x The x value
///   continues here.
/// @param y The y value.
#let foo(x: 1, y: 2) = none
]])
    local parsed = parser.parse_file(f)
    local params = parsed.functions[1].doc.params
    assert_eq(#params, 2)
    assert_eq(params[1].description, "The x value continues here.")
    assert_eq(params[2].description, "The y value.")
  end)
end)

-- -----------------------------------------------------------------------
describe("parser: parse_lib", function()
  it("extracts exports grouped by banner", function()
    local f = tmpfile("lib", [[
#import "src/plot.typ": plot
#import "src/aes.typ": aes

// Geoms.
#import "src/geom/point.typ": geom-point
#import "src/geom/line.typ": geom-line

// Stats.
#import "src/stat/bin.typ": stat-bin
]])
    local info = parser.parse_lib(f)
    assert_eq(info.exports["plot"].category, nil, "plot has no banner above it")
    assert_eq(info.exports["geom-point"].category, "Geoms")
    assert_eq(info.exports["geom-line"].category, "Geoms")
    assert_eq(info.exports["stat-bin"].category, "Stats")
    assert_eq(info.category_order[1], "Geoms")
    assert_eq(info.category_order[2], "Stats")
  end)

  it("ignores banners that aren't valid categories", function()
    local f = tmpfile("libnoisy", [[
// Nonsense banner.
#import "src/foo.typ": foo

// Geoms.
#import "src/geom/x.typ": x
]])
    local info = parser.parse_lib(f)
    assert_eq(#info.category_order, 1)
    assert_eq(info.category_order[1], "Geoms")
  end)
end)

-- -----------------------------------------------------------------------
describe("resolve: cross-references", function()
  it("warns on unresolved @ref (non-strict)", function()
    local out = resolve.resolve_refs_in_text("See @missing for details.", "core/foo.qmd", {}, false, "x.typ", 1)
    assert_contains(out, "@missing")
  end)

  it("errors on unresolved @ref under strict", function()
    assert_throws(function()
      resolve.resolve_refs_in_text("See @missing.", "core/foo.qmd", {}, true, "x.typ", 1)
    end, "unresolved")
  end)

  it("resolves @ref to relative link", function()
    local index = {
      bar = { name = "bar", category = "Geoms", category_slug = "geoms", qmd_path = "geoms/bar.qmd" }
    }
    local out = resolve.resolve_refs_in_text("See @bar.", "core/foo.qmd", index, false)
    assert_contains(out, "[`bar`](../geoms/bar.qmd)")
  end)

  it("produces relative links across categories", function()
    assert_eq(resolve.relative_link("core/foo.qmd", "geoms/bar.qmd"), "../geoms/bar.qmd")
    assert_eq(resolve.relative_link("geoms/foo.qmd", "geoms/bar.qmd"), "bar.qmd")
    assert_eq(resolve.relative_link("index.qmd", "geoms/bar.qmd"), "geoms/bar.qmd")
  end)
end)

-- -----------------------------------------------------------------------
cleanup()

io.write(string.format("\n%d passed, %d failed\n", T.passed, T.failed))
if T.failed > 0 then os.exit(1) end
