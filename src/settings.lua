-- settings

settings = {}

settings.defaultSettings = {
  darkmode = true,
  clockMode = false, -- 24 hour clock
  showInfoEverywhere = false,
  lockScreen = false,
  lockScreenTime = 2,
  screenRoundness = 4,
  newUI = true
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
