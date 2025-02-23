fs.mkdir("music")
fs.mkdir("data")

pd.setMenuImage(menuGraphic)

local menu = pd.getSystemMenu()

playingMenuItem, error = menu:addMenuItem("now playing", function()
  handler.swap("nowPlaying")
end)
modeMenuItem, error = menu:addOptionsMenuItem("mode", {"none","shuffle","loop folder","loop one","queue"}, modeString, handleMode) -- added modeString as the default so the munie shows teh corect setting
settingsModeMenuItem, error = menu:addMenuItem("settings", function()
  handler.swap("settings")
end)

settings.load()
settingsScreen.refresh()
