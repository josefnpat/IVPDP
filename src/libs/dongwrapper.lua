local dongwrapper = {}

dongwrapper.dong_bind_triggers = {}

function dongwrapper.getBind(dong,bind,trigger)
  if trigger then
    local index = tostring(dong).."_"..bind
    if dong:getBind(bind) then
      if dongwrapper.dong_bind_triggers[index] then
        dongwrapper.dong_bind_triggers[index] = nil
        return true
      end
    else
      dongwrapper.dong_bind_triggers[index] = true
      return
    end
  else
    return dong:getBind(bind)
  end
end

function dongwrapper.getBindAll(bind,trigger)
  for _,dong in pairs(dongs) do
    local val = dongwrapper.getBind(dong,bind,trigger)
    if val then return val end
  end
end

function dongwrapper.isRegistered(dong)
  local registered
  for _,test in pairs(dongs) do
    if test._joystick and test._joystick:getGUID() == dong._joystick:getGUID() then
      registered = true
      break
    end
  end
  return registered
end

function dongwrapper.hat2vector(dir)
  local x,y = 0,0
  if string.sub(dir,1,1)   == "r" then x = x + 1 end
  if string.sub(dir,1,1)   == "l" then x = x - 1 end
  if string.sub(dir,-1,-1) == "u" then y = y - 1 end
  if string.sub(dir,-1,-1) == "d" then y = y + 1 end
  return x,y
end

return dongwrapper
