local tests = {
  "tests/blood_core_test.lua"
}

local failures = 0

local function run_test(path)
  local ok, err = pcall(dofile, path)
  if ok then
    print("PASS " .. path)
    return
  end

  failures = failures + 1
  io.stderr:write("FAIL " .. path .. "\n")
  io.stderr:write(tostring(err) .. "\n")
end

for _, path in ipairs(tests) do
  run_test(path)
end

if failures > 0 then
  os.exit(1)
end

print("All tests passed.")
