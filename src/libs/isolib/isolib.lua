isolib = {}

isolib.width = 128
isolib.height = 76

isolib.offset = {}
isolib.offset.x = 0
isolib.offset.y = 0

function isolib.draw(drawable,x,y,xoff,yoff)
  local rawx,rawy = isolib.coord_to_raw(x,y)
  love.graphics.draw(drawable,rawx+(xoff or 0),rawy+(yoff or 0),0,1,1,isolib.width/2,256-isolib.height/2)
end

function isolib.center_coord(cx,cy,x,y,w,h,xoff,yoff)
  -- reset offsets as coord_to_raw() uses them
  isolib.offset.x,isolib.offset.y = 0,0
  tx,ty = isolib.coord_to_raw(cx,cy)
  isolib.offset.x = math.floor(x + w/2-tx) + (xoff or 0)
  isolib.offset.y = math.floor(y + h/2-ty) + (yoff or 0)
end

function isolib.coord_to_raw(x,y)
  local rawx = (x - y) * isolib.width/2
  local rawy = (x + y) * isolib.height/2
  rawx,rawy = rawx+isolib.offset.x,rawy+isolib.offset.y
  return rawx,rawy
end

function isolib.raw_to_coord(rawx,rawy)
  rawx,rawy = rawx-isolib.offset.x,rawy-isolib.offset.y
  rawx = rawx - isolib.width
  rawy = rawy - isolib.height
  local x = rawy/isolib.height + rawx/isolib.width
  local y = rawy/isolib.height - rawx/isolib.width
  x = x + 2
  return math.floor(x+0.5),math.floor(y+0.5)
end

return isolib
