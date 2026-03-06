-- Blood of Heroes Locator Addon for WoW 1.12.1
-- World map pins for Eastern/Western Plaguelands only.

local core = BoH_Core or {}

BoH = BoH or {}
BoH.worldPins = BoH.worldPins or {}
BoH.worldPinPool = BoH.worldPinPool or {}
BoH.minimapPins = BoH.minimapPins or {}
BoH.minimapPinPool = BoH.minimapPinPool or {}
if BoH.enabled == nil then
  BoH.enabled = true
end
if BoH.minimapElapsed == nil then
  BoH.minimapElapsed = 0
end

local getn = table.getn or function(tbl)
  return #tbl
end

local MINIMAP_UPDATE_INTERVAL = 0.2
local ZONE_DIMENSIONS_YARDS = {
  EasternPlaguelands = { width = 4032, height = 2688 },
  WesternPlaguelands = { width = 4295, height = 2863 }
}

BLOOD_OF_HEROES_DATA = {
  EasternPlaguelands = {
    {x = 35.9, y = 57.4},
    {x = 36.4, y = 53.6},
    {x = 38.3, y = 56.4},
    {x = 39.7, y = 69.4},
    {x = 39.7, y = 69.6},
    {x = 40.6, y = 73.1},
    {x = 40.7, y = 57.4},
    {x = 40.7, y = 57.6},
    {x = 41.4, y = 62.1},
    {x = 41.5, y = 62.1},
    {x = 42.2, y = 54.8},
    {x = 42.8, y = 64.2},
    {x = 43.3, y = 68.3},
    {x = 43.6, y = 70.4},
    {x = 43.7, y = 70.5},
    {x = 44.2, y = 65.0},
    {x = 44.4, y = 71.6},
    {x = 44.5, y = 53.3},
    {x = 44.5, y = 71.7},
    {x = 44.6, y = 53.5},
    {x = 45.8, y = 51.0},
    {x = 45.8, y = 71.5},
    {x = 45.9, y = 71.4},
    {x = 46.7, y = 34.4},
    {x = 46.8, y = 34.5},
    {x = 46.9, y = 67.2},
    {x = 47.0, y = 59.9},
    {x = 47.6, y = 70.0},
    {x = 47.9, y = 53.1},
    {x = 49.4, y = 68.1},
    {x = 49.8, y = 33.3},
    {x = 52.2, y = 66.5},
    {x = 52.3, y = 66.3},
    {x = 52.4, y = 55.0},
    {x = 53.0, y = 64.2},
    {x = 53.3, y = 65.1},
    {x = 53.3, y = 66.2},
    {x = 53.4, y = 63.4},
    {x = 53.5, y = 63.4},
    {x = 53.5, y = 63.5},
    {x = 54.9, y = 27.1},
    {x = 55.3, y = 69.6},
    {x = 56.7, y = 34.7},
    {x = 57.8, y = 66.4},
    {x = 62.0, y = 58.3},
    {x = 62.0, y = 58.5},
    {x = 62.9, y = 57.2},
    {x = 62.9, y = 57.9},
    {x = 63.3, y = 59.2},
    {x = 63.6, y = 75.4},
    {x = 63.6, y = 75.5},
    {x = 64.0, y = 48.7},
    {x = 64.1, y = 57.9},
    {x = 64.9, y = 74.5},
    {x = 65.0, y = 74.4},
    {x = 65.8, y = 76.8},
    {x = 66.5, y = 42.2},
    {x = 67.0, y = 53.8},
    {x = 67.8, y = 84.6},
    {x = 68.0, y = 44.7},
    {x = 68.3, y = 81.4},
    {x = 68.3, y = 81.6},
    {x = 68.4, y = 77.1},
    {x = 68.5, y = 77.1},
    {x = 68.7, y = 49.2},
    {x = 68.7, y = 79.2},
    {x = 68.9, y = 73.8},
    {x = 69.5, y = 78.6},
  },
  WesternPlaguelands = {
    {x = 7.1, y = 50.7},
    {x = 8.0, y = 54.5},
    {x = 8.1, y = 54.4},
    {x = 14.2, y = 64.7},
    {x = 20.0, y = 60.9},
    {x = 20.5, y = 66.9},
    {x = 21.5, y = 73.9},
    {x = 22.1, y = 85.0},
    {x = 24.3, y = 88.2},
    {x = 26.0, y = 74.7},
    {x = 26.3, y = 70.4},
    {x = 26.3, y = 70.5},
    {x = 26.7, y = 69.4},
    {x = 26.7, y = 69.5},
    {x = 27.0, y = 75.4},
    {x = 27.1, y = 75.5},
    {x = 27.3, y = 64.0},
    {x = 28.8, y = 85.9},
    {x = 29.2, y = 78.8},
    {x = 30.9, y = 65.5},
    {x = 32.0, y = 71.0},
    {x = 33.6, y = 32.6},
    {x = 34.0, y = 80.2},
    {x = 34.3, y = 67.8},
    {x = 34.4, y = 25.9},
    {x = 34.5, y = 25.8},
    {x = 34.5, y = 76.9},
    {x = 35.6, y = 73.3},
    {x = 35.9, y = 75.8},
    {x = 36.7, y = 38.1},
    {x = 36.9, y = 70.6},
    {x = 37.1, y = 65.7},
    {x = 37.6, y = 68.4},
    {x = 38.4, y = 31.1},
    {x = 38.5, y = 31.1},
    {x = 38.5, y = 54.0},
    {x = 38.8, y = 26.7},
    {x = 38.9, y = 36.1},
    {x = 40.0, y = 49.7},
    {x = 41.4, y = 65.7},
    {x = 41.4, y = 79.7},
    {x = 41.5, y = 79.7},
    {x = 42.3, y = 75.7},
    {x = 44.9, y = 32.9},
    {x = 46.2, y = 70.8},
    {x = 46.3, y = 64.0},
    {x = 46.5, y = 74.8},
    {x = 47.5, y = 40.8},
    {x = 47.9, y = 80.0},
    {x = 48.9, y = 67.2},
    {x = 49.1, y = 35.2},
    {x = 50.2, y = 45.5},
    {x = 50.3, y = 45.4},
    {x = 50.4, y = 77.4},
    {x = 50.5, y = 77.3},
    {x = 51.8, y = 70.3},
    {x = 53.4, y = 50.6},
    {x = 53.5, y = 50.8},
    {x = 55.3, y = 58.7},
    {x = 55.5, y = 58.7},
    {x = 56.2, y = 63.8},
    {x = 56.5, y = 76.1},
    {x = 57.0, y = 82.0},
    {x = 57.4, y = 71.9},
    {x = 57.5, y = 72.0},
    {x = 57.8, y = 76.2},
    {x = 58.1, y = 79.6},
    {x = 58.4, y = 64.8},
    {x = 58.5, y = 79.4},
    {x = 58.6, y = 79.6},
    {x = 59.2, y = 80.8},
    {x = 59.3, y = 62.2},
    {x = 59.3, y = 76.0},
    {x = 59.5, y = 76.0},
    {x = 59.9, y = 67.4},
    {x = 59.9, y = 67.5},
    {x = 61.8, y = 70.2},
    {x = 63.6, y = 67.7},
    {x = 64.7, y = 65.4},
    {x = 64.7, y = 81.0},
    {x = 66.1, y = 53.1},
    {x = 67.6, y = 66.8},
    {x = 68.2, y = 70.4},
    {x = 68.2, y = 70.6},
    {x = 68.2, y = 74.4},
    {x = 68.3, y = 74.6},
    {x = 68.6, y = 78.4},
    {x = 68.8, y = 80.6},
    {x = 68.9, y = 83.3},
    {x = 69.0, y = 71.4},
    {x = 69.0, y = 71.5},
    {x = 70.7, y = 69.4},
    {x = 70.7, y = 69.5},
    {x = 70.7, y = 80.8},
    {x = 71.1, y = 75.3},
    {x = 72.2, y = 78.4},
    {x = 72.3, y = 78.5},
    {x = 73.3, y = 70.1},
    {x = 73.3, y = 77.2},
    {x = 73.4, y = 82.1},
    {x = 73.6, y = 76.8},
    {x = 73.8, y = 51.1},
    {x = 74.1, y = 83.8},
    {x = 74.7, y = 58.7},
    {x = 75.6, y = 55.3},
    {x = 75.8, y = 83.3},
    {x = 75.8, y = 83.5},
    {x = 76.1, y = 78.2},
    {x = 76.2, y = 50.4},
    {x = 76.2, y = 50.7},
    {x = 76.6, y = 72.5},
    {x = 78.4, y = 57.4},
    {x = 78.4, y = 57.5},
    {x = 78.5, y = 57.4},
    {x = 78.5, y = 57.5},
    {x = 78.7, y = 67.4},
    {x = 78.9, y = 63.4},
    {x = 79.0, y = 63.5},
    {x = 80.4, y = 59.7},
    {x = 80.5, y = 59.6},
  }
}

