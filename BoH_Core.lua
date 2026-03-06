local core = {}

local ZOOM_RANGE = {
  [0] = 300,
  [1] = 240,
  [2] = 190,
  [3] = 150,
  [4] = 115,
  [5] = 90
}

function core.NormalizeZoneName(name)
  if name == "Eastern Plaguelands" then
    return "EasternPlaguelands"
  end
  if name == "Western Plaguelands" then
    return "WesternPlaguelands"
  end
  return nil
end

function core.GetZoomRangeYards(zoom)
  local value = ZOOM_RANGE[zoom]
  if value then
    return value
  end
  return ZOOM_RANGE[2]
end

function core.GetEffectiveRangeYards(zoom, overrideYards)
  if overrideYards then
    return overrideYards
  end
  return core.GetZoomRangeYards(zoom)
end

function core.ParseRangeCommand(msg)
  local n

  if type(msg) ~= "string" then
    return nil
  end

  n = string.match(msg, "^range%s+(%d+)$")
  if n then
    return tonumber(n)
  end

  if msg == "range reset" then
    return false
  end

  return nil
end

function core.IsNearby(px, py, nx, ny, zoneWidthYards, zoneHeightYards, maxYards)
  local dx = (nx - px) * zoneWidthYards
  local dy = (ny - py) * zoneHeightYards
  return (dx * dx + dy * dy) <= (maxYards * maxYards)
end

BoH_Core = core

return core
