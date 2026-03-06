local function dirname(path)
  local dir = string.match(path or "", "^(.*[/\\])")
  if not dir or dir == "" then
    return "."
  end
  if string.sub(dir, -1) == "/" or string.sub(dir, -1) == "\\" then
    return string.sub(dir, 1, -2)
  end
  return dir
end

local function join_path(base, leaf)
  if base == "." or base == "" then
    return leaf
  end
  if string.sub(base, -1) == "/" or string.sub(base, -1) == "\\" then
    return base .. leaf
  end
  return base .. "/" .. leaf
end

local function file_exists(path)
  local handle = io.open(path, "r")
  if handle then
    handle:close()
    return true
  end
  return false
end

local function is_absolute_path(path)
  if string.sub(path, 1, 1) == "/" then
    return true
  end
  if string.match(path, "^[A-Za-z]:[/\\]") then
    return true
  end
  return false
end

local script_dir = "."
if type(arg) == "table" and arg[0] then
  script_dir = dirname(arg[0])
end

local project_root = "."
if not file_exists("BoH_Core.lua") then
  if file_exists("../BoH_Core.lua") then
    project_root = ".."
  elseif file_exists(join_path(script_dir, "../BoH_Core.lua")) then
    project_root = join_path(script_dir, "..")
  end
end

local tests = {
  "blood_core_test.lua"
}

local failures = 0

local function run_test(path)
  local original_dofile = dofile
  dofile = function(file)
    if type(file) == "string" and not is_absolute_path(file) then
      local candidate = join_path(project_root, file)
      if file_exists(candidate) then
        return original_dofile(candidate)
      end
    end
    return original_dofile(file)
  end

  local ok, err = pcall(original_dofile, path)
  dofile = original_dofile

  if ok then
    print("PASS " .. path)
    return
  end

  failures = failures + 1
  io.stderr:write("FAIL " .. path .. "\n")
  io.stderr:write(tostring(err) .. "\n")
end

for _, path in ipairs(tests) do
  run_test(join_path(script_dir, path))
end

if failures > 0 then
  os.exit(1)
end

print("All tests passed.")
