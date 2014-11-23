local game = {}

function game:init()

  self.player = {
    x = 0,
    y = 0,
    angle = 0,
    direction = 1,
  }

  self.mapsys = mapclass.new()
  self.map = self.mapsys:load()

  --[[
  for x,v in pairs(self.map) do
    for y,w in pairs(v) do
      print(x,y,#w)
    end
  end
  --]]

  isomaplib.load_map(self.map)

  self.img = love.graphics.newImage("assets/tile.png")

  self.wall_t_1 = love.graphics.newImage("assets/wall_T_section1.png")
  self.wall_t_2 = love.graphics.newImage("assets/wall_T_section2.png")
  self.wall_t_3 = love.graphics.newImage("assets/wall_T_section3.png")
  self.wall_t_4 = love.graphics.newImage("assets/wall_T_section4.png")

  self.wall_c_1 = love.graphics.newImage("assets/wall_corner1.png")
  self.wall_c_2 = love.graphics.newImage("assets/wall_corner2.png")
  self.wall_c_3 = love.graphics.newImage("assets/wall_corner3.png")
  self.wall_c_4 = love.graphics.newImage("assets/wall_corner4.png")

  self.wall_x = love.graphics.newImage("assets/wall_cross_section.png")

  self.wall_straight_1 = love.graphics.newImage("assets/wall_straight1.png")
  self.wall_straight_2 = love.graphics.newImage("assets/wall_straight2.png")

  self.player_1 = love.graphics.newImage("assets/character_idle1.png")
  self.player_2 = love.graphics.newImage("assets/character_idle2.png")
  self.player_3 = love.graphics.newImage("assets/character_idle3.png")
  self.player_4 = love.graphics.newImage("assets/character_idle4.png")

  isomaplib.set_scale(1)
  isomaplib.debug = false
  isomaplib.center_coord(0,0)
end

function game:draw()
  if global_debug_mode then
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
  end
  isomaplib.draw()
  love.graphics.print("fps:"..love.timer.getFPS(),0,0)
  --[[
  love.graphics.arc(
    "line",love.graphics.getWidth()/2,love.graphics.getHeight()/2,
    128,gamestates.game.player.angle+0.1,gamestates.game.player.angle-0.1)
  --]]
end

function game:update(dt)
  isomaplib.center_coord(self.player.x,self.player.y)
  if global_debug_mode then
    local mx,my = love.mouse.getPosition()
    local mapx,mapy = isolib.raw_to_coord(mx,my)
    mapx = tonumber(mapx)
    mapy = tonumber(mapy)

    if love.keyboard.isDown("1","2","3") then
      if not self.map[mapx] then
        self.map[mapx] = {}
      end
      if not self.map[mapx][mapy] then
        self.map[mapx][mapy] = {}
      end
      if love.keyboard.isDown("lshift") then
        self.map[mapx][mapy].secret = true
      else
        self.map[mapx][mapy].secret = nil
      end

      if love.keyboard.isDown("1") then
        self.map[mapx][mapy] = nil
      elseif love.keyboard.isDown("2") then
        self.map[mapx][mapy].wall = nil
      elseif love.keyboard.isDown("3") then
        self.map[mapx][mapy].wall = true
      end

    end

  end
end

function game:keypressed(key)
  if global_debug_mode then
    if key == "s" then
      self.mapsys:save(self.map)
    end
  end
end

function game:mousepressed(mx,my,button)
  if button == "l" then
    self.player.angle = math.atan2(
      my - love.graphics.getHeight()/2,
      mx - love.graphics.getWidth()/2)

    local target = {x=self.player.x,y=self.player.y}

    if self.player.angle >= 0 and self.player.angle < math.pi/2 then
      target.x = target.x + 1
      self.player.direction = 1
    elseif self.player.angle > math.pi/2 and self.player.angle < math.pi then
      target.y = target.y + 1
      self.player.direction = 2
    elseif self.player.angle > -math.pi and self.player.angle < -math.pi/2 then
      target.x = target.x - 1
      self.player.direction = 3
    else -- lolol
      target.y = target.y - 1
      self.player.direction = 4
    end

    if self.map[target.x] and self.map[target.x][target.y] and -- on map
      (not self.map[target.x][target.y].wall or self.map[target.x][target.y].secret) then -- not a wall
      self.player.x = target.x
      self.player.y = target.y
    end

  end
end

function isomaplib.draw_callback(x,y,map_data)
  local distance = math.sqrt(
    (x-gamestates.game.player.x)^2 + 
    (y-gamestates.game.player.y)^2
  )
  local wat = distance > 0 and 11-distance/11*255 or 255
  love.graphics.setColor(wat,wat,wat)
  if map_data.secret then
    if global_debug_mode then
      love.graphics.setColor(0,0,255,127)
      isolib.draw(gamestates.game.img,x,y)
    end
  else
    isolib.draw(gamestates.game.img,x,y)
  end
  love.graphics.setColor(wat,wat,wat)
  if map_data.wall then
    local plusx,plusy,negx,negy
    if gamestates.game.map[x+1] and gamestates.game.map[x+1][y] and gamestates.game.map[x+1][y].wall then
      plusx = true
    end
    if gamestates.game.map[x] and gamestates.game.map[x][y+1] and gamestates.game.map[x][y+1].wall then
      plusy = true
    end
    if gamestates.game.map[x-1] and gamestates.game.map[x-1][y] and gamestates.game.map[x-1][y].wall then
      negx = true
    end
    if gamestates.game.map[x] and gamestates.game.map[x][y-1] and gamestates.game.map[x][y-1].wall then
      negy = true
    end

    if global_debug_mode then
      if map_data.secret then
        love.graphics.setColor(0,255,0,127)
      else
        love.graphics.setColor(255,0,0,127)
      end
    else
      love.graphics.setColor(wat,wat,wat)
    end

    local wall = gamestates.game.wall_x
    -- T
    if not plusx and plusy and negx and negy then
      wall = gamestates.game.wall_t_4
    elseif plusx and not plusy and negx and negy then
      wall = gamestates.game.wall_t_3
    elseif plusx and plusy and not negx and negy then
      wall = gamestates.game.wall_t_2
    elseif plusx and plusy and negx and not negy then
      wall = gamestates.game.wall_t_1

    -- C
    elseif plusx and plusy and not negx and not negy then
      wall = gamestates.game.wall_c_1
    elseif not plusx and not plusy and negx and negy then
      wall = gamestates.game.wall_c_2
    elseif not plusx and plusy and negx and not negy then
      wall = gamestates.game.wall_c_4
    elseif plusx and not plusy and not negx and negy then
      wall = gamestates.game.wall_c_3
    -- Straight double
    elseif not plusx and plusy and not negx and negy then
      wall = gamestates.game.wall_straight_1
    elseif plusx and not plusy and negx and not negy then
      wall = gamestates.game.wall_straight_2
    -- Straght single
    elseif plusx and not plusy and not negx and not negy then
      wall = gamestates.game.wall_straight_2
    elseif not plusx and not plusy and negx and not negy then
      wall = gamestates.game.wall_straight_2
    elseif not plusx and plusy and not negx and not negy then
      wall = gamestates.game.wall_straight_1
    elseif not plusx and not plusy and not negx and negy then
      wall = gamestates.game.wall_straight_1

    end

    isolib.draw(wall,x,y)
  end
  if gamestates.game.player.x == x and
    gamestates.game.player.y == y then
    if gamestates.game.player.direction == 1 then
      isolib.draw(gamestates.game.player_1,x,y)
    elseif gamestates.game.player.direction == 2 then
      isolib.draw(gamestates.game.player_4,x,y)
    elseif gamestates.game.player.direction == 3 then
      isolib.draw(gamestates.game.player_2,x,y)
    elseif gamestates.game.player.direction == 4 then
      isolib.draw(gamestates.game.player_3,x,y)
    end
  end

end

return game
