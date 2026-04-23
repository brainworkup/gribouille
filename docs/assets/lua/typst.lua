--- @module typst
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @brief Typst source shortcode
--- @description Reads a `.typ` file from the repository, rewrites its top-level
--- `#import "...lib.typ": *` directive to the public registry import
--- `#import "@preview/gribouille:$VERSION": *`, and emits it as a `typst` code
--- block. Registered at project level via `shortcodes:` in `_quarto.yml`.

-- ============================================================================
-- SHORTCODE NAME
-- ============================================================================

local SHORTCODE_NAME = 'typst'

-- ============================================================================
-- HELPERS
-- ============================================================================

--- Read the contents of a file in binary mode.
--- @param path string Filesystem path to read
--- @return string|nil Contents of the file, or nil if it cannot be opened
local function read_file(path)
  local f = io.open(path, 'rb')
  if not f then return nil end
  local body = f:read('*a')
  f:close()
  return body
end

--- Rewrite the first `#import "...lib.typ": *` directive to the public
--- registry import so users see the same line they would write themselves.
--- `VERSION` is read from the environment; missing values fall back to `?.?.?`.
--- @param source string Raw Typst source
--- @return string Source with the first matching import rewritten
local function rewrite_lib_import(source)
  local version = os.getenv('VERSION') or '?.?.?'
  local replacement = '#import "@preview/gribouille:' .. version .. '": *'
  return (source:gsub('#import%s+"[^"]*lib%.typ"%s*:[^\n]*', replacement, 1))
end

-- ============================================================================
-- SHORTCODE
-- ============================================================================

--- `{{< typst PATH >}}` shortcode.
--- Emits the contents of `PATH` (resolved relative to the Quarto project
--- directory when the path is absolute, otherwise left as-is) as a `typst`
--- code block, with the `lib.typ` import rewritten to the public registry
--- import. Only `.typ` paths are accepted.
--- @param args table Positional arguments; `args[1]` must be the `.typ` path
--- @return table Pandoc blocks wrapping a single `pandoc.CodeBlock`
local function typst_shortcode(args)
  if #args < 1 then
    error(SHORTCODE_NAME .. ': missing PATH argument')
  end

  local rel = pandoc.utils.stringify(args[1])
  if not rel:match('%.typ$') then
    error(SHORTCODE_NAME .. ': expected a .typ file, got: ' .. rel)
  end

  local full
  if rel:sub(1, 1) == '/' then
    full = quarto.project.directory .. rel
  else
    full = rel
  end
  local body = read_file(full)
  if not body then
    error(SHORTCODE_NAME .. ': file not found: ' .. full)
  end

  body = rewrite_lib_import(body)
  body = body:gsub('\n$', '')

  return pandoc.Blocks({
    pandoc.CodeBlock(body, pandoc.Attr('', { 'typst' }, {})),
  })
end

return {
  [SHORTCODE_NAME] = typst_shortcode,
}