BoH.data = BLOOD_OF_HEROES_DATA

local function NormalizeZoneName(name)
  if name == "Eastern Plaguelands" or name == "EasternPlaguelands" then
    return "EasternPlaguelands"
  end
  if name == "Western Plaguelands" or name == "WesternPlaguelands" then
    return "WesternPlaguelands"
  end
  return nil
end

local function ClearArray(array)
  local i
  for i = getn(array), 1, -1 do
    array[i] = nil
  end
end

local function AcquireWorldPin()
  local poolSize
  local pin
  local hasCustomTexture

  poolSize = getn(BoH.worldPinPool)
  if poolSize > 0 then
    pin = BoH.worldPinPool[poolSize]
    BoH.worldPinPool[poolSize] = nil
    return pin
  end

  pin = CreateFrame("Frame", nil, WorldMapDetailFrame)
  pin:SetWidth(16)
  pin:SetHeight(16)

  pin.texture = pin:CreateTexture(nil, "OVERLAY")
  pin.texture:SetAllPoints(pin)

  hasCustomTexture = pin.texture:SetTexture("Interface\\AddOns\\BloodOfHeroes\\Media\\blood-of-heroes-marker.tga")
  if not hasCustomTexture then
    pin.texture:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
  end

  return pin
end

local function ReleaseWorldPin(pin)
  if not pin then
    return
  end

  if pin.ClearAllPoints then
    pin:ClearAllPoints()
  end
  pin:Hide()
  table.insert(BoH.worldPinPool, pin)
