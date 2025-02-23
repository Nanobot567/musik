import "CoreLibs/animator"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "lib/id3"
import "lib/list"

import "consts"
import "funcs"

import "draw"

import "audio"
import "files"
import "nowplaying"

import "handler"

import "settings"

import "setup"

function pd.update()
  filesScreen.moveToDir(filesScreen.dir)
  handler.swap("files")
end

function pd.gameWillTerminate()
  settings.save()
end
