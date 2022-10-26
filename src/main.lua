import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"
import "CoreLibs/timer"
import "funcs"
-- import "crankFuncs"

local gfx <const> = playdate.graphics

playdate.file.mkdir("/music/")
dir = "/music/"
lastdirs = {}
files = playdate.file.listFiles(dir, false)

local playingGraphic = gfx.image.new("img/playing")
local pausedGraphic = gfx.image.new("img/paused")

dosFnt = playdate.graphics.font.new("fnt/dos")

currentAudio = playdate.sound.fileplayer.new()
currentFilePath,currentFileName,currentFileDir,modeString = "","","","none"
lastOffset,currentPos,songToHighlightRow,audioLen,lastScreenMode = 0,1,0,0,0
darkMode,showInfoEverywhere = true,false
audioFiles,lastSongDirs,lastSongNames = {},{},{}
mode = 0 -- 0 is none, 1 is shuffle, 2 is loop folder, 3 is loop song
screenMode = 0 -- 0 is files, 1 is playing, 2 is settings
clockMode = false -- true is 24 hr, false is 12 hr
keyTimer = nil
lockTimer = nil
lockScreenTime = 2 -- minutes
lockScreen = false
locked = false

settings = newSettingsList()

bgColor = gfx.kColorBlack
color = gfx.kColorWhite
dMColor1 = gfx.kDrawModeFillWhite
dMColor2 = gfx.kDrawModeCopy

print("-----------------------------------------------------------------------")
print("Hey there, friend! Have fun debugging / hacking my app! :D - nanobot567")
print("-----------------------------------------------------------------------")

gfx.setColor(color)
gfx.clear(bgColor)
gfx.setImageDrawMode(dMColor1)
gfx.drawText("no files!",0,0)
gfx.setImageDrawMode(dMColor2)

