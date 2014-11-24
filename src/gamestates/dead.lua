local dead = {}

function dead:init()
  self.img = love.graphics.newImage("assets/bg_dead.png")
end

function dead:enter()
  self.dt = 0
  self.go_for_it = nil
  self.recording_sent = nil
end

function dead:draw()
  love.graphics.draw(self.img)
  love.graphics.printf("You have died, but will not be forgotten.\n"..
    "A few souls rise to help you on your way...\n"..
    "Soul Count: "..(gamestates.game.ghosts+1).."\n\nFind the exit ...",
    0,love.graphics.getHeight()/4,love.graphics.getWidth(),"center")
  self.go_for_it = true
end

function dead:update(dt)
  if self.go_for_it and not self.recording_sent then
    local response = http.request(
      ghost_server,
      "recording="..json.encode(gamestates.game.recording)
    )
    self.recording_sent = true
  end
  self.dt = self.dt + dt
  if self.dt > 4 then
    Gamestate.switch(gamestates.game)
  end
end

return dead
