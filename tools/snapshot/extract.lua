local util = require("util")
local parser = require("parser")

local M = {}

-- Wraps a /// @examples fence in the same self-contained shell as `examples/*.typ`.
-- `auto` page size keeps the diff focused on plot pixels rather than blank margins.
local WRAPPER = '#import "/lib.typ": *\n#set page(width: auto, height: auto, margin: 0.5cm)\n\n%s\n'

local function collect_examples(root, golden_root)
  local sources = {}
  for _, f in ipairs(util.find_typ_files(root .. "/examples")) do
    local name = f:match("([^/]+)%.typ$")
    sources[#sources + 1] = {
      key = "examples/" .. name,
      src_typ = f,
      golden = string.format("%s/examples/%s.png", golden_root, name),
    }
  end
  return sources
end

local function append_docstring_fences(fn, build_root, golden_root, sources)
  if not fn.doc then return end
  local idx = 0
  for _, ex in ipairs(fn.doc.examples or {}) do
    if ex.render then
      for _, seg in ipairs(ex.segments) do
        if seg.kind == "code" then
          idx = idx + 1
          local out_typ = string.format("%s/src/%s-%d.typ", build_root, fn.name, idx)
          util.write_file(out_typ, string.format(WRAPPER, seg.source))
          sources[#sources + 1] = {
            key = string.format("docstrings/%s-%d", fn.name, idx),
            src_typ = out_typ,
            golden = string.format("%s/docstrings/%s-%d.png", golden_root, fn.name, idx),
          }
        end
      end
    end
  end
end

local function collect_docstrings(root, build_root, golden_root)
  local sources = {}
  parser.set_root(root)
  for _, f in ipairs(util.find_typ_files(root .. "/src")) do
    for _, fn in ipairs(parser.parse_file(f).functions or {}) do
      append_docstring_fences(fn, build_root, golden_root, sources)
    end
  end
  return sources
end

function M.collect(opts)
  assert(opts.root, "extract.collect: root required")
  assert(opts.build_root, "extract.collect: build_root required")
  assert(opts.golden_root, "extract.collect: golden_root required")

  local sources = {}
  for _, s in ipairs(collect_examples(opts.root, opts.golden_root)) do
    sources[#sources + 1] = s
  end
  for _, s in ipairs(collect_docstrings(opts.root, opts.build_root, opts.golden_root)) do
    sources[#sources + 1] = s
  end
  table.sort(sources, function(a, b) return a.key < b.key end)
  return sources
end

return M
