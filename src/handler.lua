-- screen handler

handler = {}
handler.screens = {
  files = filesScreen,
  nowPlaying = nowPlayingScreen,
  settings = settingsScreen
}

function handler.swap(screen)
  inp.pop()

  inp.push(handler.screens[screen], true)

  pd.update = handler.screens[screen].update

  pd.update(true)
end
