local M = {}

local function log(prefix, msg)
  io.stderr:write("typstdoc: " .. prefix .. msg .. "\n")
end

function M.log_info(msg) log("", msg) end
function M.log_warn(msg) log("warning: ", msg) end
function M.log_err(msg) log("error: ", msg) end

function M.die(msg)
  error("typstdoc: " .. msg, 0)
end

function M.read_file(path)
  local f, err = io.open(path, "rb")
  if not f then return nil, err end
  local content = f:read("*a")
  f:close()
  return content
end

function M.write_file(path, content)
  local dir = path:match("^(.*)/[^/]+$")
  if dir and dir ~= "" then
    os.execute(string.format("mkdir -p %q", dir))
  end
  local f, err = io.open(path, "wb")
  if not f then return nil, err end
  f:write(content)
  f:close()
  return true
end

function M.file_exists(path)
  local f = io.open(path, "rb")
  if f then f:close(); return true end
  return false
end

function M.dir_exists(path)
  local handle = io.popen(string.format("test -d %q && echo yes 2>/dev/null", path))
  if not handle then return false end
  local out = handle:read("*a")
  handle:close()
  return out:match("yes") ~= nil
end

function M.remove_file(path)
  os.execute(string.format("rm -f %q", path))
end

function M.remove_dir(path)
  os.execute(string.format("rm -rf %q", path))
end

function M.remove_generated_files(path, pattern)
  os.execute(string.format("find %q -type f -name %q -delete 2>/dev/null", path, pattern))
  os.execute(string.format("find %q -mindepth 1 -type d -empty -delete 2>/dev/null", path))
end

function M.make_dir(path)
  os.execute(string.format("mkdir -p %q", path))
end

local function popen_lines(cmd)
  local handle = io.popen(cmd)
  if not handle then M.die("could not run: " .. cmd) end
  local out = handle:read("*a")
  handle:close()
  return out
end

function M.find_typ_files(root)
  local out = popen_lines(string.format("find %q -name '*.typ' -type f 2>/dev/null", root))
  local files = {}
  for line in out:gmatch("[^\n]+") do files[#files + 1] = line end
  table.sort(files)
  return files
end

function M.list_dir_files(dir)
  local out = popen_lines(string.format("find %q -maxdepth 1 -type f 2>/dev/null", dir))
  local names = {}
  for path in out:gmatch("[^\n]+") do
    local name = path:match("([^/]+)$")
    if name and not name:match("^%.") then names[#names + 1] = name end
  end
  table.sort(names)
  return names
end

function M.git_tracked_in(root, subdir)
  local out = popen_lines(string.format(
    "git -C %q ls-files -z --cached --full-name -- %q 2>/dev/null", root, subdir))
  local names = {}
  local prefix = subdir .. "/"
  for path in out:gmatch("[^%z]+") do
    if path:sub(1, #prefix) == prefix then
      local rest = path:sub(#prefix + 1)
      if not rest:find("/", 1, true) then names[#names + 1] = rest end
    end
  end
  table.sort(names)
  return names
end

function M.split_lines(text)
  local lines = {}
  local start = 1
  local len = #text
  while start <= len do
    local nl = text:find("\n", start, true)
    if nl then
      lines[#lines + 1] = text:sub(start, nl - 1)
      start = nl + 1
    else
      lines[#lines + 1] = text:sub(start)
      break
    end
  end
  if text:sub(-1) == "\n" then lines[#lines + 1] = "" end
  return lines
end

function M.trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.slugify(s)
  return (s:lower():gsub("[^%w]+", "-"):gsub("^%-", ""):gsub("%-$", ""))
end

return M
