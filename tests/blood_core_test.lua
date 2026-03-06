local core = dofile("BoH_Core.lua")

local function assert_eq(actual, expected, msg)
  if actual ~= expected then
    error((msg or "assert_eq failed") .. ": got=" .. tostring(actual) .. " expected=" .. tostring(expected), 2)
  end
end

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

local function resolve_blood_lua_path()
  local candidates = {
    "Blood.lua",
    "../Blood.lua"
  }
  local script_dir = "."
  local i
  local candidate

  if type(arg) == "table" and arg[0] then
    script_dir = dirname(arg[0])
    table.insert(candidates, join_path(script_dir, "Blood.lua"))
    table.insert(candidates, join_path(script_dir, "../Blood.lua"))
  end

  for i = 1, #candidates do
    candidate = candidates[i]
    if file_exists(candidate) then
      return candidate
    end
  end

  return "Blood.lua"
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
  frame._scripts = {}

  function frame:RegisterEvent()
  end

  function frame:SetScript(name, fn)
    self._scripts[name] = fn
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

  function frame:ClearAllPoints()
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

local created_world_pin_frames = 0

CreateFrame = function(_, _, parent)
  local frame = create_frame()
  if parent == WorldMapDetailFrame then
    created_world_pin_frames = created_world_pin_frames + 1
  end
  return frame
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

local blood_chunk, blood_load_error = loadfile(resolve_blood_lua_path())
assert_eq(type(blood_chunk), "function", blood_load_error or "loads Blood.lua chunk")
blood_chunk("BloodOfHeroes", {})

local on_event = BoH and BoH.frame and BoH.frame._scripts and BoH.frame._scripts["OnEvent"]
assert_eq(type(on_event), "function", "event handler wired")
on_event(BoH.frame, "WORLD_MAP_UPDATE")
local first_refresh_pin_count = created_world_pin_frames
assert_eq(first_refresh_pin_count > 0, true, "creates world map pins on refresh")
on_event(BoH.frame, "WORLD_MAP_UPDATE")
assert_eq(created_world_pin_frames, first_refresh_pin_count, "reuses world map pin frames across refreshes")

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
