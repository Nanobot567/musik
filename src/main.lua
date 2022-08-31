import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

playdate.file.mkdir("/music/")
dir = "/music/"
lastdirs = {}
files = playdate.file.listFiles(dir, false)

local playingGraphic = gfx.image.new("img/playing")
local pausedGraphic = gfx.image.new("img/paused")

dosFnt = playdate.graphics.font.new("fnt/dos")

local currentAudio = playdate.sound.fileplayer.new()
local currentFilePath = ""
local currentFileName = ""
local lastOffset = 0
local currentPos = 1
local modeString = "none"
local darkMode = true
audioFiles = {}
mode = 0 -- 0 is none, 1 is shuffle, 2 is loop folder, 3 is loop song
screenMode = 0 -- 0 is files, 1 is playing, 2 is settings
audioLen = 0
keyTimer = nil

bgColor = gfx.kColorBlack
color = gfx.kColorWhite
dMColor1 = gfx.kDrawModeFillWhite
dMColor2 = gfx.kDrawModeCopy

print("----------------------------------------------------")
print("Hey there, friend! Have fun debugging / hacking my app! :D")
print("----------------------------------------------------")

gfx.setColor(color)
gfx.clear(bgColor)
gfx.setImageDrawMode(dMColor1)
gfx.drawText("no files!",0,0)
gfx.setImageDrawMode(dMColor2)

local menu = playdate.getSystemMenu()

function handleMode(str) -- add queue mode
    print("mode is now"..str)
    modeString = str

    if str == "shuffle" then
        mode = 1
    elseif str == "loop folder" then
        mode = 2
    elseif str == "loop one" then
        mode = 3
    else
        mode = 0
    end
end

local playingMenuItem, error = menu:addMenuItem("now playing", function()
    if screenMode == 0 then
        screenMode = 1
    else
        screenMode = 0
    end
end)
local modeMenuItem, error = menu:addOptionsMenuItem("mode", {"none","shuffle","loop folder","loop one"}, "none", handleMode)
local colorModeMenuItem, error = menu:addCheckmarkMenuItem("dark", darkMode, function ()
    if darkMode == true then
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
end)

