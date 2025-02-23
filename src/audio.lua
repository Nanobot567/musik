audio = {}

audio.title = nil
audio.path = nil

audio.lastOffset = 0

audio.player = snd.fileplayer.new()
audio.player:setStopOnUnderrun(false)

function audio.play(path)
  local wasPlaying = audio.player:isPlaying()

  if path ~= audio.path then
    audio.player:stop()

    audio.path = path
    audio.title = nil

    local tags = id3.readtags(path)

    if tags ~= nil then

      local title = tags["title"]

      if title ~= nil then
        audio.title = title
      end
    end

    if audio.title == nil then
      local spl = string.split(audio.path, "/")

      audio.title = spl[#spl]
    end

    audio.player:load(path)

    if wasPlaying then
      pd.timer.performAfterDelay(50, function () -- small buffer to prevent mp3 error
        audio.player:play()
      end)
    else
      audio.player:play()
    end
  end
end

function audio.toggle()
  if audio.player:isPlaying() then
    audio.player:pause()
  else
    audio.player:play()
  end
end

local safeToReset = true
local songEndErrorCounter, saveSongSpot, saveSongSpot2 = 0, 0, 0

function audio.scrub(offset)
  -- print(audio.lastOffset, audio.player:getOffset())

  -- audio.player:setOffset(audio.player:getOffset() + offset)

  audio.player:pause()

  saveSongSpot = audio.player:getOffset()
  pd.timer.new(40, function()
    if safeToReset == true then
      saveSongSpot2 = saveSongSpot
    end
  end)

  audio.player:setOffset((audio.lastOffset + offset))

  audio.player:play()
end

function audio.nextSong()
  if errorHappened then
    audio.play(audio.path)
  end
end

audio.player:setFinishCallback(function()
  songEndErrorCounter = songEndErrorCounter + 1

  -- If the function has been called more than once in 100 frames, return immediately
  if songEndErrorCounter > 5 then
    errorHappened = true
    audio.nextSong()
    return
  end

  -- Reset the counter after 100 frames
  pd.timer.new(300, function()
    songEndErrorCounter = 0
  end)

  if (math.abs(audio.player:getOffset() - audio.player:getLength()) <= 5) and math.abs(audio.lastOffset - audio.player:getLength() <= 5) then
    --print("actual song change")
    audio.nextSong()
  else
    --print("averting crisis?")
    errorHappened = true
    audio.player:pause()
    audio.player:setOffset(math.floor(saveSongSpot2 + 0.5))
    audio.player:play()

    safeToReset = false
    pd.timer.new(100, function()
      safeToReset = true
    end)
  end
end)
