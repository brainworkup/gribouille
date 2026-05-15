local util = require("util")

local M = {}

local function find_block(content)
  local marker_start, marker_end = content:find("#let%s+_STAT%-INFO%s*=%s*%(", 1, false)
  if not marker_start then return nil end
  local open = marker_end
  local depth = 1
  local i = open + 1
  while i <= #content do
    local c = content:sub(i, i)
    if c == "(" then
      depth = depth + 1
    elseif c == ")" then
      depth = depth - 1
      if depth == 0 then
        return content:sub(open + 1, i - 1)
      end
    end
    i = i + 1
  end
  return nil
end

function M.load(repo_root)
  local path = repo_root .. "/src/stat/info.typ"
  local content, err = util.read_file(path)
  if not content then
    util.log_warn("could not read " .. path .. ": " .. tostring(err))
    return {}
  end

  local body = find_block(content)
  if not body then
    util.log_warn(path .. ": could not locate `_STAT-INFO` block")
    return {}
  end

  local info = {}
  local pattern = '"?([%w_%-]+)"?%s*:%s*%(%s*outputs:%s*%(([^)]*)%)%s*,?%s*%)'
  for key, outputs_body in body:gmatch(pattern) do
    local outputs = {}
    for s in outputs_body:gmatch('"([^"]*)"') do
      outputs[#outputs + 1] = s
    end
    info[key] = { outputs = outputs }
  end

  return info
end

return M
