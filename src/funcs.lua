local gfx <const> = pd.graphics
local disp <const> = pd.display
local timer <const> = pd.timer
local fs <const> = pd.file

local songEndErrorCounter = 0

function lockScreenFunc()
  locked = true
  gfx.clear(bgColor)
  disp.setRefreshRate(5)
end

function swapScreenMode()
  if screenMode == 0 or screenMode == 3 then
    screenMode = 1

    if mode == 4 and currentAudio:isPlaying() == false then
      actualSongEnd()
    end
  elseif screenMode == 1 then
    if mode == 4 then
      screenMode = 3
    else
      screenMode = 0
    end

    if currentFileDir == "" then
      dir = "/music/"

      for i = 1, #files do
        if findSupportedTypes(files[curRow]) then
          table.insert(audioFiles, files[i])
        end
      end
    else
      dir = currentFileDir
      files = fs.listFiles(dir, false)

      for i = 1, #files do
        if findSupportedTypes(files[curRow]) then
          table.insert(audioFiles, files[i])
        end
      end
      -- set directory to currentFileDir

      for i, v in ipairs(files) do
        if v == currentFileName then
          fileList:setSelectedRow(i)
          fileList:scrollToRow(i, true)
        end
      end
    end
    if dir ~= "/music/" then
      table.insert(files, 1, "..")
      fileList:selectNextRow()
    end
  end
end

function swapColorMode(mode)
  if mode == false then
    bgColor = gfx.kColorWhite
    color = gfx.kColorBlack
    dMColor1 = gfx.kDrawModeCopy
    dMColor2 = gfx.kDrawModeFillWhite
    gfx.setColor(color)
    darkMode = false
  else
    bgColor = gfx.kColorBlack
    color = gfx.kColorWhite
    dMColor1 = gfx.kDrawModeFillWhite
    dMColor2 = gfx.kDrawModeCopy
    gfx.setColor(color)
    darkMode = true
  end
end

function saveSettings()
  local settingsFile = fs.open("/data/settings.json", fs.kFileWrite)
  settingsFile:write(json.encode({ darkMode, clockMode, showInfoEverywhere, screenRoundness, lockScreen, lockScreenTime, uiDesign }))
  settingsFile:close()
end

function loadSettings()
  local settingsFile, err = fs.open("/data/settings.json", fs.kFileRead)

  if err == nil then
    local settings = json.decode(settingsFile:read(100000))

    darkMode = settings[1]
    clockMode = settings[2]
    showInfoEverywhere = settings[3]
    screenRoundness = tonumber(settings[4])
    lockScreen = settings[5]
    lockScreenTime = tonumber(settings[6])

    if lockScreen == true then
      lockTimer = timer.new((lockScreenTime * 60) * 1000, lockScreenFunc)
    end

    if settings[7] then
      uiDesign = settings[7]
    else
      uiDesign = "new"
    end
  else
    darkMode = true
    clockMode = false
    showInfoEverywhere = false
    lockScreen = false
    screenRoundness = 4
    lockScreenTime = 2
    if lockScreen == true then
      lockTimer = timer.new((lockScreenTime * 60) * 1000, lockScreenFunc)
    end

    uiDesign = "new"
  end
end

function handleMode(str) -- add queue mode
  print("mode is now " .. str)
  modeString = str

  if str == "shuffle" then
    mode = 1
  elseif str == "loop folder" then
    mode = 2
  elseif str == "loop one" then
    mode = 3
  elseif str == "queue" then
    getLengthVar = 0
    saveSongSpot = 0
    saveSongSpot2 = 0

    screenMode = 3
    mode = 4

    currentAudio:setFinishCallback(nil)
    currentAudio:stop()
    currentAudio = pd.sound.fileplayer.new()
    currentAudio:setFinishCallback(handleSongEnd)
    currentFileName = ""
    currentFileDir = ""
    currentFilePath = ""
  else
    mode = 0
  end

  if mode ~= 4 then
    queueList = {}
    queueListDirs = {}
    queueListNames = {}
  end
end

function newSettingsList()
  local setList = ({ "dark mode - " .. tostring(darkMode),
    "24 hour clock - " .. tostring(clockMode),
    "show extra info everywhere - " .. tostring(showInfoEverywhere),
    "show version - " .. tostring(showVersion),
    "screen roundness - " .. tostring(screenRoundness),
    "ui design - " .. tostring(uiDesign),
    "lock screen - " .. tostring(lockScreen),
  })

  if lockScreen == true then
    table.insert(setList, "   lock after " .. tostring(lockScreenTime) .. " minute(s)")
  end

  return setList
end

