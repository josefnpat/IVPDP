local download = {}

download.wait = 4 -- lol

function download.recording_valid(recording)
  if type(recording)~="table" then return nil end
  local stripped_recording = {}
  for _,record in pairs(recording) do
    if type(record)~="table" then return nil end
    local stripped_record = {}
    if type(record.vx)~="number" then return nil end
    stripped_record.vx = record.vx
    if type(record.vy)~="number" then return nil end
    stripped_record.vy = record.vy
    if type(record.time)~="number" then return nil end
    stripped_record.time = record.time
    table.insert(stripped_recording,stripped_record)
  end
  return stripped_recording
end

function download:get_some()
  self.recording_pool = {}
  local response = http.request(ghost_server)
  local status,data = pcall( function() return json.decode(response) end);
  if status == true then
    for _,recording in pairs(data) do
      local clean = download.recording_valid(recording)
      if clean then
        table.insert(self.recording_pool,clean)
      end
    end
  end
end

function download:update(dt)
  download.wait = download.wait - dt
  if self.go_for_it and download.wait < 0 then
    download:get_some()
    Gamestate.switch(gamestates.game)
  end
end

function download:draw()
  love.graphics.printf(game_name.."\n\nDownloading ghosts ...",
    0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center")
  download.go_for_it = true
end

return download
