local util = require("util")

local M = {}

function M.load(repo_root)
  local path = repo_root .. "/src/stat/info.typ"
  local content, err = util.read_file(path)
  if not content then
    util.log_warn("could not read " .. path .. ": " .. tostring(err))
    return {}
  end

  local body = util.find_balanced_block(content, "#let%s+_STAT%-INFO%s*=%s*")
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
    local entry = { outputs = outputs }
    info[key] = entry
    info[(key:gsub("_", "-"))] = entry
  end

  if next(info) == nil then
    util.log_warn(path .. ": parsed zero entries from `_STAT-INFO`")
  end

  return info
end

return M
