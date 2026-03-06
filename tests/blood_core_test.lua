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

local function read_file(path)
  local handle = io.open(path, "r")
  local data
  if not handle then
    return nil
  end
  data = handle:read("*a")
  handle:close()
  return data
end

local function legacy_table_getn(tbl)
  local n
  local i

  if type(tbl) ~= "table" then
    return 0
  end

  n = rawget(tbl, "n")
  if type(n) == "number" then
    return n
  end

  i = 0
  while rawget(tbl, i + 1) ~= nil do
    i = i + 1
  end
  return i
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
  frame._visible = true

  function frame:RegisterEvent()
  end

  function frame:SetScript(name, fn)
    self._scripts[name] = fn
  end

  function frame:GetScript(name)
    return self._scripts[name]
  end

  function frame:Hide()
    local on_hide = self._scripts["OnHide"]
    self._visible = false
    if type(on_hide) == "function" then
      on_hide(self)
    end
  end

  function frame:Show()
    local was_visible = self._visible
    local on_show = self._scripts["OnShow"]
    self._visible = true
    if not was_visible and type(on_show) == "function" then
      on_show(self)
    end
  end

  function frame:SetSize()
  end

  function frame:SetWidth()
  end

  function frame:SetHeight()
  end

  function frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    self._lastPoint = { point, relativeTo, relativePoint, xOfs, yOfs }
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
    return self._visible
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
Minimap = create_frame()
function Minimap:GetWidth()
  return 140
end
function Minimap:GetHeight()
  return 140
end

local minimap_zoom = 2
function Minimap:GetZoom()
  return minimap_zoom
end
function Minimap:SetZoom(zoom)
  minimap_zoom = zoom
end

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

local map_context_by_name = {
  ["Durotar"] = { continent = 1, zone = 1 },
  ["Eastern Plaguelands"] = { continent = 2, zone = 1 },
  ["Western Plaguelands"] = { continent = 2, zone = 2 }
}

local map_name_by_context = {
  ["1:1"] = "Durotar",
  ["2:1"] = "Eastern Plaguelands",
  ["2:2"] = "Western Plaguelands"
}

local player_positions = {
  ["Durotar"] = { x = 0.50, y = 0.50 },
  ["Eastern Plaguelands"] = { x = 0.359, y = 0.574 },
  ["Western Plaguelands"] = { x = 0.071, y = 0.507 }
}

local player_zone_name = "Eastern Plaguelands"
local browsed_map_name = "Eastern Plaguelands"
local original_table_getn = table.getn

local function context_key(continent, zone)
  return tostring(continent) .. ":" .. tostring(zone)
end

local function set_current_map(name)
  if map_context_by_name[name] then
    browsed_map_name = name
  end
end

local function set_player_zone(name)
  if map_context_by_name[name] then
    player_zone_name = name
  end
end

SetMapToCurrentZone = function()
  browsed_map_name = player_zone_name
end

GetCurrentMapContinent = function()
  return map_context_by_name[browsed_map_name].continent
end

GetCurrentMapZone = function()
  return map_context_by_name[browsed_map_name].zone
end

SetMapZoom = function(continent, zone)
  local name = map_name_by_context[context_key(continent, zone)]
  if name then
    browsed_map_name = name
  end
end

GetMapInfo = function()
  return browsed_map_name
end

GetPlayerMapPosition = function(unit)
  local pos

  if unit ~= "player" then
    return 0, 0
  end

  if browsed_map_name ~= player_zone_name then
    return 0, 0
  end

  pos = player_positions[player_zone_name]
  if not pos then
    return 0, 0
  end

  return pos.x, pos.y
end

local blood_chunk, blood_load_error = loadfile(resolve_blood_lua_path())
table.getn = legacy_table_getn
assert_eq(type(blood_chunk), "function", blood_load_error or "loads Blood.lua chunk")
blood_chunk("BloodOfHeroes", {})
local blood_source = read_file(resolve_blood_lua_path()) or ""
assert_eq(string.find(blood_source, "return #tbl", 1, true), nil, "avoid Lua 5.0-incompatible # operator")

local on_event = BoH and BoH.frame and BoH.frame._scripts and BoH.frame._scripts["OnEvent"]
assert_eq(type(on_event), "function", "event handler wired")
set_player_zone("Eastern Plaguelands")
set_current_map("Eastern Plaguelands")
WorldMapFrame:Hide()
on_event(BoH.frame, "PLAYER_ENTERING_WORLD")
assert_eq(created_world_pin_frames, 0, "no world pins while map hidden")
WorldMapFrame:Show()
assert_eq(created_world_pin_frames > 0, true, "world pins render when map is opened")
on_event(BoH.frame, "WORLD_MAP_UPDATE")
local first_refresh_pin_count = created_world_pin_frames
assert_eq(first_refresh_pin_count > 0, true, "creates world map pins on refresh")
on_event(BoH.frame, "WORLD_MAP_UPDATE")
assert_eq(created_world_pin_frames, first_refresh_pin_count, "reuses world map pin frames across refreshes")

