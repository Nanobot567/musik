-- now playing screen

nowPlayingScreen = {}

function nowPlayingScreen.AButtonDown()
  audio.toggle()
end

function nowPlayingScreen.BButtonDown()
  handler.swap("files")
end

function nowPlayingScreen.rightButtonDown() -- TODO: scrub when r/l held, update time but don't start playing until button released
  audio.scrub(2)
end

function nowPlayingScreen.leftButtonDown()
  audio.scrub(-2)
end

function nowPlayingScreen.update()
  audio.lastOffset = audio.player:getOffset()
  
  pd.timer.updateTimers()
  gfx.clear()

  local secondsX, secondsY, modeStringX, modeStringY, playingGraphicX, playingGraphicY = 200, 211, 388, 212, 10, 210

  if settings.settings["newUI"] == false then
    secondsX = 200
    secondsY = 220
    modeStringX = 398
    modeStringY = 220
    playingGraphicX = 0
    playingGraphicY = 220
  end

  if audio.player:getLength() ~= nil and audio.player:getLength() ~= 0 then
    local offset = string.formatSeconds(audio.player:getOffset())
    local len = string.formatSeconds(audio.player:getLength())

    gfx.drawTextInRect(string.normalize(audio.title), 20, 110, 360, 20, nil, "...", kTextAlignment.center)
    gfx.drawTextAligned(offset .. " / " .. len, secondsX, secondsY, kTextAlignment.center)
  end

  if settings.settings["newUI"] then
    gfx.drawRoundRect(5, 205, 390, 30, settings.settings["screenRoundness"])
  end

  if audio.player:isPlaying() then
    playingGraphic:draw(playingGraphicX, playingGraphicY)
  else
    pausedGraphic:draw(playingGraphicX, playingGraphicY)
  end
end
