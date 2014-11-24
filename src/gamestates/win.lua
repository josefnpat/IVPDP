local win = {}

function win:init()
  self.img = love.graphics.newImage("assets/bg_win.png")
end

function win:draw()
  love.graphics.draw(self.img)
  love.graphics.setColor(0,0,0)
  love.graphics.printf("You found the exit, but stop to think:\n"..
    "how many bodies have I walked over to get here...\n"..
    "Soul Count: "..(gamestates.game.ghosts+1).."\n"..
    "Thanks for playing!\n"..
    "@josefnpat &\nJoseph Braband\n"..
    "missingsentinelsoftware.com",
    love.graphics.getWidth()*2/5,0,love.graphics.getWidth()*2/5,"center")
  love.graphics.setColor(255,255,255)
end

function win:update(dt)
end

return win
