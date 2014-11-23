local dead = {}

function dead:enter()
  self.dt = 0
  self.go_for_it = nil
  self.recording_sent = nil
end

function dead:draw()
  love.graphics.printf("U R DED, LULZ",0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center")
  self.go_for_it = true
end

function dead:update(dt)
  if self.go_for_it and not self.recording_sent then
    print("workin' for the weekend")
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
