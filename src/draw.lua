function drawInfo()
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

  local w, h = gfx.getTextSize(batteryPercent .. "%", musikFont)

  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(0, 0, 400, musikFont:getHeight())
  gfx.setColor(gfx.kColorBlack)

  musikFont:drawTextAligned(time["hour"] .. ":" .. time["minute"], 1, 1, 400, 20, kTextAlignment.left)
  musikFont:drawTextAligned(batteryPercent .. "%", 401 - w, 1, 400, 20, kTextAlignment.right)
end

function drawScreenRect()
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRoundRect(20, 15, 360, 210, settings.settings["screenRoundness"])
  gfx.setColor(gfx.kColorBlack)

  gfx.drawRoundRect(20, 15, 360, 210, settings.settings["screenRoundness"])
end

function drawVersion()
  local musikTextX, musikTextY, musikTextAlignment = 200, 229, kTextAlignment.center

  if settings.settings["newUI"] == false then
    musikTextX = 400
    musikTextY = 232
    musikTextAlignment = kTextAlignment.right
  end

  musikFont:drawTextAligned("musik " .. pd.metadata.version .. " eta", musikTextX, musikTextY, musikTextAlignment, nil)
end

