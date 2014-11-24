git,git_count = "missing git.lua",0
pcall( function() return require("git") end );

Gamestate = require "libs.gamestate"

ghost_server = "http://50.116.63.25/public/IVPDP/api.php?api=1"

music = love.audio.newSource("assets/music.ogg")

music:setLooping(true)
music:play()


fonts = {
  title = love.graphics.newFont("assets/fonts/RockSalt.ttf",32)
}

love.graphics.setFont(fonts.title)

require "libs/json"

dong2lib = require "libs.dong2lib"
dongwrapper = require "libs.dongwrapper"
http = require('socket.http')

splashclass = require "libs.splashclass"
mapclass = require "libs.mapclass"

isomaplib = require("libs/isomaplib/isomaplib")

gamestates = {
  splash = require "gamestates.splash",
  download = require "gamestates.download",
  game = require "gamestates.game",
  dead = require "gamestates.dead",
  win = require "gamestates.win",
}

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(gamestates.splash)

  dong = dong2lib.new()
  setBindings(dong)

  game_name = "Patient Negative Zero"

  love.window.setTitle(game_name.." v"..git_count.." [git:"..git.."]")

end

function love.joystickadded(joystick)
  local ndong = dong2lib.new(joystick)
  if ndong then
    setBindings(ndong)
    dong = ndong
    print("JOYSTICK DETECTED")
  end
end

function love.update(dt)
  if dongwrapper.getBind(dong,"debug",1) then
    global_debug_mode = not global_debug_mode
    global_debug_mode_triggered = true
  end
end

function setBindings(dong)

  dong:setBind("confirm",
    function(self,data) return data[1] or data[2] end,
    {
      KEYBMOUSE={args={"return"," "}},
      XBOX_360_WIRED={args={"A"}},
    })

  dong:setBind("debug",
    function(self,data) return data[1] and data[2] end,
    {
      KEYBMOUSE={args={"lshift","`"}},
      XBOX_360_WIRED={args={"LB","RB"}}, 
    })

  dong:setBind("direction",
    function(self,data)
      if self._type=="KEYBMOUSE" then
        if not love.mouse.isDown("l") then return end
        local dx = love.mouse.getX() - love.graphics.getWidth()/2
        local dy = love.mouse.getY() - love.graphics.getHeight()/2
        local mag = math.sqrt( dx^2 + dy^2 )
        local vx,vy = dx/mag,dy/mag --normalize
        return vx,vy
      else
        local LS_DEADZONE = 7849/65534*2
        if math.sqrt( data[1]^2 + data[2]^2 ) > LS_DEADZONE then
          return unpack(data)
        end
      end
    end,
    {
      KEYBMOUSE={args={"x","y"},name="Mouse",mouse=true},
      XBOX_360_WIRED={args={"LSX","LSY"}},
    })

end

