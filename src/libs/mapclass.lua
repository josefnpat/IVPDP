local map = {}

function map.new()
  local self={}
  self.load=map.load
  self.save=map.save
  self._map=nil --init
  self.getMap=map.getMap
  self.setMap=map.setMap
  self._location="map.json" --init
  self.getLocation=map.getLocation
  self.setLocation=map.setLocation
  return self
end

function map:load()
  if love.filesystem.isFile( self:getLocation() ) then
    local raw = love.filesystem.read( self:getLocation() )
    local data = json.decode(raw)
    local map = {}
    -- wtf bbq thanks bart screw you json
    for x,v in pairs(data) do
      map[tonumber(x)] = {}
      for y,d in pairs(v) do
        map[tonumber(x)][tonumber(y)] = d
      end
    end
    return map
  else
    return {}
  end
end

function map:save(map)
  print("MAP SAVED.")
  local raw = json.encode(map)
  love.filesystem.write( self:getLocation(), raw )
end

function map:getMap()
  return self._map
end

function map:setMap(val)
  self._map=val
end

function map:getLocation()
  return self._location
end

function map:setLocation(val)
  self._location=val
end

return map
