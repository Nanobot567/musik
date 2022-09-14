import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/nineslice"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

function swapScreenMode()
    if screenMode == 0 then
        screenMode = 1
    elseif screenMode == 1 then
        screenMode = 0
            
        if currentFileDir == "" then
            dir = "/music/"
        else
            dir = currentFileDir
            files = playdate.file.listFiles(currentFileDir, false)
            for i,v in ipairs(files) do
                if v == currentFileName then
                    fileList:setSelectedRow(i)
                    fileList:scrollToRow(i, true)
                end
            end
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

function handleMode(str) -- add queue mode
    print("mode is now "..str)
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

function split(inputstr,sep)
    t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        -- "([^"..sep.."]+)"
        table.insert(t, str)
    end

    return t
end

function newSettingsList()
    return {"dark mode - "..tostring(darkMode),
    "24 hour clock - "..tostring(clockMode),
    "show extra info everywhere - "..tostring(showInfoEverywhere)}
end

function drawInfo()
    local time = playdate.getTime()
    if #tostring(time["hour"]) == 1 then
        time["hour"] = "0"..time["hour"]
    end

    if clockMode == false then
        if tonumber(time["hour"]) > 12 then
            time["hour"] -= 12
        end
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
    -- gfx.setImageDrawMode(dMColor2)
end

function handleSongEnd()
    if mode == 2 then
        if currentFileName == audioFiles[1] then
            currentPos = 1
        end
        if currentFileName == audioFiles[#audioFiles] then
            if not playdate.buttonIsPressed(playdate.kButtonA) then
                if playdate.file.isdir(dir..audioFiles[1]) == false then
                    currentFileName = audioFiles[1]
                    currentAudio:load(dir..audioFiles[1])
                end
            end
        else
            local isdir = playdate.file.isdir(dir..audioFiles[currentPos+1])
            if isdir == true then
                currentPos += 2
            else
                currentPos += 1
            end

            currentFileName = audioFiles[currentPos]
            currentAudio:load(dir..audioFiles[currentPos])
        end
    elseif mode == 1 then
        local randthing = math.random(1,#audioFiles)
        if playdate.file.isdir(dir..audioFiles[randthing]) == false then
            currentFileName = audioFiles[randthing]
            currentAudio:load(dir..audioFiles[randthing])
        end
    elseif mode == 3 then
        currentAudio:setOffset(0)
    elseif mode == 0 then
        currentAudio = playdate.sound.fileplayer.new()
    end
    currentFilePath = dir..currentFileName
    currentFileDir = dir
    table.insert(lastSongNames,currentFileName)
    table.insert(lastSongDirs,currentFileDir)

    audioLen = currentAudio:getLength()

    if mode ~= 0 then
        currentAudio:setOffset(0)
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
    if screenMode == 0 then
        keyTimer:remove()
    end
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
    if screenMode == 0 then
        keyTimer:remove()
    end
end