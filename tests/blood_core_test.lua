local core = dofile("BoH_Core.lua")

local function assert_eq(actual, expected, msg)
  if actual ~= expected then
    error((msg or "assert_eq failed") .. ": got=" .. tostring(actual) .. " expected=" .. tostring(expected), 2)
  end
end

local function noop()
end

local function create_texture()
  return {
    SetAllPoints = noop,
    SetTexture = function()
      return true
    end
  }
end

local function create_frame()
  local frame = {}

  function frame:RegisterEvent()
  end

  function frame:SetScript()
  end

  function frame:Hide()
  end

  function frame:Show()
  end

  function frame:SetSize()
  end

  function frame:SetWidth()
  end

  function frame:SetHeight()
  end

  function frame:SetPoint()
  end

  function frame:SetAlpha()
  end

  function frame:SetScale()
  end

  function frame:GetSize()
    return 1024, 768
  end

  function frame:GetWidth()
    return 1024
  end

  function frame:GetHeight()
    return 768
  end

  function frame:IsVisible()
    return true
  end

  function frame:CreateTexture()
    return create_texture()
  end

  return frame
end

WorldMapFrame = create_frame()
WorldMapFrame.ScrollContainer = create_frame()
function WorldMapFrame:GetMapID()
  return 1422
end

WorldMapDetailFrame = create_frame()

CreateFrame = function()
  return create_frame()
end

C_Map = {
  GetBestMapForUnit = function()
    return 1422
  end
}

C_Timer = {
  After = function(_, callback)
    if type(callback) == "function" then
      callback()
    end
  end
}

hooksecurefunc = function(_, _, callback)
  if type(callback) == "function" then
    callback()
  end
end

wipe = function(tbl)
  for key in pairs(tbl) do
    tbl[key] = nil
  end
end

SlashCmdList = {}

SetMapToCurrentZone = noop
GetMapInfo = function()
  return "Eastern Plaguelands"
end

assert(loadfile("Blood.lua"))("BloodOfHeroes", {})

assert_eq(core.GetEffectiveRangeYards(2, nil), core.GetZoomRangeYards(2), "uses zoom range by default")
assert_eq(core.GetEffectiveRangeYards(2, 180), 180, "uses override when present")
assert_eq(core.IsNearby(0.50, 0.50, 0.51, 0.50, 1000, 1000, 20), true, "near node")
assert_eq(core.IsNearby(0.50, 0.50, 0.90, 0.90, 1000, 1000, 20), false, "far node")

assert_eq(core.NormalizeZoneName("Eastern Plaguelands"), "EasternPlaguelands", "normalize epl")
assert_eq(core.NormalizeZoneName("Western Plaguelands"), "WesternPlaguelands", "normalize wpl")
assert_eq(core.NormalizeZoneName("Durotar"), nil, "normalize other")
assert_eq(core.GetZoomRangeYards(0) > core.GetZoomRangeYards(5), true, "zoom range ordering")
assert_eq(type(BLOOD_OF_HEROES_DATA and BLOOD_OF_HEROES_DATA.EasternPlaguelands), "table", "epl data table exists")
assert_eq(type(BLOOD_OF_HEROES_DATA and BLOOD_OF_HEROES_DATA.WesternPlaguelands), "table", "wpl data table exists")

print("blood_core_test.lua: PASS")
