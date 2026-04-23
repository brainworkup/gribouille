--- @module typst
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @brief Typst source shortcode
--- @description Reads a `.typ` file from the repository, strips its top-level
--- `#import "...lib.typ": *` directive so the `typst-render` preamble theme
--- wrappers are not shadowed, and emits it as a `typst` code block. Registered
--- at project level via `shortcodes:` in `_quarto.yml`.

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

--- Strip the first `#import "...lib.typ": *` directive from a Typst source.
--- The `typst-render` preamble provides document-colour-aware theme wrappers
--- that the repository's standalone `lib.typ` import would otherwise shadow.
--- @param source string Raw Typst source
--- @return string Source with the first matching import removed
local function strip_lib_import(source)
  return (source:gsub('#import%s+"[^"]*lib%.typ"%s*:[^\n]*\n?', '', 1))
end

-- ============================================================================
-- SHORTCODE
-- ============================================================================

--- `{{< typst PATH >}}` shortcode.
--- Emits the contents of `PATH` (resolved relative to the repository root,
--- one level above the Quarto project) as a `typst` code block, with the
--- `lib.typ` import stripped. Only `.typ` paths are accepted.
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

  local full = quarto.project.directory .. '/../' .. rel
  local body = read_file(full)
  if not body then
    error(SHORTCODE_NAME .. ': file not found: ' .. full)
  end

  body = strip_lib_import(body)
  body = body:gsub('\n$', '')

  return pandoc.Blocks({
    pandoc.CodeBlock(body, pandoc.Attr('', { 'typst' }, {})),
  })
end

return {
  [SHORTCODE_NAME] = typst_shortcode,
}
