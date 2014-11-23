local game = {}

function game:enter()

  self.player = {
    x = 0,
    y = 0,
    angle = 0,
    direction = 1,
    walking_dt = 0,
    walking_dt_t = 0.3,
  }

end

function game:init()

  self.mapsys = mapclass.new()
  self.map = self.mapsys:load()

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

  self.player_tear = love.graphics.newImage("assets/tear.png")

  self.player_1 = love.graphics.newImage("assets/character_idle1.png")
  self.player_2 = love.graphics.newImage("assets/character_idle2.png")
  self.player_3 = love.graphics.newImage("assets/character_idle3.png")
  self.player_4 = love.graphics.newImage("assets/character_idle4.png")

  self.player_walk_1 = {
    love.graphics.newImage("assets/character_anim1.png"),
    self.player_1,
    love.graphics.newImage("assets/character_anim5.png"),
  }
  self.player_walk_2 = {
    love.graphics.newImage("assets/character_anim2.png"),
    self.player_2,
    love.graphics.newImage("assets/character_anim6.png"),
  }
  self.player_walk_3 = {
    love.graphics.newImage("assets/character_anim3.png"),
    self.player_3,
    love.graphics.newImage("assets/character_anim7.png"),
  }
  self.player_walk_4 = {
    love.graphics.newImage("assets/character_anim4.png"),
    self.player_4,
    love.graphics.newImage("assets/character_anim8.png"),
  }

  self.doodads = { -- Keep order unless you want to redo all doodads on map!
    love.graphics.newImage('assets/pedo.png'),
    love.graphics.newImage('assets/anime.png'),
    love.graphics.newImage('assets/doge.png'),
  }

  self.traps = {
    love.graphics.newImage("assets/trap.png"),
    love.graphics.newImage("assets/spikes.png"),
  }
  self.monster = love.graphics.newImage("assets/monster.png")

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
  if global_debug_mode then
    love.graphics.arc(
      "line",love.graphics.getWidth()/2,love.graphics.getHeight()/2,
      128,gamestates.game.player.angle+0.1,gamestates.game.player.angle-0.1)
  end
end

