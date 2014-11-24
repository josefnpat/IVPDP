local win = {}

function win:init()
  self.img = love.graphics.newImage("assets/bg_win.png")
end

function win:enter()
  self.dt = 0
  self.go_for_it = nil
  self.recording_sent = nil
end

function win:draw()
  love.graphics.draw(self.img)
  love.graphics.printf("You have died, but will not be forgotten.\n"..
    "Have a few souls to help you on your way...\n"..
    "Soul Count: "..(gamestates.game.ghosts+1),
    0,love.graphics.getHeight()/4,love.graphics.getWidth(),"center")
  self.go_for_it = true
end

function win:update(dt)
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

return win