end

local function ClearWorldPins()
  local i
  local pin

  for i = 1, getn(BoH.worldPins) do
    pin = BoH.worldPins[i]
    ReleaseWorldPin(pin)
  end

  ClearArray(BoH.worldPins)
end

local function AcquireMinimapPin()
  local poolSize
  local pin
  local hasCustomTexture

  poolSize = getn(BoH.minimapPinPool)
  if poolSize > 0 then
    pin = BoH.minimapPinPool[poolSize]
    BoH.minimapPinPool[poolSize] = nil
    return pin
  end

  pin = CreateFrame("Frame", nil, Minimap)
  pin:SetWidth(10)
  pin:SetHeight(10)

  pin.texture = pin:CreateTexture(nil, "OVERLAY")
  pin.texture:SetAllPoints(pin)

  hasCustomTexture = pin.texture:SetTexture("Interface\\AddOns\\BloodOfHeroes\\Media\\blood-of-heroes-marker.tga")
  if not hasCustomTexture then
    pin.texture:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
  end

  return pin
end

local function ReleaseMinimapPin(pin)
  if not pin then
    return
  end

  if pin.ClearAllPoints then
    pin:ClearAllPoints()
  end
  pin:Hide()
  table.insert(BoH.minimapPinPool, pin)
end

local function ClearMinimapPins()
  local i
  local pin

  for i = 1, getn(BoH.minimapPins) do
    pin = BoH.minimapPins[i]
    ReleaseMinimapPin(pin)
  end

  ClearArray(BoH.minimapPins)
end

local function GetCurrentZoneKey()
  local mapName

  if type(GetMapInfo) ~= "function" then
    return nil
  end

  mapName = GetMapInfo()
  return NormalizeZoneName(mapName)
