-- musik by nanobot567. feel free to copy / share this code, just give credit please! :)

-- small text font on card-pressed.png is consolas 9

import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"
import "CoreLibs/timer"
import "funcs"
-- import "crankFuncs"

local gfx <const> = playdate.graphics
local disp <const> = playdate.display
local timer <const> = playdate.timer
local fs <const> = playdate.file

fs.mkdir("/music/")
fs.mkdir("/data/")
dir = "/music/"
lastdirs = {}
files = fs.listFiles(dir, false)

local playingGraphic = gfx.image.new("img/playing")
local pausedGraphic = gfx.image.new("img/paused")
local menuGraphic = gfx.image.new("img/menu")
dosFnt = gfx.font.new("fnt/dos")

playdate.setMenuImage(menuGraphic)

currentAudio = playdate.sound.fileplayer.new()
currentFilePath,currentFileName,currentFileDir,modeString = "","","","none"
lastOffset,currentPos,songToHighlightRow,audioLen,lastScreenMode = 0,1,0,0,0
darkMode,showInfoEverywhere = true,false
audioFiles,lastSongDirs,lastSongNames = {},{},{}
mode = 0 -- 0 is none, 1 is shuffle, 2 is loop folder, 3 is loop song, 4 is queue
screenMode = 0 -- 0 is files, 1 is playing, 2 is settings
clockMode = false -- true is 24 hr, false is 12 hr
upKeyTimer = nil
downKeyTimer = nil
lockTimer = nil
lockScreenTime = 2 -- minutes
lockScreen = false
locked = false
showVersion = true
screenRoundness = 4

queueList = {}
queueListDirs = {}
queueListNames = {}

bgColor = gfx.kColorBlack
color = gfx.kColorWhite
dMColor1 = gfx.kDrawModeFillWhite
dMColor2 = gfx.kDrawModeCopy

for i=1,#files do
    if findSupportedTypes(files[curRow]) then
        table.insert(audioFiles,files[i])
    end
end

print("-----------------------------------------------------------------------")
print("Hey there, friend! Have fun debugging / hacking my app! :D - nanobot567")
print("-----------------------------------------------------------------------")

loadSettings()
swapColorMode(darkMode)
settings = newSettingsList()

gfx.setColor(color)
gfx.clear(bgColor)
gfx.setImageDrawMode(dMColor1)
gfx.drawText("no files!",0,0)
gfx.setImageDrawMode(dMColor2)

