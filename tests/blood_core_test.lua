local core = dofile("BoH_Core.lua")

local function assert_eq(actual, expected, msg)
  if actual ~= expected then
    error((msg or "assert_eq failed") .. ": got=" .. tostring(actual) .. " expected=" .. tostring(expected), 2)
  end
end

assert_eq(core.NormalizeZoneName("Eastern Plaguelands"), "EasternPlaguelands", "normalize epl")
assert_eq(core.NormalizeZoneName("Western Plaguelands"), "WesternPlaguelands", "normalize wpl")
assert_eq(core.NormalizeZoneName("Durotar"), nil, "normalize other")
assert_eq(core.GetZoomRangeYards(0) > core.GetZoomRangeYards(5), true, "zoom range ordering")

print("blood_core_test.lua: PASS")