end

local function SaveMapContext()
  local continent
  local zone

  if type(GetCurrentMapContinent) ~= "function" or type(GetCurrentMapZone) ~= "function" then
    return nil, nil
  end

  continent = GetCurrentMapContinent()
  zone = GetCurrentMapZone()
  return continent, zone
end

local function RestoreMapContext(continent, zone)
  if continent == nil or zone == nil then
    return
  end

  if type(SetMapZoom) ~= "function" then
    return
  end

  SetMapZoom(continent, zone)
end

local function GetPlayerZoneContext()
  local previousContinent
  local previousZone
  local zoneKey
  local px
  local py

  if type(SetMapToCurrentZone) == "function" then
    previousContinent, previousZone = SaveMapContext()
    SetMapToCurrentZone()
  end

  zoneKey = GetCurrentZoneKey()
  if zoneKey and type(GetPlayerMapPosition) == "function" then
    px, py = GetPlayerMapPosition("player")
  end

  RestoreMapContext(previousContinent, previousZone)

  return zoneKey, px, py
end

local function AddWorldPins()
  local zoneKey
  local nodes
  local mapWidth
  local mapHeight
  local i
  local loc
  local pin

  ClearWorldPins()

  if not BoH.enabled then
    return
  end

  if not WorldMapFrame or not WorldMapDetailFrame then
    return
  end

  if WorldMapFrame.IsVisible and not WorldMapFrame:IsVisible() then
    return
  end

  zoneKey = GetCurrentZoneKey()
  if not zoneKey then
    return
  end

  nodes = BLOOD_OF_HEROES_DATA[zoneKey]
  if not nodes then
    return
  end

  mapWidth = WorldMapDetailFrame:GetWidth()
  mapHeight = WorldMapDetailFrame:GetHeight()
  if not mapWidth or mapWidth <= 0 or not mapHeight or mapHeight <= 0 then
    return
  end

  for i = 1, getn(nodes) do
    loc = nodes[i]
    pin = AcquireWorldPin()
    pin:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", (loc.x / 100) * mapWidth, (-loc.y / 100) * mapHeight)
    pin:Show()

    table.insert(BoH.worldPins, pin)
  end
end

local function RefreshMinimapPins()
  local zoneKey
  local nodes
  local zoneSize
  local px
  local py
  local zoom
  local maxYards
  local minimapWidth
  local minimapHeight
  local minimapRangeX
  local minimapRangeY
  local i
  local loc
  local nx
  local ny
  local dxYards
  local dyYards
  local pin

  ClearMinimapPins()

  if not BoH.enabled then
    return
  end

  if not Minimap or type(GetPlayerMapPosition) ~= "function" then
    return
  end

  if type(core.IsNearby) ~= "function" or type(core.GetEffectiveRangeYards) ~= "function" then
    return
  end

  zoneKey, px, py = GetPlayerZoneContext()
  if not zoneKey then
    return
  end

  nodes = BLOOD_OF_HEROES_DATA[zoneKey]
  zoneSize = ZONE_DIMENSIONS_YARDS[zoneKey]
  if not nodes or not zoneSize then
    return
  end

  if not px or not py or (px == 0 and py == 0) then
    return
  end

  zoom = 2
  if Minimap.GetZoom then
    zoom = Minimap:GetZoom() or 2
  end
  maxYards = core.GetEffectiveRangeYards(zoom, BoH.rangeOverrideYards)
  if not maxYards or maxYards <= 0 then
    return
  end

  minimapWidth = Minimap:GetWidth() or 140
  minimapHeight = Minimap:GetHeight() or 140
  if minimapWidth <= 0 then
    minimapWidth = 140
  end
  if minimapHeight <= 0 then
    minimapHeight = 140
  end
  minimapRangeX = minimapWidth / 2
  minimapRangeY = minimapHeight / 2

  for i = 1, getn(nodes) do
    loc = nodes[i]
    nx = loc.x / 100
    ny = loc.y / 100
    if core.IsNearby(px, py, nx, ny, zoneSize.width, zoneSize.height, maxYards) then
      dxYards = (nx - px) * zoneSize.width
      dyYards = (ny - py) * zoneSize.height

      pin = AcquireMinimapPin()
      pin:SetPoint("CENTER", Minimap, "CENTER", (dxYards / maxYards) * minimapRangeX, (-dyYards / maxYards) * minimapRangeY)
      pin:Show()

      table.insert(BoH.minimapPins, pin)
    end
  end
