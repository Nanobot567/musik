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

-- dosFnt = playdate.graphics.font.new("fnt/dos")
-- playdate.graphics.setFont(dosFnt)

local currentAudio = playdate.sound.fileplayer.new()
local currentFilePath = ""
local currentFileName = ""
audioFiles = {}
mode = 0 -- 0 is none, 1 is shuffle, 2 is loop folder, 3 is loop song
local modeString = "none"
onPlayingScreen = false
local lastOffset = 0
local currentPos = 1
audioLen = 0
local darkMode = true

gfx.setColor(gfx.kColorWhite)

local menu = playdate.getSystemMenu()

function handleMode(str) -- add queue mode
    print(str)
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

    print("did mode")
end

local playingMenuItem, error = menu:addMenuItem("now playing", function()
    onPlayingScreen = not onPlayingScreen
end)
local modeMenuItem, error = menu:addOptionsMenuItem("mode", {"none","shuffle","loop folder","loop one"}, "none", handleMode)

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
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
            else
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
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
    gfx.clear(gfx.kColorBlack)

    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    if currentAudio:isPlaying() == true then
        playingGraphic:draw(0,220)
    else
        pausedGraphic:draw(0,220)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    if onPlayingScreen == false then
        playingMenuItem:setTitle("now playing")
        gfx.drawRect(20,13,360,209)

        curRow = fileList:getSelectedRow()
        files = playdate.file.listFiles(dir, false)
        fileList:setNumberOfRows(#files)

        if fileList.needsDisplay == true then
            fileList:drawInRect(0, 0, 400, 230)
        end

        if playdate.buttonJustPressed(playdate.kButtonDown) then
            fileList:selectNextRow(true)
        elseif playdate.buttonJustPressed(playdate.kButtonUp) then
            fileList:selectPreviousRow(true)
        elseif playdate.buttonJustPressed(playdate.kButtonA) then
            if playdate.file.isdir(dir..files[curRow]) == true then
                audioFiles = {}
                fileList:setSelectedRow(1)

                table.insert(lastdirs,dir)
                dir = dir..files[curRow]

                for i=1,#files do
                    if string.find(files[i],"%.mp3") ~= nil or string.find(files[i],"%.wav") ~= nil then
                        table.insert(audioFiles,files[i])
                    end
                end

                fileList:setNumberOfRows(#files)
            else
                if dir..files[curRow] == currentFilePath then
                    -- if currentAudio:isPlaying() == true then
                    --     lastOffset = currentAudio:getOffset()
                    --     currentAudio:pause()
                    -- else
                    --     currentAudio:setOffset(lastOffset)
                    --     currentAudio:play()
                    -- end
                    onPlayingScreen = true
                else
                    if string.find(files[curRow],"%.mp3") ~= nil or string.find(files[curRow],"%.wav") ~= nil then
                        for i=1,#files do
                            if string.find(files[curRow],"%.mp3") ~= nil or string.find(files[curRow],"%.wav") ~= nil then
                                table.insert(audioFiles,files[i])
                            end
                        end

                        currentPos = curRow
                        currentFilePath = dir..files[curRow]

                        if currentAudio:isPlaying() == true then
                            currentAudio:stop()
                        end

                        currentAudio:load(dir..files[curRow])
                        audioLen = currentAudio:getLength()
                        currentAudio:play()

                        currentFileName = files[curRow]
                        onPlayingScreen = true
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
    else
        playingMenuItem:setTitle("files")
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        audioLen = currentAudio:getLength()
        if audioLen ~= nil then
            gfx.drawTextInRect(currentFileName,0,0,400,240,nil,nil,kTextAlignment.center,nil)
            gfx.drawTextInRect((formatSeconds(currentAudio:getOffset()).." / "..formatSeconds(audioLen)),0,220,400,20,nil,nil,kTextAlignment.center,nil)
        else
            gfx.drawTextInRect("nothing playing",0,220,400,20,nil,nil,kTextAlignment.center,nil)
        end
        gfx.drawTextInRect(modeString,0,220,400,20,nil,nil,kTextAlignment.right,nil)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)

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
                else
                    currentAudio:setOffset(lastOffset)
                    currentAudio:play()
                end
            end
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            onPlayingScreen = false
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

currentAudio:setFinishCallback(handleSongEnd)