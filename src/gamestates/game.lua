local game = {}

function game:enter()

  self.ghosts = self.ghosts + 1

  self.players = {
    {
      current = true,
      x = 0,
      y = 0,
      angle = 0,
      direction = 1,
      walking_dt = 0,
      walking_dt_t = 0.3,
    },
  }

  if self.ghosts >= 1 then
    for i = 1,self.ghosts do
      table.insert(self.players,
        {
          x = 0,
          y = 0,
          angle = 0,
          direction = 1,
          walking_dt = 0,
          walking_dt_t = 0.3,
          recording = self.recording_pool[math.random(1,#self.recording_pool)],
          recording_index = 1
        })
    end
  end

  self.recording = {}
  self.time = 0

  -- Annoying?
  --[[
  for x,v in pairs(self.map) do
    for y,d in pairs(v) do
      d.trap_triggered = nil
    end
  end
  --]]

end

function game:init()

  music = love.audio.newSource("assets/music.ogg")
  music:setLooping(true)
  music:play()

  self.ghosts = -1

  self.recording_pool = gamestates.download.recording_pool

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
    love.graphics.newImage('assets/pewdiepie.png'),
    love.graphics.newImage('assets/fab1.png'),
    love.graphics.newImage('assets/fab2.png'),
    love.graphics.newImage('assets/fab3.png'),
    love.graphics.newImage('assets/fab4.png'),
    love.graphics.newImage('assets/monster.png'),
  }

  self.traps = {
    love.graphics.newImage("assets/trap.png"),
    love.graphics.newImage("assets/spikes.png"),
  }
  self.door_bottom = self.img
  self.door_top = love.graphics.newImage("assets/door.png")

  isomaplib.set_scale(1)
  isomaplib.debug = false
  isomaplib.center_coord(0,0)
end

function game:draw()
  if global_debug_mode then
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
  end
  isomaplib.draw()
  if global_debug_mode then
    love.graphics.print("fps:"..love.timer.getFPS(),0,0)
    for _,player in pairs(gamestates.game.players) do
      love.graphics.arc(
        "line",love.graphics.getWidth()/2,love.graphics.getHeight()/2,
        128,player.angle+0.05,player.angle-0.05)
    end
  end
end

function game:update(dt)

  self.time = self.time + dt

  isomaplib.center_coord(self.players[1].x,self.players[1].y,self.players[1].xoff,self.players[1].yoff)

  for _,player in pairs(self.players) do
    local vx,vy
    if player.current then
      vx,vy = dongwrapper.getBind(dong,"direction")
    else
      if player.recording[player.recording_index] then
        if self.time > player.recording[player.recording_index].time then
          vx = player.recording[player.recording_index].vx
          vy = player.recording[player.recording_index].vy
          player.recording_index = player.recording_index + 1
        end
      else
        player.dead = true
      end
    end

    --for i,p in pairs(self.players) do if p._remove then table.remove(self.players,i) end end

    if vx and vy and (not player.walking or not player.current) then
      player.angle = math.atan2(vy,vx)

      local target = {x=player.x,y=player.y}

      if player.angle >= 0 and player.angle < math.pi/2 then
        target.x = target.x + 1
        player.direction = 1
      elseif player.angle > math.pi/2 and player.angle < math.pi then
        target.y = target.y + 1
        player.direction = 2
      elseif player.angle > -math.pi and player.angle < -math.pi/2 then
        target.x = target.x - 1
        player.direction = 3
      else -- lolol
        target.y = target.y - 1
        player.direction = 4
      end

      if global_debug_mode or (
        self.map[target.x] and self.map[target.x][target.y] and -- on map
        (not player.walking or not player.current) and -- not already walking
        (not self.map[target.x][target.y].wall or self.map[target.x][target.y].secret) 
      ) then -- not a wall
        if player.current then
          table.insert(self.recording,
            {
              time = self.time,
              vx = vx,
              vy = vy,
            })
        end
        player.x = target.x
        player.y = target.y
        player.walking = 1
        if global_debug_mode then
          player.walking_dt = 1/60
        else
          player.walking_dt = player.walking_dt_t
        end
        player.walking_frame_dt = 0
        player.walking_frame_dt_t = 0.1
      end
    end

    if player.walking then
      player.walking_dt = player.walking_dt - dt
      player.walking_frame_dt = player.walking_frame_dt + dt
      if player.walking_frame_dt > player.walking_frame_dt_t then
        player.walking_frame_dt = 0
        player.walking = player.walking + 1
        if player.walking > #self.player_walk_1 then
          player.walking = 1
        end
      end
      if player.walking_dt <= 0 then
        player.walking = nil
      end
    end
    if self.map[player.x] and self.map[player.x][player.y] then
      if self.map[player.x][player.y].trap then
        self.map[player.x][player.y].trap_triggered = true
        if player.current and not global_debug_mode then
          table.insert(self.recording_pool,self.recording)
          Gamestate.switch(gamestates.dead)
        end
      end
      if self.map[player.x][player.y].win and player.current and not global_debug_mode then
        Gamestate.switch(gamestates.win)
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
        self.map[mapx][mapy].win = true
      end
    end
  end
end

function game:keypressed(key)
  if global_debug_mode then
    if key == "s" then
      self.mapsys:save(self.map)
    end
    if key == "d" then
      print(json.encode(self.recording))
    end
  end
end

function isomaplib.getDistanceShade(x,y)
  local distance = math.sqrt(
    (x-gamestates.game.players[1].x)^2 +
    (y-gamestates.game.players[1].y)^2
  )
  local doublewat = 11
  return distance > 0 and doublewat-distance/doublewat*255 or 255
end

function isomaplib.draw_callback(x,y,map_data)
  local wat = isomaplib.getDistanceShade(x,y)
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
  end
end

function isomaplib.draw_callback2(x,y,map_data)

  for _,player in pairs(gamestates.game.players) do
    if player.x == x and
      player.y == y then

      if player.current then
        love.graphics.setColor(255,255,255)
      elseif player.dead then
        love.graphics.setColor(217,0,0,127)
      else
        love.graphics.setColor(80,173,255,127)
      end

      local rat = player.walking_dt/player.walking_dt_t
      local xoff = 128/2*rat
      local yoff = 76/2*rat

      if player.direction == 1 then
        if player.walking then
          isolib.draw(gamestates.game.player_walk_1[player.walking],x,y,-xoff,-yoff)
          player.xoff = xoff
          player.yoff = yoff
        else
          isolib.draw(gamestates.game.player_1,x,y)
        end
      elseif player.direction == 2 then
        if player.walking then
          isolib.draw(gamestates.game.player_walk_4[player.walking],x,y,xoff,-yoff)
          player.xoff = -xoff
          player.yoff = yoff
        else
          isolib.draw(gamestates.game.player_4,x,y)
        end
      elseif player.direction == 3 then
        if player.walking then
          isolib.draw(gamestates.game.player_walk_2[player.walking],x,y,xoff,yoff)
          player.xoff = -xoff
          player.yoff = -yoff
        else
          isolib.draw(gamestates.game.player_2,x,y)
        end
      elseif player.direction == 4 then
        if player.walking then
          isolib.draw(gamestates.game.player_walk_3[player.walking],x,y,-xoff,yoff)
          player.xoff = xoff
          player.yoff = -yoff
        else
          isolib.draw(gamestates.game.player_3,x,y)
        end
      end

      if not player.walking then
        local draw_tear
        local checks = {}
        for i = -1,1 do
          for j = -1,1 do
            table.insert(checks, {player.x+i,player.y+j} )
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
          isolib.draw(gamestates.game.player_tear,player.x,player.y)
        end
      end
    end
  end

  local wat = isomaplib.getDistanceShade(x,y)

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

    if map_data.doodad then
      wall = gamestates.game.doodads[map_data.doodad]
    end

    isolib.draw(wall,x,y)
  end

  if map_data.win then
    love.graphics.setColor(wat,wat,wat)
    isolib.draw(gamestates.game.door_top,x,y)
  end

end

return game
