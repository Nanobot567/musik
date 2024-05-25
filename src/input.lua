-- functions that have to do with input

local pd <const> = playdate
local fs <const> = pd.file

function bAction()
  curRow = fileList:getSelectedRow()

  if dir == "/music/" then
    swapScreenMode()
  else
    local x = string.find(dir, "/") - 1
    local splitted = split(dir, "/")
    table.remove(splitted)
    for i = x, 0, -1 do
      lastdirs[i] = "/" .. table.concat(splitted, "/") .. "/"
      table.remove(splitted, #splitted)
    end

    dir = table.remove(lastdirs, #lastdirs)

    files = fs.listFiles(dir, false)

    if dir ~= "/music/" then
      table.insert(files, 1, "..")
    end

    local selRow = table.remove(lastDirPos)

    if selRow ~= nil then
      fileList:setSelectedRow(selRow)
      fileList:scrollToRow(selRow)
    end
  end

  audioFiles = {}

  for i = 1, #files do
    if files[curRow] ~= nil then
      if findSupportedTypes(files[curRow]) then
        table.insert(audioFiles, files[i])
      end
    end
  end
end

function pd.downButtonDown()
  local function timerCallback()
    if fileList:getSelectedRow() ~= #files then
      fileList:selectNextRow(true)
    end
  end
  if screenMode == 0 or screenMode == 3 then
    downKeyTimer = pd.timer.keyRepeatTimerWithDelay(300, 50, timerCallback)
  end
end

function pd.downButtonUp()
  if screenMode == 0 or screenMode == 3 then
    downKeyTimer:remove()
  end
end

function pd.upButtonDown()
  local function timerCallback()
    if fileList:getSelectedRow() ~= 1 then
      fileList:selectPreviousRow(true)
    end
  end
  if screenMode == 0 or screenMode == 3 then
    upKeyTimer = pd.timer.keyRepeatTimerWithDelay(300, 50, timerCallback)
  end
end

function pd.upButtonUp()
  if screenMode == 0 or screenMode == 3 then
    upKeyTimer:remove()
  end
end

function updateCrank()
  if screenMode == 0 or screenMode == 3 then
    local crankTicks = pd.getCrankTicks(8)

    if crankTicks == 1 then
      if fileList:getSelectedRow() ~= #files then
        fileList:selectNextRow(true)
      end
    elseif crankTicks == -1 then
      if fileList:getSelectedRow() ~= 1 then
        fileList:selectPreviousRow(true)
      end
    end
  end
end
