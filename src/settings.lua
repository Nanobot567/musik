-- settings

settings = {}

settings.defaultSettings = {
  darkmode = true,
  clockMode = false, -- 24 hour clock
  showInfoEverywhere = false,
  lockScreen = false,
  lockScreenTime = 2,
  screenRoundness = 4,
  newUI = true,
  swapPlayPauseImages = false
}

settings.settings = {}

function settings.load()
  local settingsData = json.decodeFile("/data/settings")

  if settingsData == nil then
    settingsData = {}
  end

  for k, v in pairs(settings.defaultSettings) do
    if not settingsData[k] then
      settingsData[k] = v
    end
  end

  settings.settings = table.deepcopy(settingsData)

  pd.display.setInverted(settingsData["darkmode"])
end

function settings.save()
  json.encodeToFile("/data/settings", false, settings.settings)
end

settingsScreen = {}

settingsScreen.list = PDList({ padh = 25, padb = 3 })

function settingsScreen.refresh()
  settingsScreen.list:set({
    "darkmode",
    "clockMode",
    "showInfoEverywhere",
    "lockScreen",
    "lockScreenTime",
    "screenRoundness",
    "newUI",
    "swapPlayPauseImages"
  }, false, settingsScreen.list:getRow())
  settingsScreen.list:setLabels({
      "dark mode - " .. tostring(settings.settings["darkmode"]),
      "24 hour clock - " .. tostring(settings.settings["clockMode"]),
      "show extra info everywhere - " .. tostring(settings.settings["showInfoEverywhere"]),
      "lock screen - " .. tostring(settings.settings["lockScreen"]),
      "lock screen time - " .. tostring(settings.settings["lockScreenTime"]) .. " min.",
      "screen roundness - " .. tostring(settings.settings["screenRoundness"]),
      "new UI - " .. tostring(settings.settings["newUI"]),
      "swap play graphic with pause graphic - " .. tostring(settings.settings["swapPlayPauseImages"])
    })
end

function settingsScreen.update(force)
  if settingsScreen.list:needsDisplay() or force then
    gfx.clear()
    drawScreenRect()

    settingsScreen.list:drawInRect(20, 15, 360, 210)
  end

  drawInfo()
  drawVersion()
end

function settingsScreen.upButtonDown()
  settingsScreen.list:previous()
end

function settingsScreen.downButtonDown()
  settingsScreen.list:next()
end

function settingsScreen.AButtonDown()
  local text = settingsScreen.list:getRowText()

  if text == "lockScreenTime" then
    local t = settings.settings["lockScreenTime"]

    if t >= 1 and t ~= 5 then
      settings.settings["lockScreenTime"] += 1
    elseif t == 5 then
      settings.settings["lockScreenTime"] = 1
    end
  elseif text == "screenRoundness" then
    local r = settings.settings["screenRoundness"]

    if r >= 1 and r < 8 then
      if r == 1 or r == 6 then
        settings.settings["screenRoundness"] += 2
      else
        settings.settings["screenRoundness"] += 1
      end
    elseif r >= 8 then
      settings.settings["screenRoundness"] = 1
    end
  else
    settings.settings[text] = not settings.settings[text]
  end

  pd.display.setInverted(settings.settings["darkmode"])
  settingsScreen.refresh()
  settingsScreen.update(true)
end

function settingsScreen.BButtonDown()
  handler.swap(handler.last)
end