function drawInfo()
  local extension
  local time = pd.getTime()
  if #tostring(time["hour"]) == 1 then
    time["hour"] = "0" .. time["hour"]
  end

  if clockMode == false then
    if tonumber(time["hour"]) > 12 then
      time["hour"] -= 12
    end
  end

  if #tostring(time["minute"]) == 1 then
    time["minute"] = "0" .. time["minute"]
  end

  local batteryPercent = pd.getBatteryPercentage()

  if string.find(batteryPercent, "100.") then
    batteryPercent = "100"
  else
    batteryPercent = string.sub(string.gsub(batteryPercent, "%.", ""), 1, 2)
  end

  local size = gfx.getTextSize(batteryPercent .. "%", dosFnt)

  dosFnt:drawTextAligned(time["hour"] .. ":" .. time["minute"], 1, 1, 400, 20, kTextAlignment.left)
  dosFnt:drawTextAligned(batteryPercent .. "%", 401 - size, 1, 400, 20, kTextAlignment.right)
  -- gfx.setImageDrawMode(dMColor2)
end

function actualSongEnd()
  updateGetLength = true
  
  local justInQueue = false

  audioFiles = {}
  for i = 1, #files do
    if findSupportedTypes(files[i]) then
      table.insert(audioFiles, files[i])
    end
  end

  currentAudio:pause()

  if mode == 2 then
    if currentFileName == audioFiles[1] then
      currentPos = 1
    end
    if currentFileName == audioFiles[#audioFiles] then
      if not pd.buttonIsPressed("a") then
        if fs.isdir(dir .. audioFiles[1]) == false then
          currentFileName = audioFiles[1]
          currentAudio:load(dir .. audioFiles[1])
        end
      end
    else
      local isdir = fs.isdir(dir .. audioFiles[currentPos + 1])
      if isdir == true then
        currentPos += 2
      else
        currentPos += 1
      end

      currentFileName = audioFiles[currentPos]
      currentAudio:load(dir .. audioFiles[currentPos])
    end
  elseif mode == 1 then
    local randthing = math.random(1, #audioFiles)
    if dir .. audioFiles[randthing] == currentFilePath and #audioFiles ~= 1 then
      while dir .. audioFiles[randthing] == currentFilePath do
        randthing = math.random(1, #audioFiles)
      end
    end
    currentFileName = audioFiles[randthing]
    currentAudio:load(dir .. audioFiles[randthing])
  elseif mode == 0 then
    currentAudio = pd.sound.fileplayer.new()
    currentAudio:setFinishCallback(handleSongEnd)
    currentFileName = ""
    currentFileDir = ""
    currentFilePath = ""
  elseif mode == 4 then
    if #queueList == 1 then
      mode = 1
      modeMenuItem:setValue("shuffle")
      modeString = "shuffle"
      justInQueue = true
    end

    if #queueList ~= 0 then
      currentFileName = queueListNames[1]
      currentFileDir = queueListDirs[1]
      currentFilePath = queueList[1]
      table.remove(queueList, 1)
      table.remove(queueListDirs, 1)
      table.remove(queueListNames, 1)
      currentAudio:load(currentFilePath)
    else
      mode = 0
      modeMenuItem:setValue("none")
      modeString = "none"
    end
  end

  if mode ~= 4 then
    if justInQueue == false then
      currentFilePath = dir .. currentFileName
      currentFileDir = dir
    end
  end

  table.insert(lastSongNames, currentFileName)
  table.insert(lastSongDirs, currentFileDir)

  audioLen = getLengthVar

  currentAudio:setRate(1.0)

  if mode ~= 0 then
    pd.timer.new(10, function()
      currentAudio:pause()
      currentAudio:setOffset(0)
      currentAudio:play()
    end)
    currentAudio:play()
  else
    getLengthVar = 0
    currentFilePath = ""
    pd.setAutoLockDisabled(false)
  end
end

function handleSongEnd() -- fix literally everything :) have fun future aiden - i did it past me! aren't you proud of me?
  songEndErrorCounter = songEndErrorCounter + 1

  -- If the function has been called more than once in 100 frames, return immediately
  if songEndErrorCounter > 5 then
    actualSongEnd()
    return
  end

  -- Reset the counter after 100 frames
  pd.timer.new(300, function()
    songEndErrorCounter = 0
  end)

  if currentAudio:getLength() ~= nil and (math.abs(currentAudio:getOffset() - currentAudio:getLength()) <= 5) and (math.abs(getLengthVar - currentAudio:getLength()) <= 5) then
    actualSongEnd()
  else
    currentAudio:pause()
    currentAudio:setOffset(math.floor(saveSongSpot2 + 0.5))
    currentAudio:play()

    safeToReset = false
    pd.timer.new(100, function()
      safeToReset = true
    end)
  end
end
