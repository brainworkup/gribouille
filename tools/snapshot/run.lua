#!/usr/bin/env lua

-- Visual snapshot harness: extract → compile → diff (or update goldens).
-- Sources: examples/*.typ plus /// @examples fences in src/.

local function script_dir()
  local source = debug.getinfo(1, "S").source
  if source:sub(1, 1) == "@" then source = source:sub(2) end
  return source:match("^(.*)/[^/]+$") or "."
end

local DIR = script_dir()
local ROOT = DIR .. "/../.."
local function abs(path)
  if path:sub(1, 1) == "/" then return path end
  return ROOT .. "/" .. path
end

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

local function parse_args(argv)
  local opts = {
    mode = "check",
    root = ROOT,
    ppi = 144,
    tolerance = 0,
    fuzz = "1%",
    only = nil,
  }
  local i = 1
  while i <= #argv do
    local a = argv[i]
    if a == "--check" then opts.mode = "check"
    elseif a == "--update" then opts.mode = "update"
    elseif a == "--root" then i = i + 1; opts.root = argv[i]
    elseif a == "--ppi" then i = i + 1; opts.ppi = tonumber(argv[i]) or 144
    elseif a == "--tolerance" then i = i + 1; opts.tolerance = tonumber(argv[i]) or 0
    elseif a == "--fuzz" then i = i + 1; opts.fuzz = argv[i]
    elseif a == "--only" then i = i + 1; opts.only = argv[i]
    elseif a == "--help" or a == "-h" then io.write(USAGE); os.exit(0)
    else io.stderr:write("snapshot: unknown arg: " .. a .. "\n"); io.write(USAGE); os.exit(2)
    end
    i = i + 1
  end
  return opts
end

local function shell_quote(s)
  return "'" .. s:gsub("'", [['\'']]) .. "'"
end

local function ensure_parent(path)
  local dir = path:match("^(.*)/[^/]+$")
  if dir and dir ~= "" then util.make_dir(dir) end
end

local function compile_typst(src_typ, out_png, root, ppi)
  ensure_parent(out_png)
  local cmd = string.format(
    "typst compile %s --root %s --ppi %d %s 2>&1",
    shell_quote(src_typ), shell_quote(root), ppi, shell_quote(out_png)
  )
  local handle = io.popen(cmd .. "; echo EXIT_$?")
  local out = handle:read("*a")
  handle:close()
  local exit = out:match("EXIT_(%d+)") or "1"
  return exit == "0", out:gsub("EXIT_%d+%s*$", "")
end

local function diff_images(golden, current, diff_png, fuzz)
  ensure_parent(diff_png)
  local cmd = string.format(
    "magick compare -metric AE -fuzz %s %s %s %s 2>&1",
    fuzz, shell_quote(golden), shell_quote(current), shell_quote(diff_png)
  )
  local handle = io.popen(cmd .. "; echo EXIT_$?")
  local out = handle:read("*a")
  handle:close()
  local exit = tonumber(out:match("EXIT_(%d+)") or "1") or 1
  local body = out:gsub("EXIT_%d+%s*$", "")
  local ae = tonumber((body:gsub("[^%d.eE+]", " "):match("(%d+)"))) or 0
  return exit, ae, body
end

local function copy_file(src, dst)
  ensure_parent(dst)
  os.execute(string.format("cp %s %s", shell_quote(src), shell_quote(dst)))
end

local function main()
  local opts = parse_args(arg or {})
  opts.root = abs(opts.root)
  local build_root = opts.root .. "/build/snapshot"
  local golden_root = opts.root .. "/tests/visual/golden"

  util.remove_dir(build_root)
  util.make_dir(build_root .. "/src")
  util.make_dir(build_root .. "/png")
  util.make_dir(build_root .. "/diff")

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

  local compile_fail, diff_fail, missing, ok = {}, {}, {}, 0

  for _, s in ipairs(sources) do
    local png = string.format("%s/png/%s.png", build_root, s.key)
    local compiled, log = compile_typst(s.src_typ, png, opts.root, opts.ppi)
    if not compiled then
      compile_fail[#compile_fail + 1] = s.key
      io.write(string.format("COMPILE-FAIL %s\n%s\n", s.key, log))
    elseif opts.mode == "update" then
      copy_file(png, s.golden)
      ok = ok + 1
      io.write(string.format("update       %s\n", s.key))
    else
      if not util.file_exists(s.golden) then
        missing[#missing + 1] = s.key
        io.write(string.format("MISSING      %s (no golden at %s)\n", s.key, s.golden))
      else
        local diff_png = string.format("%s/diff/%s.png", build_root, s.key)
        local exit, ae = diff_images(s.golden, png, diff_png, opts.fuzz)
        if exit > 1 or ae > opts.tolerance then
          diff_fail[#diff_fail + 1] = string.format("%s (AE=%d, exit=%d)", s.key, ae, exit)
          io.write(string.format("DIFF         %s  AE=%d\n", s.key, ae))
        else
          ok = ok + 1
          io.write(string.format("ok           %s\n", s.key))
        end
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

  if opts.mode == "check" and (#compile_fail + #missing + #diff_fail) > 0 then
    os.exit(1)
  end
  if opts.mode == "update" and #compile_fail > 0 then
    os.exit(1)
  end
end

main()
