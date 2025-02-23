-- screen handler

handler = {}
handler.screens = {
  files = filesScreen,
  nowPlaying = nowPlayingScreen,
  settings = settingsScreen
}

handler.current = nil
handler.last = nil

function handler.swap(screen)
  handler.last = handler.current

  inp.pop()

  inp.push(handler.screens[screen], true)

  pd.update = handler.screens[screen].update

  handler.current = screen

  pd.update(true)
end
