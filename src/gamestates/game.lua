local game = {}

function game:init()

  self.player = {
    x = 0,
    y = 0,
    angle = 0,
  }

  self.map = {}
--[[
  self.size = 25
  for x=-self.size,self.size do
    self.map[x] = {}
    for y=-self.size,self.size do
      self.map[x][y] = {}
      self.map[x][y].wall = false
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

  self.cursor = love.graphics.newImage("assets/cursor.png")

  isomaplib.set_scale(1)
  isomaplib.debug = false
  isomaplib.center_coord(0,0)
end

function game:draw()
  isomaplib.draw()
  if global_debug_mode then
    love.graphics.print("DEBUG MODE - fps:"..love.timer.getFPS(),0,0)
  end
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
    if love.keyboard.isDown("1") then
      if not self.map[mapx] then
        self.map[mapx] = {}
      end
      if not self.map[mapx][mapy] then
        self.map[mapx][mapy] = {}
      end
      self.map[mapx][mapy] = nil
    elseif love.keyboard.isDown("2") then
      if not self.map[mapx] then
        self.map[mapx] = {}
      end
      if not self.map[mapx][mapy] then
        self.map[mapx][mapy] = {}
      end
      self.map[mapx][mapy] = {}
    elseif love.keyboard.isDown("3") then
      if not self.map[mapx] then
        self.map[mapx] = {}
      end
      if not self.map[mapx][mapy] then
        self.map[mapx][mapy] = {}
      end

      self.map[mapx][mapy].wall = true
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
    elseif self.player.angle > math.pi/2 and self.player.angle < math.pi then
      target.y = target.y + 1
    elseif self.player.angle > -math.pi and self.player.angle < -math.pi/2 then
      target.x = target.x - 1
    else -- lolol
      target.y = target.y - 1
    end

    if self.map[target.x] and self.map[target.x][target.y] and -- on map
      not self.map[target.x][target.y].wall then -- not a wall
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
  isolib.draw(gamestates.game.img,x,y)
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
    isolib.draw(gamestates.game.cursor,x,y)
  end
end

return game
