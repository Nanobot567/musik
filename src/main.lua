-- musik by nanobot567. feel free to copy / share this code, just give credit please! :)

-- small text font on card-pressed.png is consolas 9

pd = playdate

import "CoreLibs/crank"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"
import "CoreLibs/timer"

import "utils"
import "input"
import "lists"
import "funcs"
-- import "crankFuncs"

local gfx <const> = pd.graphics
local disp <const> = pd.display
local timer <const> = pd.timer
local fs <const> = pd.file

fs.mkdir("/music/")
fs.mkdir("/data/")
dir = "/music/"
lastdirs = {}
files = fs.listFiles(dir, false)

local playingGraphic = gfx.image.new("img/playing")
local pausedGraphic = gfx.image.new("img/paused")
local menuGraphic = gfx.image.new("img/menu")
dosFnt = gfx.font.new("fnt/dos")

pd.setMenuImage(menuGraphic)

currentAudio = pd.sound.fileplayer.new()
currentFilePath, currentFileName, currentFileDir, modeString = "", "", "", "none"
lastOffset, currentPos, songToHighlightRow, audioLen, lastScreenMode = 0, 1, 0, 0, 0
darkMode, showInfoEverywhere = true, false
audioFiles, lastSongDirs, lastSongNames = {}, {}, {}
lastDirPos = { 1 }
mode = 0          -- 0 is none, 1 is shuffle, 2 is loop folder, 3 is loop song, 4 is queue
screenMode = 0    -- 0 is files, 1 is playing, 2 is settings
clockMode = false -- true is 24 hr, false is 12 hr
upKeyTimer = nil
downKeyTimer = nil
lockTimer = nil
lockScreenTime = 2 -- minutes
lockScreen = false
locked = false
showVersion = true
screenRoundness = 4
uiDesign = "new"
playPauseGraphicSwap = false

updateGetLength = true -- this resets the getLengthVar
getLengthVar = 0       -- this is conected to getLength()
saveSongSpot = 0
saveSongSpot2 = 0
safeToReset = true

queueList = {}
queueListDirs = {}
queueListNames = {}

bgColor = gfx.kColorBlack
color = gfx.kColorWhite
dMColor1 = gfx.kDrawModeFillWhite
dMColor2 = gfx.kDrawModeCopy

for i = 1, #files do
  if findSupportedTypes(files[curRow]) then
    table.insert(audioFiles, files[i])
  end
end

