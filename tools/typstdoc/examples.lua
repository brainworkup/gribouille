-- Example/gallery consistency: every `examples/*.typ` must have a `gallery.yml`
-- slug or be explicitly excluded, otherwise it never renders (the gallery
-- listing is slug-driven). Pure helpers; I/O lives in main.lua.
local M = {}

-- Hero/landing art embedded directly by `docs/index.qmd` and site assets,
-- deliberately absent from the gallery.
M.EXCLUDE = { gribouille = true, showcase = true }

-- Collect `slug:` values from a `gallery.yml` document body.
function M.parse_slugs(content)
  local slugs = {}
  for line in (content .. "\n"):gmatch("([^\n]*)\n") do
    local slug = line:match('^%s*%-%s*slug:%s*"?([%w%-]+)"?')
    if slug then slugs[slug] = true end
  end
  return slugs
end

-- Sorted list of example basenames that lack a slug and are not excluded.
-- `example_names` are file names with the `.typ` extension.
function M.orphans(example_names, slugs, exclude)
  exclude = exclude or M.EXCLUDE
  local out = {}
  for _, name in ipairs(example_names) do
    local base = name:match("^(.+)%.typ$")
    if base and not slugs[base] and not exclude[base] then
      out[#out + 1] = base
    end
  end
  table.sort(out)
  return out
end

return M