fileList = playdate.ui.gridview.new(0, 10)
fileList.backgroundImage = playdate.graphics.nineSlice.new('img/scrollimg', 20, 23, 92, 20)
fileList:setNumberOfRows(#files)
fileList:setScrollDuration(250)
fileList:setCellPadding(0, 0, 5, 10)
fileList:setContentInset(24, 24, 13, 11)

function fileList:drawCell(section, row, column, selected, x, y, width, height)
    local toWrite = files[row]
    if files[row] ~= nil then
        if selected then
            gfx.fillRoundRect(x, y, width, 20, 4)
            gfx.setImageDrawMode(dMColor2)
        else
            gfx.setImageDrawMode(dMColor1)
        end

        if files[row] == currentFileName and dir == currentFileDir then
            toWrite = "*"..files[row].."*"
        end
        gfx.drawText(toWrite, x+4, y+2, width, height, nil, "...")
    end
end

settingsList = playdate.ui.gridview.new(0, 10)
settingsList.backgroundImage = playdate.graphics.nineSlice.new('img/scrollimg', 20, 23, 92, 20)
settingsList:setNumberOfRows(#files)
settingsList:setScrollDuration(250)
settingsList:setCellPadding(0, 0, 5, 10)
settingsList:setContentInset(24, 24, 13, 11)

function settingsList:drawCell(section, row, column, selected, x, y, width, height)
    local toWrite = settings[row]
    if settings[row] ~= nil then
        if selected then
            gfx.fillRoundRect(x, y, width, 20, 4)
            gfx.setImageDrawMode(dMColor2)
        else
            gfx.setImageDrawMode(dMColor1)
        end

        if settings[row] == currentFileName and dir == currentFileDir then
            toWrite = "*"..settings[row].."*"
        end
        gfx.drawText(toWrite, x+4, y+2, width, height, nil, "...")
    end
end

local menu = playdate.getSystemMenu()

local playingMenuItem, error = menu:addMenuItem("now playing", swapScreenMode)
local modeMenuItem, error = menu:addOptionsMenuItem("mode", {"none","shuffle","loop folder","loop one"}, "none", handleMode)
local settingsModeMenuItem, error = menu:addMenuItem("settings", function()
    if screenMode ~= 2 then
        lastScreenMode = screenMode
        screenMode = 2
        settingsList:setSelectedRow(1)
    else
        screenMode = lastScreenMode
    end
end)


if files[1] == nil then
    table.insert(files,"no files!")
    playdate.stop()
end

currentAudio:setRate(1.0)

function playdate.update()
    playdate.timer.updateTimers()

    if locked == false then
        gfx.clear(bgColor)

        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
        if currentAudio:isPlaying() == true then
            playingGraphic:draw(0,220)
        else
            pausedGraphic:draw(0,220)
        end
        gfx.setImageDrawMode(dMColor1)
    else
        gfx.drawTextInRect("locked! press a and b to unlock...",0,110,400,240,nil,nil,kTextAlignment.center,nil)
        dosFnt:drawTextAligned("musik "..playdate.metadata.version.." epsilon", 400, 232, kTextAlignment.right, nil)
    end
    

    local btnState = playdate.getButtonState()

    if btnState ~= 0 and lockScreen == true and locked ~= true then
        lockTimer:reset()
    elseif btnState == 48 and locked == true then
        locked = false
        lockTimer = playdate.timer.new((lockScreenTime*60)*1000, lockScreenFunc)
        playdate.wait(350)
        gfx.clear(bgColor)
    end

    -- playdate.drawFPS(0,0)
    if showInfoEverywhere == true then
        drawInfo()
    end

    if locked ~= true then
        if screenMode == 0 then
            playingMenuItem:setTitle("now playing")
            settingsModeMenuItem:setTitle("settings")
            dosFnt:drawTextAligned("musik "..playdate.metadata.version.." epsilon", 400, 232, kTextAlignment.right, nil)

            gfx.drawRoundRect(20,13,360,209,4)

            files = playdate.file.listFiles(dir, false)
            fileList:setNumberOfRows(#files)
            curRow = fileList:getSelectedRow()

            if fileList.needsDisplay == true then
                fileList:drawInRect(0, 0, 400, 230)
            end

            if playdate.buttonJustPressed(playdate.kButtonRight) then
                local selRow = fileList:getSelectedRow()
                if selRow <= #files-4 then
                    fileList:setSelectedRow(selRow+4)
                else
                    fileList:setSelectedRow(#files)
                end
                selRow = fileList:getSelectedRow()
                fileList:scrollToRow(fileList:getSelectedRow())
            elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
                local selRow = fileList:getSelectedRow()
                if selRow > 5 then
                    fileList:setSelectedRow(selRow-4)
                else
                    fileList:setSelectedRow(1)
                end
                selRow = fileList:getSelectedRow()
                fileList:scrollToRow(fileList:getSelectedRow())
            elseif playdate.buttonJustPressed(playdate.kButtonA) then
                local curRow = fileList:getSelectedRow()
                if playdate.file.isdir(dir..files[curRow]) == true then
                    audioFiles = {}
                    fileList:setSelectedRow(1)

                    table.insert(lastdirs,dir)
                    dir = dir..files[curRow]

                    files = playdate.file.listFiles(dir, false)

                    for i=1,#files do
                        if string.find(files[i],"%.mp3") ~= nil or string.find(files[i],"%.pda") ~= nil then
                            table.insert(audioFiles,files[i])
                        end
                    end

                    fileList:setNumberOfRows(#files)
                else
                    if dir..files[curRow] == currentFilePath then
                        swapScreenMode()
                    else
                        if string.find(files[curRow],"%.mp3") ~= nil or string.find(files[curRow],"%.pda") ~= nil then
                            audioFiles = {}
                            for i=1,#files do
                                if string.find(files[curRow],"%.mp3") ~= nil or string.find(files[curRow],"%.pda") ~= nil then
                                    table.insert(audioFiles,files[i])
                                end
                            end

                            currentPos = curRow

                            currentAudio:pause()

                            table.insert(lastSongDirs,currentFileDir)
                            table.insert(lastSongNames,currentFileName)

                            currentAudio:load(dir..files[curRow])

                            audioLen = currentAudio:getLength()
                            playdate.setAutoLockDisabled(true)

                            currentFileName = files[curRow]
                            currentFileDir = dir
                            currentFilePath = dir..files[curRow]

                            currentAudio:setOffset(0)
                            currentAudio:play()

                            swapScreenMode()
                        end
                    end
                end
            elseif playdate.buttonJustPressed(playdate.kButtonB) then
                curRow = fileList:getSelectedRow()

                if dir == "/music/" then
                    swapScreenMode()
                else
                    dir = lastdirs[#lastdirs]
                    files = playdate.file.listFiles(dir, false)

                    table.remove(lastdirs,#lastdirs)

                    fileList:setSelectedRow(1)
                end

                audioFiles = {}

                for i=1,#files do
                    if string.find(files[curRow],"%.mp3") ~= nil or string.find(files[curRow],"%.pda") ~= nil then
                        table.insert(audioFiles,files[i])
                    end
                end
            end
        elseif screenMode == 1 then
            playingMenuItem:setTitle("files")
            settingsModeMenuItem:setTitle("settings")
            gfx.setImageDrawMode(dMColor1)
            audioLen = currentAudio:getLength()
            if audioLen ~= nil then
                gfx.drawTextInRect(currentFileName,0,110,400,240,nil,nil,kTextAlignment.center,nil)
                gfx.drawTextInRect((formatSeconds(currentAudio:getOffset()).." / "..formatSeconds(audioLen)),0,220,400,20,nil,nil,kTextAlignment.center,nil)
            else
                gfx.drawTextInRect("nothing playing",0,220,400,20,nil,nil,kTextAlignment.center,nil)
            end

            gfx.drawLine(0,10,400,10)
            gfx.drawTextInRect(modeString,0,220,400,20,nil,nil,kTextAlignment.right,nil)

            if showInfoEverywhere == false then
                drawInfo()
            end

            if playdate.buttonJustPressed(playdate.kButtonLeft) then
                if currentAudio:getOffset()-5 ~= audioLen then
                    lastOffset = currentAudio:getOffset()
                    if audioLen ~= nil then
                        currentAudio:setOffset(lastOffset-5)
                        lastOffset = currentAudio:getOffset()
                    end
                end
            elseif playdate.buttonJustPressed(playdate.kButtonRight) then
                if currentAudio:getOffset()+5 ~= audioLen then
                    lastOffset = currentAudio:getOffset()
                    if audioLen ~= nil then
                        currentAudio:setOffset(lastOffset+5)
                        lastOffset = currentAudio:getOffset()
                    end
                end
            elseif playdate.buttonJustPressed(playdate.kButtonUp) then
                if currentAudio:getOffset() <= 1 then
                    if lastSongDirs[#lastSongDirs] ~= "" then
                        currentAudio:pause()
                        currentAudio:load(lastSongDirs[#lastSongDirs]..lastSongNames[#lastSongNames])
                        currentAudio:setOffset(0)
                        currentFilePath = lastSongDirs[#lastSongDirs]..lastSongNames[#lastSongNames]
                        currentFileDir = lastSongDirs[#lastSongDirs]
                        currentFileName = lastSongNames[#lastSongNames]

                        audioLen = currentAudio:getLength()
                        currentAudio:play()

                        table.remove(lastSongDirs,#lastSongDirs)
                        table.remove(lastSongNames,#lastSongNames)
                    end
                else
                    currentAudio:setOffset(0)
                end

                
            elseif playdate.buttonJustPressed(playdate.kButtonDown) then
                if currentAudio:getOffset() > 5.5 then
                    currentAudio:stop()
                end
            end

            if playdate.buttonJustPressed(playdate.kButtonA) then
                if audioLen ~= nil then
                    if currentAudio:isPlaying() == true then
                        lastOffset = currentAudio:getOffset()
                        currentAudio:pause()
                        playdate.setAutoLockDisabled(false)
                    else
                        currentAudio:setOffset(lastOffset)
                        currentAudio:play()
                        playdate.setAutoLockDisabled(true)
                    end
                end
            elseif playdate.buttonJustPressed(playdate.kButtonB) then
                swapScreenMode()
            end
        elseif screenMode == 2 then
            dosFnt:drawTextAligned("musik "..playdate.metadata.version.." epsilon", 400, 232, kTextAlignment.right, nil)

            playingMenuItem:setTitle("files")
            settingsModeMenuItem:setTitle("back")
            gfx.drawRoundRect(20,13,360,209,4)

            curRow = fileList:getSelectedRow()
            settingsList:setNumberOfRows(#settings)

            if settingsList.needsDisplay == true then
                settingsList:drawInRect(0, 0, 400, 230)
            end
            
            if playdate.buttonJustPressed(playdate.kButtonUp) then
                settingsList:selectPreviousRow()
                settingsList:scrollToRow(settingsList:getSelectedRow())
            elseif playdate.buttonJustPressed(playdate.kButtonDown) then
                settingsList:selectNextRow()
                settingsList:scrollToRow(settingsList:getSelectedRow())
            end

            if playdate.buttonJustPressed(playdate.kButtonA) then
                local row = settingsList:getSelectedRow()
                if row == 1 then
                    darkMode = not darkMode
                    swapColorMode(darkMode)
                elseif row == 2 then
                    clockMode = not clockMode
                elseif row == 3 then
                    showInfoEverywhere = not showInfoEverywhere
                elseif row == 4 then
                    lockScreen = not lockScreen
                    if lockScreen == true then
                        lockTimer = playdate.timer.new((lockScreenTime*60)*1000, lockScreenFunc)
                    end
                elseif row == 5 then
                    if lockScreenTime >= 1 and lockScreenTime ~= 5 then
                        lockScreenTime += 1
                    elseif lockScreenTime == 5 then
                        lockScreenTime = 1
                    end
                    lockTimer = playdate.timer.new((lockScreenTime*60)*1000, lockScreenFunc)
                end

                settings = newSettingsList()
            elseif playdate.buttonJustPressed(playdate.kButtonB) then
                screenMode = lastScreenMode
            end
        end
    end
        -- updateCrank()
end

currentAudio:setFinishCallback(handleSongEnd)
currentAudio:setStopOnUnderrun(false)