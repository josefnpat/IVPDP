local dead = {}

function dead:enter()
  self.dt = 0
end

function dead:draw()
  love.graphics.printf("U R DED, LULZ",0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center")
end

function dead:update(dt)
  self.dt = self.dt + dt
  if self.dt > 4 then
    Gamestate.switch(gamestates.game)
  end
end

return dead
