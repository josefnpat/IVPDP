git,git_count = "missing git.lua",0
pcall( function() return require("git") end );

Gamestate = require "libs.gamestate"

dong2lib = require "libs.dong2lib"
dongwrapper = require "libs.dongwrapper"

splashclass = require "libs.splashclass"

isomaplib = require("libs/isomaplib/isomaplib")

gamestates = {
  splash = require "gamestates.splash",
  game = require "gamestates.game",
}

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(gamestates.splash)

  dong = dong2lib.new()
  setBindings(dong)

  game_name = "IVPDP"

  love.window.setTitle(game_name.." v"..git_count.." [git:"..git.."]")

end

function love.update(dt)
  if dongwrapper.getBind(dong,"debug",1) then
    global_debug_mode = not global_debug_mode
  end
end

function setBindings(dong)

  dong:setBind("confirm",
    function(self,data) return data[1] or data[2] end,
    {
      KEYBMOUSE={args={"return"," "}},
    })

  dong:setBind("debug",
    function(self,data) return data[1] and data[2] end,
    {
      KEYBMOUSE={args={"lshift","`"}},
    })

end

