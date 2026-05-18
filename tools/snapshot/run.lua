#!/usr/bin/env lua

local function script_dir()
  local source = debug.getinfo(1, "S").source
  if source:sub(1, 1) == "@" then source = source:sub(2) end
  return source:match("^(.*)/[^/]+$") or "."
end

local DIR = script_dir()
local ROOT = DIR .. "/../.."

package.path = DIR .. "/?.lua;" .. ROOT .. "/tools/typstdoc/?.lua;" .. package.path

local util = require("util")
local extract = require("extract")

local USAGE = [[
Usage: tools/snapshot/run.lua [--check | --update] [options]

Modes:
  --check         Compile and diff against tests/visual/golden/ (default).
  --update        Compile and overwrite goldens in tests/visual/golden/.

Options:
  --root <dir>    Repository root (default: two levels above this script).
  --ppi <n>       Raster density (default: 144).
  --tolerance <n> Max AE pixel count per diff (default: 0).
  --fuzz <pct>    ImageMagick `-fuzz` value (default: 1%).
  --only <key>    Only run sources whose key contains this substring.
  --help          Show this help and exit.
]]

local function abs(path)
  if path:sub(1, 1) == "/" then return path end
  return ROOT .. "/" .. path
end

local function shell_quote(s)
  return "'" .. s:gsub("'", [['\'']]) .. "'"
end

local function parse_args(argv)
  local opts = {
    update = false,
    root = ROOT,
    ppi = 144,
    tolerance = 0,
    fuzz = "1%",
    only = nil,
  }
  local i = 1
  local function take_value(flag)
    i = i + 1
    if i > #argv then
      io.stderr:write("snapshot: " .. flag .. " requires a value\n")
      os.exit(2)
    end
    return argv[i]
  end
  while i <= #argv do
    local a = argv[i]
    if a == "--check" then opts.update = false
    elseif a == "--update" then opts.update = true
    elseif a == "--root" then opts.root = take_value(a)
    elseif a == "--ppi" then opts.ppi = tonumber(take_value(a)) or opts.ppi
    elseif a == "--tolerance" then opts.tolerance = tonumber(take_value(a)) or opts.tolerance
    elseif a == "--fuzz" then opts.fuzz = take_value(a)
    elseif a == "--only" then opts.only = take_value(a)
    elseif a == "--help" or a == "-h" then io.write(USAGE); os.exit(0)
    else io.stderr:write("snapshot: unknown arg: " .. a .. "\n"); io.write(USAGE); os.exit(2)
    end
    i = i + 1
  end
  return opts
end

local function compile_typst(src_typ, out_png, root, ppi)
  local cmd = string.format(
    "typst compile %s --root %s --ppi %d %s 2>&1",
    shell_quote(src_typ), shell_quote(root), ppi, shell_quote(out_png)
  )
  local code, out = util.popen_capture(cmd)
  return code == 0, out
end

-- ImageMagick `compare -metric AE` writes the pixel-difference count last on stderr.
local function diff_images(golden, current, diff_png, fuzz)
  local cmd = string.format(
    "magick compare -metric AE -fuzz %s %s %s %s 2>&1",
    fuzz, shell_quote(golden), shell_quote(current), shell_quote(diff_png)
  )
  local code, out = util.popen_capture(cmd)
  local ae = tonumber(out:match("(%d+)%s*$")) or 0
  return code, ae
end

local function main()
  local opts = parse_args(arg or {})
  opts.root = abs(opts.root)
  local build_root = opts.root .. "/build/snapshot"
  local golden_root = opts.root .. "/tests/visual/golden"

  util.remove_dir(build_root)
  for _, sub in ipairs({ "src", "png/examples", "png/docstrings", "diff/examples", "diff/docstrings" }) do
    util.make_dir(build_root .. "/" .. sub)
  end

  local sources = extract.collect({
    root = opts.root,
    build_root = build_root,
    golden_root = golden_root,
  })

  if opts.only then
    local filtered = {}
    for _, s in ipairs(sources) do
      if s.key:find(opts.only, 1, true) then filtered[#filtered + 1] = s end
    end
    sources = filtered
  end

  if #sources == 0 then
    io.stderr:write("snapshot: no sources matched\n")
    os.exit(1)
  end

  if opts.update then
    util.make_dir(golden_root .. "/examples")
    util.make_dir(golden_root .. "/docstrings")
  end

  local compile_fail, diff_fail, missing, ok = {}, {}, {}, 0

  for _, s in ipairs(sources) do
    local png = string.format("%s/png/%s.png", build_root, s.key)
    local compiled, log = compile_typst(s.src_typ, png, opts.root, opts.ppi)
    if not compiled then
      compile_fail[#compile_fail + 1] = s.key
      io.write(string.format("COMPILE-FAIL %s\n%s\n", s.key, log))
    elseif opts.update then
      util.copy_file(png, s.golden)
      ok = ok + 1
      io.write(string.format("update       %s\n", s.key))
    elseif not util.file_exists(s.golden) then
      missing[#missing + 1] = s.key
      io.write(string.format("MISSING      %s (no golden at %s)\n", s.key, s.golden))
    else
      local diff_png = string.format("%s/diff/%s.png", build_root, s.key)
      local code, ae = diff_images(s.golden, png, diff_png, opts.fuzz)
      if code > 1 or ae > opts.tolerance then
        diff_fail[#diff_fail + 1] = string.format("%s (AE=%d, exit=%d)", s.key, ae, code)
        io.write(string.format("DIFF         %s  AE=%d\n", s.key, ae))
      else
        ok = ok + 1
        io.write(string.format("ok           %s\n", s.key))
      end
    end
  end

  local total = #sources
  io.write(string.format("\nsnapshots: %d/%d ok\n", ok, total))
  if #compile_fail > 0 then
    io.write(string.format("compile failures: %d\n", #compile_fail))
  end
  if #missing > 0 then
    io.write(string.format("missing goldens:  %d\n", #missing))
  end
  if #diff_fail > 0 then
    io.write(string.format("diff failures:    %d\n", #diff_fail))
    for _, line in ipairs(diff_fail) do io.write("  " .. line .. "\n") end
  end

  if not opts.update and (#compile_fail + #missing + #diff_fail) > 0 then
    os.exit(1)
  end
  if opts.update and #compile_fail > 0 then
    os.exit(1)
  end
end

main()