fileList = playdate.ui.gridview.new(0, 10)
fileList.backgroundImage = gfx.nineSlice.new('img/scrollimg', 1, 1, 10, 10)
fileList:setNumberOfRows(#files)
fileList:setScrollDuration(250)
fileList:setCellPadding(0, 0, 5, 10)
fileList:setContentInset(24, 24, 13, 11)

function fileList:drawCell(section, row, column, selected, x, y, width, height)
    local toWrite = fixFormatting(files[row])
    if files[row] ~= nil then
        if selected then
            gfx.fillRoundRect(x, y, width, 20, 4)
            gfx.setImageDrawMode(dMColor2)
        else
            gfx.setImageDrawMode(dMColor1)
        end

        if (files[row] == currentFileName and dir == currentFileDir) then
            toWrite = "*"..toWrite.."*"
        elseif inTable(queueList, dir..files[row]) then
            toWrite = "_"..toWrite.."_"
        end
        gfx.drawText(toWrite, x+4, y+2, width, height, nil, "...")
    end
end

settingsList = playdate.ui.gridview.new(0, 10)
settingsList.backgroundImage = gfx.nineSlice.new('img/scrollimg', 1, 1, 10, 10)
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
            toWrite = "*"..toWrite.."*"
        end
        gfx.drawText(toWrite, x+4, y+2, width, height, nil, "...")
    end
end

local menu = playdate.getSystemMenu()

local playingMenuItem, error = menu:addMenuItem("now playing", swapScreenMode)
modeMenuItem, error = menu:addOptionsMenuItem("mode", {"none","shuffle","loop folder","loop one","queue"}, "none", handleMode)
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
    timer.updateTimers()

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
        gfx.clear(bgColor)
        gfx.drawTextInRect("locked! hold a and b to unlock...",0,110,400,240,nil,nil,kTextAlignment.center,nil)
    end

    if showVersion == true and screenMode ~= 1 then
        dosFnt:drawTextAligned("musik "..playdate.metadata.version.." zeta", 400, 232, kTextAlignment.right, nil)
    end
    

    local btnState = playdate.getButtonState()

    if btnState ~= 0 and lockScreen == true and locked == false then
        lockTimer:reset()
    end
    
    if btnState == 48 and locked == true then
        locked = false
        disp.setRefreshRate(30)
        lockTimer = timer.new((lockScreenTime*60)*1000, lockScreenFunc)
        playdate.wait(350)
        gfx.clear(bgColor)
    end

    if showInfoEverywhere == true then
        drawInfo()
    end

    if locked ~= true then
        if screenMode == 0 or screenMode == 3 then
            playingMenuItem:setTitle("now playing")
            settingsModeMenuItem:setTitle("settings")

            gfx.drawRoundRect(20,13,360,209,screenRoundness)

            files = fs.listFiles(dir, false)
            fileList:setNumberOfRows(#files)
            curRow = fileList:getSelectedRow()

            if fileList.needsDisplay == true then
                fileList:drawInRect(0, 0, 400, 230)
            end

            if playdate.buttonJustPressed("right") then
                if curRow <= #files-4 then
                    fileList:setSelectedRow(curRow+4)
                else
                    fileList:setSelectedRow(#files)
                end
                fileList:scrollToRow(fileList:getSelectedRow())
            elseif playdate.buttonJustPressed("left") then
                if curRow ~= 1 then
                    if curRow > 5 then
                        fileList:setSelectedRow(curRow-4)
                    else
                        fileList:setSelectedRow(1)
                    end
                    fileList:scrollToRow(fileList:getSelectedRow())
                else
                    bAction()
                end
            elseif playdate.buttonJustPressed("a") then
                if fs.isdir(dir..files[curRow]) == true then
                    audioFiles = {}
                    fileList:setSelectedRow(1)

                    table.insert(lastdirs,dir)
                    dir = dir..files[curRow]

                    files = fs.listFiles(dir, false)

                    for i=1,#files do
                        if findSupportedTypes(files[i]) then
                            table.insert(audioFiles,files[i])
                        end
                    end

                    fileList:setNumberOfRows(#files)
                else
                    if dir..files[curRow] == currentFilePath then
                        swapScreenMode()
                    else
                        if findSupportedTypes(files[curRow]) then
                            audioFiles = {}
                            for i=1,#files do
                                if findSupportedTypes(files[curRow]) then
                                    table.insert(audioFiles,files[i])
                                end
                            end

                            currentPos = curRow

                            if screenMode ~= 3 then
                                currentAudio:pause()

                                table.insert(lastSongDirs,currentFileDir)
                                table.insert(lastSongNames,currentFileName)

                                currentAudio:load(dir..files[curRow])

                                audioLen = currentAudio:getLength()
                                playdate.setAutoLockDisabled(true)

                                currentFileName = files[curRow]
                                currentFileDir = dir
                                currentFilePath = dir..files[curRow]

                                currentAudio:setRate(1.0)
                                currentAudio:setOffset(0)
                                currentAudio:play()

                                swapScreenMode()
                            else
                                if files[curRow] == ".." then
                                    bAction()
                                else
                                    table.insert(queueList, dir..files[curRow])
                                    table.insert(queueListDirs, dir)
                                    table.insert(queueListNames, files[curRow])
                                end
                            end
                        end
                    end
                end
            elseif playdate.buttonJustPressed("b") then
                if screenMode ~= 3 then
                    bAction()
                else
                    if inTable(queueList, dir..files[curRow]) then
                        table.remove(queueList, indexOf(queueList, dir..files[curRow]))
                        table.remove(queueListDirs, indexOf(queueList, dir))
                        table.remove(queueListNames, indexOf(queueListNames, files[curRow]))
                    else
                        bAction()
                    end
                end
            end
        elseif screenMode == 1 then
            playingMenuItem:setTitle("files")
            settingsModeMenuItem:setTitle("settings")
            gfx.setImageDrawMode(dMColor1)
            audioLen = currentAudio:getLength()
            if audioLen ~= nil then
                gfx.drawTextInRect(fixFormatting(currentFileName),0,110,400,240,nil,nil,kTextAlignment.center,nil)
                gfx.drawTextInRect((formatSeconds(currentAudio:getOffset()).." / "..formatSeconds(audioLen)),0,220,400,20,nil,nil,kTextAlignment.center,nil)
            else
                gfx.drawTextInRect("nothing playing",0,220,400,20,nil,nil,kTextAlignment.center,nil)
            end

            gfx.drawLine(0,10,400,10)
            gfx.drawTextInRect(modeString,0,220,398,20,nil,nil,kTextAlignment.right,nil)

            if showInfoEverywhere == false then
                drawInfo()
            end

            if playdate.buttonJustPressed("left") then
                if currentAudio:getOffset()-5 > 0 then
                    lastOffset = currentAudio:getOffset()
                    if audioLen ~= nil then
                        currentAudio:setOffset(lastOffset-5)
                        lastOffset = currentAudio:getOffset()
                    end
                else
                    currentAudio:setOffset(0)
                end
            elseif playdate.buttonJustPressed("right") then
                if currentAudio:getOffset()+5 ~= audioLen then
                    lastOffset = currentAudio:getOffset()
                    if audioLen ~= nil then
                        currentAudio:setOffset(lastOffset+5)
                        lastOffset = currentAudio:getOffset()
                    end
                end
            elseif playdate.buttonJustPressed("up") then
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

                
            elseif playdate.buttonJustPressed("down") then
                if currentAudio:getOffset() > 5.5 then
                    handleSongEnd()
                end
            end

            if playdate.buttonJustPressed("a") then
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
            elseif playdate.buttonJustPressed("b") then
                swapScreenMode()
            end
        elseif screenMode == 2 then
            playingMenuItem:setTitle("files")
            settingsModeMenuItem:setTitle("back")
            gfx.drawRoundRect(20,13,360,209,screenRoundness)

            curRow = fileList:getSelectedRow()
            settingsList:setNumberOfRows(#settings)

            if settingsList.needsDisplay == true then
                settingsList:drawInRect(0, 0, 400, 230)
            end
            
            if playdate.buttonJustPressed("up") then
                settingsList:selectPreviousRow()
                settingsList:scrollToRow(settingsList:getSelectedRow())
            elseif playdate.buttonJustPressed("down") then
                settingsList:selectNextRow()
                settingsList:scrollToRow(settingsList:getSelectedRow())
            end

            if playdate.buttonJustPressed("a") then
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
                    lockScreen = not lockScreen
                    if lockScreen == true then
                        lockTimer = timer.new((lockScreenTime*60)*1000, lockScreenFunc)
                    end
                elseif row == 7 then
                    if lockScreenTime >= 1 and lockScreenTime ~= 5 then
                        lockScreenTime += 1
                    elseif lockScreenTime == 5 then
                        lockScreenTime = 1
                    end
                    lockTimer = timer.new((lockScreenTime*60)*1000, lockScreenFunc)
                end

                settings = newSettingsList()
            elseif playdate.buttonJustPressed("b") then
                screenMode = lastScreenMode
            end
        end
    end
        -- updateCrank()
end

function playdate.gameWillTerminate()
    saveSettings()
end

currentAudio:setFinishCallback(handleSongEnd)
currentAudio:setStopOnUnderrun(false)