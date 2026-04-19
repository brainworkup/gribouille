-- Transform CHANGELOG.md into docs/changelog.qmd: strip the document title,
-- promote each `## X.Y.Z (date)` into a three-level hierarchy (major / minor /
-- patch), push any sub-headings down accordingly, and wrap the "Unreleased"
-- section in a dev-profile content block so it only appears in draft builds.

local util = require("util")

local M = {}

local FRONT_MATTER = [[
---
title: "Changelog"
subtitle: "Version history."
toc: true
toc-depth: 2
---
]]

local FOOTER = [[
---

Looking for a specific change?
Browse the [full commit history](https://github.com/mcanouil/gribouille/commits/main) or the [list of releases](https://github.com/mcanouil/gribouille/releases) on GitHub.
]]

local UNRELEASED_OPEN = '::: {.content-visible when-profile="dev"}'
local UNRELEASED_CLOSE = ":::"

local function match_version(line)
  local major, minor, patch, date = line:match("^## (%d+)%.(%d+)%.(%d+)%s*(%(.-%))%s*$")
  if major then return major, minor, patch, date end
  major, minor, patch = line:match("^## (%d+)%.(%d+)%.(%d+)%s*$")
  return major, minor, patch, nil
end

local function transform(source)
  local out = {}
  local current_major, current_minor
  local in_version = false
  local in_unreleased = false

  local function push(line) out[#out + 1] = line end

  local function close_unreleased()
    if in_unreleased then
      push(UNRELEASED_CLOSE)
      push("")
      in_unreleased = false
    end
  end

  local lines = util.split_lines(source)
  if lines[#lines] == "" then lines[#lines] = nil end

  for i, line in ipairs(lines) do
    if i == 1 and line == "# Changelog" then
      -- skip document title.
    elseif line == "## Unreleased" then
      close_unreleased()
      push(UNRELEASED_OPEN)
      push("## Unreleased {#unreleased}")
      push("")
      in_unreleased = true
      current_major, current_minor = nil, nil
      in_version = false
    else
      local major, minor, patch, date = match_version(line)
      if major then
        close_unreleased()
        local minor_key = major .. "." .. minor
        if current_major ~= major then
          push("## " .. major .. " {#version-" .. major .. "}")
          push("")
          current_major = major
          current_minor = nil
        end
        if current_minor ~= minor_key then
          push("### " .. minor_key .. " {#version-" .. major .. "-" .. minor .. "}")
          push("")
          current_minor = minor_key
        end
        local heading = "#### " .. major .. "." .. minor .. "." .. patch
        if date and date ~= "" then heading = heading .. " " .. date end
        heading = heading .. " {#version-" .. major .. "-" .. minor .. "-" .. patch .. "}"
        push(heading)
        in_version = true
      elseif in_version and line:sub(1, 4) == "### " then
        push("##### " .. line:sub(5))
      elseif in_version and line:sub(1, 5) == "#### " then
        push("###### " .. line:sub(6))
      else
        push(line)
      end
    end
  end

  close_unreleased()

  local normalised = {}
  for _, l in ipairs(out) do
    if not (l == "" and normalised[#normalised] == "") then
      normalised[#normalised + 1] = l
    end
  end
  while normalised[1] == "" do table.remove(normalised, 1) end
  while normalised[#normalised] == "" do normalised[#normalised] = nil end
  if #normalised == 0 then return "" end
  return table.concat(normalised, "\n") .. "\n"
end

function M.run(opts)
  if not util.file_exists(opts.input) then
    util.log_info(string.format("%s not present, skipping changelog", opts.input))
    return { skipped_entirely = true }
  end
  local source = util.read_file(opts.input) or util.die("cannot read " .. opts.input)
  local body = transform(source)
  if opts.check then return { checked = true } end
  local content = (body == "")
    and (FRONT_MATTER .. "\n" .. FOOTER)
    or (FRONT_MATTER .. "\n" .. body .. "\n" .. FOOTER)
  util.write_file(opts.output, content)
  return { written = opts.output }
end

return M
