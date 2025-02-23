filesScreen = {}

filesScreen.dir = "/music/"

filesScreen.listAnimator = gfx.animator.new(0, 0, 0)

filesScreen.list = PDList({cellh = 25, padb = 3})

local fl = filesScreen.list

local animatorDuration = 250

function filesScreen.AButtonDown()
  local path = filesScreen.dir .. "/" .. filesScreen.files[fl:getRow()]

  if fs.isdir(path) then
    filesScreen.moveToDir(path)

    fl:setSelectedRow(1)

    filesScreen.listAnimator = gfx.animator.new(animatorDuration, 200, 0, pd.easingFunctions.outExpo)
  else
    audio.play(path)

    handler.swap("nowPlaying")
  end
end

function filesScreen.BButtonDown()
  local spl = string.split(filesScreen.dir, "/")

  table.remove(spl, #spl)

  local cct = table.concat(spl, "/")

  if cct ~= "" then
    filesScreen.moveToDir(cct)

    filesScreen.listAnimator = gfx.animator.new(animatorDuration, -200, 0, pd.easingFunctions.outExpo)
  end
end

function filesScreen.upButtonDown()
  fl:previous()
end

function filesScreen.downButtonDown()
  fl:next()
end

function filesScreen.update(force)
  pd.timer.updateTimers()

  if fl:needsDisplay() or filesScreen.listAnimator:ended() == false or force then
    gfx.clear()
    drawScreenRect()

    fl:drawInRect(20 + math.floor(filesScreen.listAnimator:currentValue()), 15, 360 - math.floor(filesScreen.listAnimator:currentValue()), 210)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 15, 20, 360)
    gfx.setColor(gfx.kColorBlack)
  end

  drawInfo()
  drawVersion()
end

function filesScreen.moveToDir(dir)
  filesScreen.dir = dir

  fileList = fs.listFiles(dir)

  filesScreen.files = {}

  for i, v in ipairs(fileList) do
    if findSupportedTypes(v) or fs.isdir(dir .. "/" .. v) then
      table.insert(filesScreen.files, v)
    end
  end

  fl:set(filesScreen.files)
end
