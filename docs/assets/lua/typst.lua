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

--- Ensure the source carries a `#import "@preview/gribouille:VERSION": *`
--- directive so users see the same line they would write themselves. If an
--- existing `lib.typ` import is present it is rewritten in place; otherwise
--- the package import is inserted after the leading comment block.
--- `VERSION` is read from the environment; missing values fall back to `?.?.?`.
--- @param source string Raw Typst source
--- @return string Source with the package import present
local function rewrite_lib_import(source)
  local version = os.getenv('VERSION') or '?.?.?'
  local replacement = '#import "@preview/gribouille:' .. version .. '": *'
  local rewritten, n = source:gsub('#import%s+"[^"]*lib%.typ"%s*:[^\n]*', replacement, 1)
  if n > 0 then
    return rewritten
  end
  local header_lines = {}
  local rest_start = 1
  for line, next_pos in source:gmatch('([^\n]*)\n()') do
    if line:match('^%s*//') or line:match('^%s*$') then
      header_lines[#header_lines + 1] = line
      rest_start = next_pos
    else
      break
    end
  end
  local rest = source:sub(rest_start):gsub('^\n+', '')
  if #header_lines > 0 then
    return table.concat(header_lines, '\n') .. '\n' .. replacement .. '\n\n' .. rest
  end
  return replacement .. '\n\n' .. rest
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
