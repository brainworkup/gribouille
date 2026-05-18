-- Collects snapshot sources: standalone examples/ files plus per-fence
-- wrappers extracted from /// @examples blocks via the typstdoc parser.

local util = require("util")
local parser = require("parser")

local M = {}

local WRAPPER = '#import "/lib.typ": *\n#set page(width: auto, height: auto, margin: 0.5cm)\n\n%s\n'

local function ensure_parent(path)
  local dir = path:match("^(.*)/[^/]+$")
  if dir and dir ~= "" then util.make_dir(dir) end
end

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

local function collect_docstrings(root, build_root, golden_root)
  local sources = {}
  parser.set_root(root)
  for _, f in ipairs(util.find_typ_files(root .. "/src")) do
    local parsed = parser.parse_file(f)
    for _, fn in ipairs(parsed.functions or {}) do
      if fn.doc then
        local idx = 0
        for _, ex in ipairs(fn.doc.examples or {}) do
          if ex.render then
            for _, seg in ipairs(ex.segments) do
              if seg.kind == "code" then
                idx = idx + 1
                local wrapped = string.format(WRAPPER, seg.source)
                local out_typ = string.format("%s/src/%s-%d.typ", build_root, fn.name, idx)
                ensure_parent(out_typ)
                util.write_file(out_typ, wrapped)
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
    end
  end
  return sources
end

function M.collect(opts)
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