fileList:setNumberOfRows(#files)

print("-----------------------------------------------------------------------")
print("Hey there, friend! Have fun debugging / hacking my app! :D - nanobot567")
print("-----------------------------------------------------------------------")

loadSettings()
swapColorMode(darkMode)
settings = newSettingsList()

gfx.setColor(color)
gfx.clear(bgColor)

if files[1] == nil then
  gfx.setImageDrawMode(dMColor1)
  gfx.drawTextAligned("no files found!", 200, 10, kTextAlignment.center) -- updated the txt
  gfx.drawTextAligned("scan the code to view musik's documentation.", 200, 35, kTextAlignment.center)

  gfx.setImageDrawMode(gfx.kDrawModeNXOR) -- add a QR code to the add audio part of the GitHub repo info thing
  local addSongsQRImg = gfx.image.new("img/addSongsQR")
    assert(addSongsQRImg)

    addSongsQRImg:draw(120,65)

  gfx.setImageDrawMode(dMColor2)

  table.insert(files,"no files!")
  pd.stop()
end

local menu = pd.getSystemMenu()

local playingMenuItem, error = menu:addMenuItem("now playing", swapScreenMode)
modeMenuItem, error = menu:addOptionsMenuItem("mode", { "none", "shuffle", "loop folder", "loop one", "queue" }, "none",
  handleMode)
local settingsModeMenuItem, error = menu:addMenuItem("settings", function()
  if screenMode ~= 2 then
    lastScreenMode = screenMode
    screenMode = 2
    settingsList:setSelectedRow(1)
  else
    screenMode = lastScreenMode
  end
end)

currentAudio:setRate(1.0)

files = fs.listFiles(dir, false)

function pd.update()
  timer.updateTimers()
  gfx.clear(bgColor)

  if currentAudio:getLength() ~= nil then           -- if its not nil then go ahead
    if getLengthVar < currentAudio:getLength() then -- always take the higher getLength() and show that
      getLengthVar = currentAudio:getLength()
    end

    if currentAudio:getOffset() >= (getLengthVar * .9) then -- if the song is at or past 90% switch to actual length estimate after it has worked out its kinks
      getLengthVar = currentAudio:getLength()
    end

    if updateGetLength == true then -- reset var for next songs 
      getLengthVar = 1
      updateGetLength = false
    end
  end

  if locked == true then
    gfx.drawTextInRect("locked! hold a and b to unlock...", 0, 110, 400, 240, nil, nil, kTextAlignment.center, nil)
  end

  if showVersion == true and screenMode ~= 1 then
    local musikTextX, musikTextY, musikTextAlignment = 200, 227, kTextAlignment.center

    if uiDesign == "classic" then
      musikTextX = 400
      musikTextY = 232
      musikTextAlignment = kTextAlignment.right
    end

    dosFnt:drawTextAligned("musik " .. pd.metadata.version .. " zeta", musikTextX, musikTextY, musikTextAlignment, nil)
  end

  local btnState = pd.getButtonState()

  if btnState ~= 0 and lockScreen == true and locked == false then
    lockTimer:reset()
    lockTimer.duration = (lockScreenTime * 60) * 1000
    lockTimer.timerEndedCallback = lockScreenFunc
  end

  if btnState == 48 and locked == true then
    locked = false
    disp.setRefreshRate(30)
    lockTimer = timer.new((lockScreenTime * 60) * 1000, lockScreenFunc)
    pd.wait(350)
    gfx.clear(bgColor)
  end

  if showInfoEverywhere == true then
    drawInfo()
  end

  if locked ~= true then
    if screenMode == 0 or screenMode == 3 then
      playingMenuItem:setTitle("now playing")
      settingsModeMenuItem:setTitle("settings")

      fileList:setNumberOfRows(#files)
      curRow = fileList:getSelectedRow()

      if fileList.needsDisplay == true then
        fileList:drawInRect(0, 0, 400, 230)
      end

      gfx.drawRoundRect(20, 13, 360, 209, screenRoundness)

      if pd.buttonJustPressed("right") then
        if curRow <= #files - 4 then
          fileList:setSelectedRow(curRow + 4)
        else
          fileList:setSelectedRow(#files)
        end
        fileList:scrollToRow(fileList:getSelectedRow())
      elseif pd.buttonJustPressed("left") then
        if curRow ~= 1 then
          if curRow > 5 then
            fileList:setSelectedRow(curRow - 4)
          else
            fileList:setSelectedRow(1)
          end
          fileList:scrollToRow(fileList:getSelectedRow())
        else
          bAction()
        end
      elseif pd.buttonJustPressed("a") then
        if files[curRow] == ".." and curRow == 1 then
          bAction()
        elseif fs.isdir(dir .. files[curRow]) == true then
          audioFiles = {}
          table.insert(lastDirPos, curRow)
          fileList:setSelectedRow(1)
          fileList:scrollToRow(1)

          table.insert(lastdirs, dir)
          dir = dir .. files[curRow]

          files = fs.listFiles(dir, false)

          for i = 1, #files do
            if findSupportedTypes(files[i]) then
              table.insert(audioFiles, files[i])
            end
          end

          if dir ~= "/music/" then
            table.insert(files, 1, "..")
          end

          fileList:setNumberOfRows(#files)
        else
          if dir .. files[curRow] == currentFilePath then
            swapScreenMode()
          else
            if findSupportedTypes(files[curRow]) then
              audioFiles = {}
              for i = 1, #files do
                if findSupportedTypes(files[curRow]) then
                  table.insert(audioFiles, files[i])
                end
              end
              currentPos = curRow

              if screenMode ~= 3 then
                saveSongSpot = 0
                updateGetLength = true

                currentAudio:pause()

                table.insert(lastSongDirs, currentFileDir)
                table.insert(lastSongNames, currentFileName)

                currentAudio:load(dir .. files[curRow])

                audioLen = getLengthVar
                pd.setAutoLockDisabled(true)

                currentFileName = files[curRow]
                currentFileDir = dir
                currentFilePath = dir .. files[curRow]

                currentAudio:setRate(1.0)
                currentAudio:setOffset(0)
                currentAudio:play()

                swapScreenMode()
              else
                table.insert(queueList, dir .. files[curRow])
                table.insert(queueListDirs, dir)
                table.insert(queueListNames, files[curRow])
              end
            end
          end
        end
      elseif pd.buttonJustPressed("b") then
        if screenMode ~= 3 then
          bAction()
        else
          if inTable(queueList, dir .. files[curRow]) then
            table.remove(queueList, indexOf(queueList, dir .. files[curRow]))
            table.remove(queueListDirs, indexOf(queueList, dir))
            table.remove(queueListNames, indexOf(queueListNames, files[curRow]))
          else
            bAction()
          end
        end
      end

      gfx.setImageDrawMode(gfx.kDrawModeNXOR)

      if not playPauseGraphicSwap then
        if currentAudio:isPlaying() == true then
          playingGraphic:draw(0, 220)
        else
          pausedGraphic:draw(0, 220)
        end
      else
        if currentAudio:isPlaying() == true then
          pausedGraphic:draw(0, 220)
        else
          playingGraphic:draw(0, 220)
        end
      end

      gfx.setImageDrawMode(dMColor1)
    elseif screenMode == 1 then
      playingMenuItem:setTitle("files")
      settingsModeMenuItem:setTitle("settings")
      gfx.setImageDrawMode(dMColor1)

      local secondsX, secondsY, modeStringX, modeStringY, playingGraphicX, playingGraphicY = 200, 211, 388, 212, 10, 210

      if uiDesign == "classic" then
        secondsX = 200
        secondsY = 220
        modeStringX = 398
        modeStringY = 220
        playingGraphicX = 0
        playingGraphicY = 220
      end

      audioLen = getLengthVar
      if audioLen ~= nil and audioLen ~= 0 then
        gfx.drawTextInRect(fixFormatting(currentFileName), 20, 110, 360, 20, nil, "...", kTextAlignment.center)
        gfx.drawTextAligned((formatSeconds(currentAudio:getOffset()) .. " / " .. formatSeconds(audioLen)), secondsX, secondsY, kTextAlignment.center)
      else
        gfx.drawTextAligned("nothing playing", 200, 211, kTextAlignment.center)
      end

      if uiDesign == "new" then
        gfx.drawRoundRect(5, 205, 390, 30, screenRoundness)
      end

      gfx.drawLine(0, 10, 400, 10)
      gfx.drawTextAligned(modeString, modeStringX, modeStringY, kTextAlignment.right)

      if showInfoEverywhere == false then
        drawInfo()
      end

      if pd.buttonJustPressed("up") or pd.buttonJustPressed("left") then
        if currentAudio:getOffset() <= 1 then
          if lastSongDirs[#lastSongDirs] ~= "" and #lastSongDirs ~= 0 then
            currentAudio:pause()
            currentAudio:load(lastSongDirs[#lastSongDirs] .. lastSongNames[#lastSongNames])
            currentAudio:setOffset(0)
            currentFilePath = lastSongDirs[#lastSongDirs] .. lastSongNames[#lastSongNames]
            currentFileDir = lastSongDirs[#lastSongDirs]
            currentFileName = lastSongNames[#lastSongNames]

            audioLen = getLengthVar
            currentAudio:play()

            table.remove(lastSongDirs, #lastSongDirs)
            table.remove(lastSongNames, #lastSongNames)
          end
        else
          currentAudio:setOffset(0)
        end
      elseif pd.buttonJustPressed("down") or pd.buttonJustPressed("right") then
        canGoNext = true
        actualSongEnd() -- pausing and starting handeled here | changed to actualSongEnd to make sure song ends
      end

      if pd.buttonJustPressed("a") then
        if audioLen ~= nil then
          if currentAudio:isPlaying() == true then
            lastOffset = currentAudio:getOffset()
            currentAudio:pause()
            pd.setAutoLockDisabled(false)
          else
            currentAudio:setOffset(lastOffset)
            currentAudio:play()
            pd.setAutoLockDisabled(true)
          end
        end
      elseif pd.buttonJustPressed("b") then
        swapScreenMode()
      end

      gfx.setImageDrawMode(gfx.kDrawModeNXOR)

      if not playPauseGraphicSwap then
        if currentAudio:isPlaying() == true then
          playingGraphic:draw(playingGraphicX, playingGraphicY)
        else
          pausedGraphic:draw(playingGraphicX, playingGraphicY)
        end
      else
        if currentAudio:isPlaying() == true then
          pausedGraphic:draw(playingGraphicX, playingGraphicY)
        else
          playingGraphic:draw(playingGraphicX, playingGraphicY)
        end
      end
      gfx.setImageDrawMode(dMColor1)
    elseif screenMode == 2 then
      playingMenuItem:setTitle("files")
      settingsModeMenuItem:setTitle("back")
      gfx.drawRoundRect(20, 13, 360, 209, screenRoundness)

      curRow = fileList:getSelectedRow()
      settingsList:setNumberOfRows(#settings)

      if settingsList.needsDisplay == true then
        settingsList:drawInRect(0, 0, 400, 230)
      end

      gfx.drawRoundRect(20, 13, 360, 209, screenRoundness)

      if pd.buttonJustPressed("up") then
        settingsList:selectPreviousRow()
        settingsList:scrollToRow(settingsList:getSelectedRow())
      elseif pd.buttonJustPressed("down") then
        settingsList:selectNextRow()
        settingsList:scrollToRow(settingsList:getSelectedRow())
      end

      if pd.buttonJustPressed("a") then
        local row = settingsList:getSelectedRow()
        if row == 1 then
          darkMode = not darkMode
          swapColorMode(darkMode)
        elseif row == 2 then
          clockMode = not clockMode
        elseif row == 3 then
          showInfoEverywhere = not showInfoEverywhere
        elseif row == 4 then
          showVersion = not showVersion
        elseif row == 5 then
          if screenRoundness >= 1 and screenRoundness < 8 then
            if screenRoundness == 1 or screenRoundness == 6 then
              screenRoundness += 2
            else
              screenRoundness += 1
            end
          elseif screenRoundness >= 8 then
            screenRoundness = 1
          end
        elseif row == 6 then
          if uiDesign == "new" then
            uiDesign = "classic"
          else
            uiDesign = "new"
          end
        elseif row == 7 then
          playPauseGraphicSwap = not playPauseGraphicSwap
        elseif row == 8 then
          lockScreen = not lockScreen
          if lockScreen == true then
            lockTimer = timer.new((lockScreenTime * 60) * 1000, lockScreenFunc)
          end
        elseif row == 9 then
          if lockScreenTime >= 1 and lockScreenTime ~= 5 then
            lockScreenTime += 1
          elseif lockScreenTime == 5 then
            lockScreenTime = 1
          end
          lockTimer = timer.new((lockScreenTime * 60) * 1000, lockScreenFunc)
        end

        settings = newSettingsList()
      elseif pd.buttonJustPressed("b") then
        screenMode = lastScreenMode
      end

      if pd.buttonJustPressed("left") or pd.buttonJustPressed("right") or pd.buttonJustPressed("up") or pd.buttonJustPressed("down") or pd.buttonJustPressed("a") or pd.buttonJustPressed("b") then
        saveSongSpot = currentAudio:getOffset() -- if you press a button save the curnet song play point
        pd.timer.new(40, function()
          if safeToReset == true then
            saveSongSpot2 = saveSongSpot
          end
        end)
      end
    end
  end

  updateCrank()
end

function pd.gameWillTerminate()
  saveSettings()
end

currentAudio:setFinishCallback(handleSongEnd)
currentAudio:setStopOnUnderrun(false)
