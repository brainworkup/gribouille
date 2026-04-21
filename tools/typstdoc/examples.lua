-- Mirror /examples/ into docs/examples/ so the Quarto site has a colocated copy
-- of every `.typ` snippet and data fixture.
-- The top-level /examples/ directory stays the source of truth; local render
-- artefacts (`.pdf`, `.png`) are gitignored, so we list git-tracked files to
-- keep the mirror in lockstep with what the repository publishes.

local util = require("util")

local M = {}

-- Examples are standalone-compilable and import lib.typ themselves. The docs
-- mirror drops that import so the typst-render preamble's document-colour-aware
-- theme wrappers aren't shadowed when files are included.
local function strip_lib_import(bytes, name)
  if not name:match("%.typ$") then return bytes end
  local pattern = '#import%s+"[^"]*lib%.typ"%s*:[^\n]*\n?'
  local stripped = bytes:gsub(pattern, "", 1)
  return stripped
end

local function mirror(root, subdir, dst_dir, check_only)
  local src_dir = root .. "/" .. subdir
  local src_names = util.git_tracked_in(root, subdir)
  local src_set = {}
  for _, name in ipairs(src_names) do src_set[name] = true end

  if not check_only then util.make_dir(dst_dir) end

  local copied, removed, skipped, drift = 0, 0, 0, {}

  for _, name in ipairs(src_names) do
    local src_path = src_dir .. "/" .. name
    local dst_path = dst_dir .. "/" .. name
    local src_bytes = util.read_file(src_path) or util.die("cannot read " .. src_path)
    src_bytes = strip_lib_import(src_bytes, name)
    local dst_bytes = util.read_file(dst_path)
    if dst_bytes == src_bytes then
      skipped = skipped + 1
    elseif check_only then
      drift[#drift + 1] = (dst_bytes == nil and "missing: " or "stale: ") .. name
    else
      local ok, err = util.write_file(dst_path, src_bytes)
      if not ok then util.die("cannot write " .. dst_path .. ": " .. tostring(err)) end
      copied = copied + 1
    end
  end

  for _, name in ipairs(util.list_dir_files(dst_dir)) do
    if not src_set[name] then
      if check_only then
        drift[#drift + 1] = "orphan: " .. name
      else
        os.remove(dst_dir .. "/" .. name)
        removed = removed + 1
      end
    end
  end

  return { copied = copied, removed = removed, skipped = skipped, drift = drift }
end

function M.run(opts)
  local src_dir = opts.root .. "/" .. opts.subdir
  if not util.dir_exists(src_dir) then
    util.log_info(string.format("%s not present, skipping examples mirror", src_dir))
    return { skipped_entirely = true }
  end

  local result = mirror(opts.root, opts.subdir, opts.dst_dir, opts.check)
  if #result.drift > 0 then
    io.stderr:write(string.format(
      "typstdoc: %s is out of sync with %s\n", opts.dst_dir, src_dir))
    for _, d in ipairs(result.drift) do
      io.stderr:write("  - " .. d .. "\n")
    end
    util.die(string.format("%s drift detected", opts.dst_dir))
  end
  return result
end

return M