local slash_blood = SlashCmdList and SlashCmdList["BLOOD"]
assert_eq(type(slash_blood), "function", "slash command wired")
assert_eq(BoH.rangeOverrideYards, nil, "range override starts unset")
slash_blood("range 175")
assert_eq(BoH.rangeOverrideYards, 175, "range override set")
slash_blood("range reset")
assert_eq(BoH.rangeOverrideYards, nil, "range override reset")

on_event(BoH.frame, "PLAYER_ENTERING_WORLD")
assert_eq(type(BoH.frame._scripts["OnUpdate"]), "function", "minimap loop enabled in EPL")
set_current_map("Durotar")
BoH.frame._scripts["OnUpdate"](BoH.frame, 0.25)
assert_eq(GetMapInfo(), "Durotar", "minimap update restores browsed map")
assert_eq((table.getn and table.getn(BoH.minimapPins) or #BoH.minimapPins) > 0, true, "minimap nearby pins while browsing other map")
local first_pin = BoH.minimapPins[1]
local first_pin_x = first_pin and first_pin._lastPoint and first_pin._lastPoint[4]
local first_pin_y = first_pin and first_pin._lastPoint and first_pin._lastPoint[5]
assert_eq(first_pin ~= nil, true, "minimap pin exists before movement")
player_positions["Eastern Plaguelands"] = { x = 0.369, y = 0.584 }
BoH.frame._scripts["OnUpdate"](BoH.frame, 0.25)
local moved_pin = BoH.minimapPins[1]
local moved_pin_x = moved_pin and moved_pin._lastPoint and moved_pin._lastPoint[4]
local moved_pin_y = moved_pin and moved_pin._lastPoint and moved_pin._lastPoint[5]
assert_eq((moved_pin_x ~= first_pin_x) or (moved_pin_y ~= first_pin_y), true, "minimap pins update while enabled")
BoH.minimapPinPool.n = 1
BoH.minimapPinPool[1] = nil
local stale_len_ok = pcall(function()
  BoH.frame._scripts["OnUpdate"](BoH.frame, 0.25)
end)
assert_eq(stale_len_ok, true, "minimap update tolerates stale pool length metadata")

slash_blood("toggle")
assert_eq(BoH.enabled, false, "toggle disables")
assert_eq(BoH.frame._scripts["OnUpdate"], nil, "toggle disables minimap loop")
slash_blood("toggle")
assert_eq(BoH.enabled, true, "toggle enables")
assert_eq(type(BoH.frame._scripts["OnUpdate"]), "function", "toggle re-enables minimap loop")

set_player_zone("Durotar")
on_event(BoH.frame, "ZONE_CHANGED_NEW_AREA")
assert_eq(BoH.frame._scripts["OnUpdate"], nil, "minimap loop disabled outside EPL/WPL")
set_player_zone("Western Plaguelands")
on_event(BoH.frame, "ZONE_CHANGED_NEW_AREA")
assert_eq(type(BoH.frame._scripts["OnUpdate"]), "function", "minimap loop enabled in WPL")

assert_eq(core.GetEffectiveRangeYards(2, nil), core.GetZoomRangeYards(2), "uses zoom range by default")
assert_eq(core.GetEffectiveRangeYards(2, 180), 180, "uses override when present")
assert_eq(core.InterfaceVersionTarget, 11200, "interface version target")
assert_eq(core.ParseRangeCommand("range 175"), 175, "range parser number")
assert_eq(core.ParseRangeCommand("range reset"), false, "range parser reset")
assert_eq(core.ParseRangeCommand("range"), nil, "range parser invalid")
assert_eq(core.IsNearby(0.50, 0.50, 0.51, 0.50, 1000, 1000, 20), true, "near node")
assert_eq(core.IsNearby(0.50, 0.50, 0.90, 0.90, 1000, 1000, 20), false, "far node")

assert_eq(core.NormalizeZoneName("Eastern Plaguelands"), "EasternPlaguelands", "normalize epl")
assert_eq(core.NormalizeZoneName("Western Plaguelands"), "WesternPlaguelands", "normalize wpl")
assert_eq(core.NormalizeZoneName("Durotar"), nil, "normalize other")
assert_eq(core.GetZoomRangeYards(0) > core.GetZoomRangeYards(5), true, "zoom range ordering")
assert_eq(type(BLOOD_OF_HEROES_DATA and BLOOD_OF_HEROES_DATA.EasternPlaguelands), "table", "epl data table exists")
assert_eq(type(BLOOD_OF_HEROES_DATA and BLOOD_OF_HEROES_DATA.WesternPlaguelands), "table", "wpl data table exists")

table.getn = original_table_getn

print("blood_core_test.lua: PASS")
