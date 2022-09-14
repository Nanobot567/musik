import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

function updateCrank()
    local crankState = playdate.getCrankTicks(4)
    local textRect = playdate.geometry.rect.new(0, 110, 400, 20)
    local textColor

    if darkMode == true then
        textColor = gfx.kDrawModeCopy
    else
        textColor = gfx.kDrawModeFillWhite
    end

    if playdate.isCrankDocked() == false and currentAudio:isPlaying() == true then
        local text = "play rate: "..currentAudio:getRate().." - dock crank to hide"
        gfx.fillRect(textRect)
        gfx.setColor(bgColor)
        gfx.setImageDrawMode(textColor)
        gfx.drawTextInRect(text,textRect,nil,nil,kTextAlignment.center)
        if crankState == 1 then
            currentAudio:setRate(currentAudio:getRate()+0.25)
        elseif crankState == -1 then
            currentAudio:setRate(currentAudio:getRate()-0.25)
        end
        gfx.setColor(color)
        gfx.setImageDrawMode(dMColor1)
    end
end