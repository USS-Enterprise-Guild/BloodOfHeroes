local core = dofile("BoH_Core.lua")

local function assert_eq(actual, expected, msg)
  if actual ~= expected then
    error((msg or "assert_eq failed") .. ": got=" .. tostring(actual) .. " expected=" .. tostring(expected), 2)
  end
end

assert_eq(core.GetEffectiveRangeYards(2, nil), core.GetZoomRangeYards(2), "uses zoom range by default")
assert_eq(core.GetEffectiveRangeYards(2, 180), 180, "uses override when present")
assert_eq(core.IsNearby(0.50, 0.50, 0.51, 0.50, 1000, 1000, 20), true, "near node")
assert_eq(core.IsNearby(0.50, 0.50, 0.90, 0.90, 1000, 1000, 20), false, "far node")

assert_eq(core.NormalizeZoneName("Eastern Plaguelands"), "EasternPlaguelands", "normalize epl")
assert_eq(core.NormalizeZoneName("Western Plaguelands"), "WesternPlaguelands", "normalize wpl")
assert_eq(core.NormalizeZoneName("Durotar"), nil, "normalize other")
assert_eq(core.GetZoomRangeYards(0) > core.GetZoomRangeYards(5), true, "zoom range ordering")

print("blood_core_test.lua: PASS")