function game:update(dt)
  if self.player.walking_dt ~= self.player.walking_dt_t then
    isomaplib.center_coord(self.player.x,self.player.y,self.player.xoff,self.player.yoff)
  end

  local vx,vy = dongwrapper.getBind(dong,"direction")
  if vx and vy then
    self.player.angle = math.atan2(vy,vx)

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

    if global_debug_mode or (
      self.map[target.x] and self.map[target.x][target.y] and -- on map
      not self.player.walking and -- not already walking
      (not self.map[target.x][target.y].wall or self.map[target.x][target.y].secret) 
    ) then -- not a wall
      self.player.x = target.x
      self.player.y = target.y
      self.player.walking = 1
      self.player.walking_dt = self.player.walking_dt_t
      self.player.walking_frame_dt = 0
      self.player.walking_frame_dt_t = 0.1
    end
  end

  if self.player.walking then
    self.player.walking_dt = self.player.walking_dt - dt
    self.player.walking_frame_dt = self.player.walking_frame_dt + dt
    if self.player.walking_frame_dt > self.player.walking_frame_dt_t then
      self.player.walking_frame_dt = 0
      self.player.walking = self.player.walking + 1
      if self.player.walking > #self.player_walk_1 then
        self.player.walking = 1
      end
    end
    if self.player.walking_dt <= 0 then
      self.player.walking = nil
    end
  else


    if self.map[self.player.x] and self.map[self.player.x][self.player.y] and
      self.map[self.player.x][self.player.y].trap then
      self.map[self.player.x][self.player.y].trap_triggered = true
      if not global_debug_mode then
        Gamestate.switch(gamestates.dead)
      end
    end
  end

  if global_debug_mode then
    local mx,my = love.mouse.getPosition()
    local mapx,mapy = isolib.raw_to_coord(mx,my)
    mapx = tonumber(mapx)
    mapy = tonumber(mapy)

    if love.keyboard.isDown("1","2","3","4","q","w","e") then
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

      if love.keyboard.isDown("4") then
        if self.map[mapx][mapy].doodad then
          self.map[mapx][mapy].doodad = self.map[mapx][mapy].doodad - 1
          if self.map[mapx][mapy].doodad <= 0 then
            self.map[mapx][mapy].doodad = #self.doodads
          end
        else
          self.map[mapx][mapy].doodad = #self.doodads
        end
        self.map[mapx][mapy].wall = true
      elseif love.keyboard.isDown("1") then
        self.map[mapx][mapy] = nil
      elseif love.keyboard.isDown("2") then
        self.map[mapx][mapy].wall = nil
      elseif love.keyboard.isDown("3") then
        self.map[mapx][mapy].wall = true
      elseif love.keyboard.isDown("q") then
        -- trap
        self.map[mapx][mapy].trap = true
        self.map[mapx][mapy].img = 1
      elseif love.keyboard.isDown("w") then
        -- spikes
        self.map[mapx][mapy].trap = true
        self.map[mapx][mapy].img = 2
      elseif love.keyboard.isDown("e") then
        -- monster
        self.map[mapx][mapy].monster = true
        self.map[mapx][mapy].direction = math.random(1,2)
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
  if map_data.trap then
    if map_data.trap_triggered or global_debug_mode then
      if global_debug_mode then
        love.graphics.setColor(255,255,0,127)
      end
      isolib.draw(gamestates.game.traps[map_data.img],x,y)
    end
  elseif map_data.wall then
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

    if map_data.doodad then
      wall = gamestates.game.doodads[map_data.doodad]
    end

    isolib.draw(wall,x,y)
  end
  if gamestates.game.player.x == x and
    gamestates.game.player.y == y then

    local rat = gamestates.game.player.walking_dt/gamestates.game.player.walking_dt_t
    local xoff = 128/2*rat
    local yoff = 76/2*rat

    if gamestates.game.player.direction == 1 then
      if gamestates.game.player.walking then
        isolib.draw(gamestates.game.player_walk_1[gamestates.game.player.walking],x,y,-xoff,-yoff)
        gamestates.game.player.xoff = xoff
        gamestates.game.player.yoff = yoff
      else
        isolib.draw(gamestates.game.player_1,x,y)
      end
    elseif gamestates.game.player.direction == 2 then
      if gamestates.game.player.walking then
        isolib.draw(gamestates.game.player_walk_4[gamestates.game.player.walking],x,y,xoff,-yoff)
        gamestates.game.player.xoff = -xoff
        gamestates.game.player.yoff = yoff
      else
        isolib.draw(gamestates.game.player_4,x,y)
      end
    elseif gamestates.game.player.direction == 3 then
      if gamestates.game.player.walking then
        isolib.draw(gamestates.game.player_walk_2[gamestates.game.player.walking],x,y,xoff,yoff)
        gamestates.game.player.xoff = -xoff
        gamestates.game.player.yoff = -yoff
      else
        isolib.draw(gamestates.game.player_2,x,y)
      end
    elseif gamestates.game.player.direction == 4 then
      if gamestates.game.player.walking then
        isolib.draw(gamestates.game.player_walk_3[gamestates.game.player.walking],x,y,-xoff,yoff)
        gamestates.game.player.xoff = xoff
        gamestates.game.player.yoff = -yoff
      else
        isolib.draw(gamestates.game.player_3,x,y)
      end
    end

    if not gamestates.game.player.walking then
      local draw_tear
      local checks = {}
      for i = -1,1 do
        for j = -1,1 do
          table.insert(checks, {gamestates.game.player.x+i,gamestates.game.player.y+j} )
        end
      end
      for _,check in pairs(checks) do
        if gamestates.game.map[check[1]] and gamestates.game.map[check[1]][check[2]] and
          gamestates.game.map[check[1]][check[2]].trap then
          draw_tear = true
          break
        end
      end
      if draw_tear then
        isolib.draw(gamestates.game.player_tear,gamestates.game.player.x,gamestates.game.player.y)
      end
    end


  end

end

return game
