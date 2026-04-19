#!/usr/bin/env lua

local function script_dir()
  local source = debug.getinfo(1, "S").source
  if source:sub(1, 1) == "@" then source = source:sub(2) end
  return source:match("^(.*)/[^/]+$") or "."
end
local DIR = script_dir()
local DEFAULT_ROOT = DIR .. "/../.."
package.path = DIR .. "/?.lua;" .. package.path

local util = require("util")
local parser = require("parser")
local render = require("render")
local resolve = require("resolve")
local config_patch = require("config_patch")
local deps = require("deps")
local examples = require("examples")
local changelog = require("changelog")

local USAGE = [[
Usage: tools/typstdoc/main.lua [options]

Options:
  --root <dir>        Repository root (default: two levels above this script). Prefixes all path defaults.
  --src <dir>         Source directory to scan (default: <root>/src)
  --lib <file>        Library entry point (default: <root>/lib.typ)
  --out <dir>         Output directory for reference pages (default: <root>/docs/reference)
  --sidebar <file>    Sidebar YAML output (default: <root>/docs/_sidebar-reference.yml)
  --docs <dir>        Quarto project directory to patch (default: <root>/docs)
  --toml <file>       Package manifest to read (default: <root>/typst.toml)
  --deps <file>       Typst dependency entry file (default: <root>/src/deps.typ)
  --variables <file>  YAML output with compiler + dependency versions (default: <root>/docs/_variables.yml)
  --strict            Treat unresolved @refs as errors
  --check             Parse and validate without writing
  --help              Show this help and exit
]]

local VALUE_FLAGS = {
  ["--root"] = "root",
  ["--src"] = "src",
  ["--lib"] = "lib",
  ["--out"] = "out",
  ["--sidebar"] = "sidebar",
  ["--docs"] = "docs",
  ["--toml"] = "toml",
  ["--deps"] = "deps_file",
  ["--variables"] = "variables",
}

local BOOL_FLAGS = {
  ["--strict"] = "strict",
  ["--check"] = "check",
}

local function parse_args(argv)
  local opts = { root = DEFAULT_ROOT, strict = false, check = false }
  local i = 1
  while i <= #argv do
    local a = argv[i]
    if a == "--help" or a == "-h" then
      io.write(USAGE); os.exit(0)
    elseif BOOL_FLAGS[a] then
      opts[BOOL_FLAGS[a]] = true; i = i + 1
    elseif VALUE_FLAGS[a] then
      local value = argv[i + 1]
      if not value then util.die("missing value for " .. a) end
      opts[VALUE_FLAGS[a]] = value; i = i + 2
    else
      util.die("unknown argument: " .. a)
    end
  end
  opts.src = opts.src or (opts.root .. "/src")
  opts.lib = opts.lib or (opts.root .. "/lib.typ")
  opts.out = opts.out or (opts.root .. "/docs/reference")
  opts.sidebar = opts.sidebar or (opts.root .. "/docs/_sidebar-reference.yml")
  opts.docs = opts.docs or (opts.root .. "/docs")
  opts.toml = opts.toml or (opts.root .. "/typst.toml")
  opts.deps_file = opts.deps_file or (opts.root .. "/src/deps.typ")
  opts.variables = opts.variables or (opts.root .. "/docs/_variables.yml")
  return opts
end

local function parse_sources(src_dir, lib_info)
  local files = util.find_typ_files(src_dir)
  local all_functions = {}
  local modules = {}
  for _, file in ipairs(files) do
    local parsed = parser.parse_file(file)
    if parsed.module then
      modules[#modules + 1] = {
        file = parsed.file,
        category = nil,
        description = parsed.module.lines,
      }
    end
    for _, fn in ipairs(parsed.functions) do
      parser.validate_function(fn, lib_info)
      all_functions[#all_functions + 1] = fn
    end
  end
  return files, all_functions, modules
end

local function report_check(files, all_functions, deps_info, examples_result, changelog_result)
  local examples_status = examples_result.skipped_entirely
    and "examples skipped"
    or string.format("examples %d in sync", examples_result.skipped)
  local changelog_status = changelog_result.skipped_entirely
    and "changelog skipped"
    or "changelog OK"
  util.log_info(string.format(
    "parsed %d function(s) across %d file(s); deps OK (%s); %s; %s; check OK",
    #all_functions, #files, deps.summary(deps_info),
    examples_status, changelog_status))
end

local function write_reference(opts, all_functions, modules, lib_info)
  local index = resolve.build_index(all_functions, lib_info)

  util.remove_dir(opts.out)
  util.make_dir(opts.out)

  local written = 0
  for _, fn in ipairs(all_functions) do
    if fn.doc and fn.doc.category then
      local body, rel_path = render.render_function(fn, index, { strict = opts.strict })
      util.write_file(opts.out .. "/" .. rel_path, body)
      written = written + 1
    end
  end

  for _, cat in ipairs(lib_info.category_order) do
    local body, rel_path = render.render_category_index(cat, all_functions, modules)
    util.write_file(opts.out .. "/" .. rel_path, body)
  end

  local top_body, top_path = render.render_top_index(lib_info.category_order, all_functions)
  util.write_file(opts.out .. "/" .. top_path, top_body)

  util.write_file(opts.sidebar, render.render_sidebar(lib_info.category_order, all_functions))
  return written
end

local function main(argv)
  local ok, opts = pcall(parse_args, argv)
  if not ok then util.log_err(tostring(opts)); io.write(USAGE); os.exit(2) end

  local deps_info = deps.collect({
    toml = opts.toml,
    deps_file = opts.deps_file,
    src = opts.src,
  })

  local examples_result = examples.run({
    root = opts.root,
    subdir = "examples",
    dst_dir = opts.docs .. "/examples",
    check = opts.check,
  })

  local changelog_result = changelog.run({
    input = opts.root .. "/CHANGELOG.md",
    output = opts.docs .. "/changelog.qmd",
    check = opts.check,
  })

  local lib_info = parser.parse_lib(opts.lib)
  local files, all_functions, modules = parse_sources(opts.src, lib_info)

  if opts.check then
    report_check(files, all_functions, deps_info, examples_result, changelog_result)
    return 0
  end

  util.write_file(opts.variables, deps.render(deps_info))
  local written = write_reference(opts, all_functions, modules, lib_info)

  local sidebar_basename = opts.sidebar:match("([^/]+)$") or opts.sidebar
  config_patch.patch_metadata_yml(opts.docs .. "/_metadata.yml")
  config_patch.patch_quarto_yml(opts.docs .. "/_quarto.yml", sidebar_basename)

  local stub_ref = opts.docs .. "/reference.qmd"
  if util.file_exists(stub_ref) then util.remove_file(stub_ref) end

  util.log_info(string.format("wrote %d function page(s) under %s", written, opts.out))
  return 0
end

local ok, err = pcall(main, arg or {})
if not ok then
  util.log_err(tostring(err))
  os.exit(1)
end