end

local function MinimapUpdatesEnabled()
  if not BoH.enabled then
    return false
  end
  if not Minimap then
    return false
  end
  if type(GetPlayerMapPosition) ~= "function" then
    return false
  end
  if type(core.IsNearby) ~= "function" or type(core.GetEffectiveRangeYards) ~= "function" then
    return false
  end
  return GetPlayerZoneContext() ~= nil
end

local function OnMinimapUpdate(_, elapsed)
  BoH.minimapElapsed = BoH.minimapElapsed + (elapsed or 0)
  if BoH.minimapElapsed < MINIMAP_UPDATE_INTERVAL then
    return
  end

  BoH.minimapElapsed = 0
  RefreshMinimapPins()
end

local function UpdateMinimapLoopState()
  if not BoH.frame then
    return
  end

  if MinimapUpdatesEnabled() then
    BoH.frame:SetScript("OnUpdate", OnMinimapUpdate)
    RefreshMinimapPins()
  else
    BoH.frame:SetScript("OnUpdate", nil)
    BoH.minimapElapsed = 0
    ClearMinimapPins()
  end
end

local function RefreshCurrentZoneMap()
  if type(SetMapToCurrentZone) == "function" then
    SetMapToCurrentZone()
  end

  AddWorldPins()
  UpdateMinimapLoopState()
end

local function OnEvent(_, eventName)
  if eventName == "WORLD_MAP_UPDATE" then
    AddWorldPins()
    return
  end

  if eventName == "PLAYER_LOGIN" or eventName == "PLAYER_ENTERING_WORLD" or eventName == "ZONE_CHANGED" or eventName == "ZONE_CHANGED_NEW_AREA" then
    RefreshCurrentZoneMap()
  end
end

local function OnSlashCommand(msg)
  local rangeResult

  msg = string.lower(msg or "")
  msg = string.gsub(msg, "^%s+", "")
  msg = string.gsub(msg, "%s+$", "")

  if msg == "toggle" then
    BoH.enabled = not BoH.enabled
    if BoH.enabled then
      print("|cFF00FF00Blood of Heroes enabled.|r")
      RefreshCurrentZoneMap()
    else
      print("|cFFFF0000Blood of Heroes disabled.|r")
      ClearWorldPins()
      ClearMinimapPins()
      UpdateMinimapLoopState()
    end
    return
  end

  rangeResult = nil
  if type(core.ParseRangeCommand) == "function" then
    rangeResult = core.ParseRangeCommand(msg)
  end

  if rangeResult ~= nil then
    if rangeResult == false then
      BoH.rangeOverrideYards = nil
      print("|cFF00FF00Blood of Heroes range reset to minimap zoom.|r")
    else
      BoH.rangeOverrideYards = rangeResult
      print("|cFF00FF00Blood of Heroes range set to " .. tostring(rangeResult) .. " yards.|r")
    end

    RefreshCurrentZoneMap()
    return
  end

  print("|cFFFFAA00Usage: /blood toggle | /blood range <yards> | /blood range reset|r")
end

if type(CreateFrame) ~= "function" then
  return
end

BoH.frame = BoH.frame or CreateFrame("Frame")
BoH.frame:RegisterEvent("PLAYER_LOGIN")
BoH.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
BoH.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
BoH.frame:RegisterEvent("ZONE_CHANGED")
BoH.frame:RegisterEvent("WORLD_MAP_UPDATE")
BoH.frame:SetScript("OnEvent", OnEvent)

SLASH_BLOOD1 = "/blood"
SlashCmdList = SlashCmdList or {}
SlashCmdList["BLOOD"] = OnSlashCommand