fileList = playdate.ui.gridview.new(0, 10)
fileList.backgroundImage = playdate.graphics.nineSlice.new('img/scrollimg', 20, 23, 92, 20)
fileList:setNumberOfRows(#files)
fileList:setScrollDuration(250)
fileList:setCellPadding(0, 0, 5, 10)
fileList:setContentInset(24, 24, 13, 11)

function fileList:drawCell(section, row, column, selected, x, y, width, height)
        if files[row] ~= nil then
            if selected then
                gfx.fillRoundRect(x, y, width, 20, 4)
                gfx.setImageDrawMode(dMColor2)
            else
                gfx.setImageDrawMode(dMColor1)
            end

            gfx.drawText(files[row], x+4, y+2, width, height, nil, "...")
        end
end


if files[1] == nil then
    table.insert(files,"no files!")
    playdate.stop()
end


function playdate.update()
    playdate.timer.updateTimers()
    gfx.clear(bgColor)

    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    if currentAudio:isPlaying() == true then
        playingGraphic:draw(0,220)
    else
        pausedGraphic:draw(0,220)
    end
    gfx.setImageDrawMode(dMColor1)

    -- playdate.drawFPS(0,0)

    if screenMode == 0 then
        dosFnt:drawTextAligned("musik "..playdate.metadata.version.." delta", 400, 232, kTextAlignment.right, nil)

        playingMenuItem:setTitle("now playing")
        gfx.drawRoundRect(20,13,360,209,4)

        curRow = fileList:getSelectedRow()
        files = playdate.file.listFiles(dir, false)
        fileList:setNumberOfRows(#files)

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
            fileList:scrollToRow(fileList:getSelectedRow())
        elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
            local selRow = fileList:getSelectedRow()
            if selRow > 5 then
                fileList:setSelectedRow(selRow-4)
            else
                fileList:setSelectedRow(1)
            end
            fileList:scrollToRow(fileList:getSelectedRow())
        elseif playdate.buttonJustPressed(playdate.kButtonA) then
            if playdate.file.isdir(dir..files[curRow]) == true then
                audioFiles = {}
                fileList:setSelectedRow(1)

                table.insert(lastdirs,dir)
                dir = dir..files[curRow]

                for i=1,#files do
                    if string.find(files[i],"%.mp3") ~= nil or string.find(files[i],"%.pda") ~= nil then
                        table.insert(audioFiles,files[i])
                    end
                end

                fileList:setNumberOfRows(#files)
            else
                if dir..files[curRow] == currentFilePath then
                    screenMode = 1
                else
                    if string.find(files[curRow],"%.mp3") ~= nil or string.find(files[curRow],"%.pda") ~= nil then
                        currentAudio:setRate(1.0)
                        for i=1,#files do
                            if string.find(files[curRow],"%.mp3") ~= nil or string.find(files[curRow],"%.pda") ~= nil then
                                table.insert(audioFiles,files[i])
                            end
                        end

                        currentPos = curRow
                        currentFilePath = dir..files[curRow]

                        if currentAudio:isPlaying() == true then
                            currentAudio:stop()
                            playdate.setAutoLockDisabled(false)
                        end

                        currentAudio:load(dir..files[curRow])
                        audioLen = currentAudio:getLength()
                        currentAudio:play()
                        playdate.setAutoLockDisabled(true)

                        currentFileName = files[curRow]
                        screenMode = 1
                    end
                end
            end
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            curRow = fileList:getSelectedRow()

            if dir ~= "/music/" then
                dir = lastdirs[#lastdirs]

                table.remove(lastdirs,#lastdirs)

                fileList:setSelectedRow(1)
            end
        end
    elseif screenMode == 1 then
        playingMenuItem:setTitle("files")
        gfx.setImageDrawMode(dMColor1)
        audioLen = currentAudio:getLength()
        if audioLen ~= nil then
            gfx.drawTextInRect(currentFileName,0,110,400,240,nil,nil,kTextAlignment.center,nil)
            gfx.drawTextInRect((formatSeconds(currentAudio:getOffset()).." / "..formatSeconds(audioLen)),0,220,400,20,nil,nil,kTextAlignment.center,nil)
            gfx.drawLine(0,10,400,10)
        else
            gfx.drawTextInRect("nothing playing",0,220,400,20,nil,nil,kTextAlignment.center,nil)
        end
        local time = playdate.getTime()
        if #tostring(time["hour"]) == 1 then
            time["hour"] = "0"..time["hour"]
        end

        if #tostring(time["minute"]) == 1 then
            time["minute"] = "0"..time["minute"]
        end

        local batteryPercent = playdate.getBatteryPercentage()

        if string.find(batteryPercent,"100.") then
            batteryPercent = "100"
        else
            batteryPercent = string.sub(string.gsub(batteryPercent,"%.",""),1,2)
        end

        local size = gfx.getTextSize(batteryPercent.."%",dosFnt)

        dosFnt:drawTextAligned(time["hour"]..":"..time["minute"],1,1,400,20,kTextAlignment.left,nil)
        dosFnt:drawTextAligned(batteryPercent.."%",401-size,1,400,20,kTextAlignment.right,nil)
        gfx.drawTextInRect(modeString,0,220,400,20,nil,nil,kTextAlignment.right,nil)
        gfx.setImageDrawMode(dMColor2)

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
            screenMode = 0
        end
    end
end

function split(inputstr,sep)
    t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        -- "([^"..sep.."]+)"
        table.insert(t, str)
    end

    return t
end

function handleSongEnd()
    if mode == 2 then
        if currentFileName == audioFiles[#audioFiles] then
            if playdate.file.isdir(dir..audioFiles[1]) == false then
                currentFileName = audioFiles[1]
                currentAudio:load(dir..audioFiles[1])
            end
        else
            if playdate.file.isdir(dir..audioFiles[currentPos+1]) == false then
                currentFileName = audioFiles[currentPos+1]
                currentAudio:load(dir..audioFiles[currentPos+1])
                currentPos += 1
            end
        end
    elseif mode == 1 then
        local randthing = math.random(1,#audioFiles)
        while currentFileName == audioFiles[randthing] do
            randthing = math.random(1,#audioFiles)
        end
        if playdate.file.isdir(dir..audioFiles[randthing]) == false then
            currentFileName = audioFiles[randthing]
            currentAudio:load(dir..audioFiles[randthing])
        end
    elseif mode == 3 then
    elseif mode == 0 then
        currentAudio = playdate.sound.fileplayer.new()
    end
    currentFilePath = dir..currentFileName

    audioLen = currentAudio:getLength()

    if mode ~= 0 then
        currentAudio:play()
    else
        currentFilePath = ""
        playdate.setAutoLockDisabled(false)
    end
end

function formatSeconds(seconds)
    local seconds = tonumber(seconds)
    
    if seconds <= 0 then
        return "0:00"
    else
        hours = string.format("%02.f", math.floor(seconds/3600))
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))
        return mins..":"..secs
    end
end



function playdate.downButtonDown()
    local function timerCallback()
        if fileList:getSelectedRow() ~= #files then
            fileList:selectNextRow(true)
        end
    end
    if screenMode == 0 then
        keyTimer = playdate.timer.keyRepeatTimerWithDelay(300,50,timerCallback)
    end
end

function playdate.downButtonUp()
    keyTimer:remove()
end

function playdate.upButtonDown()
    local function timerCallback()
        if fileList:getSelectedRow() ~= 1 then
            fileList:selectPreviousRow(true)
        end
    end
    if screenMode == 0 then
        keyTimer = playdate.timer.keyRepeatTimerWithDelay(300,50,timerCallback)
    end
end

function playdate.upButtonUp()
    keyTimer:remove()
end

currentAudio:setFinishCallback(handleSongEnd)