-- listviews
local gfx <const> = pd.graphics

fileList = pd.ui.gridview.new(0, 10)
fileList:setScrollDuration(250)
fileList:setCellPadding(0, 0, 5, 10)
fileList:setContentInset(24, 24, 13, 11)

function fileList:drawCell(section, row, column, selected, x, y, width, height)
  local toWrite = fixFormatting(files[row])
  if files[row] ~= nil then
    if selected then
      gfx.fillRoundRect(x, y, width, 20, 4)
      gfx.setImageDrawMode(dMColor2)
    else
      gfx.setImageDrawMode(dMColor1)
    end

    if (files[row] == currentFileName and dir == currentFileDir) then
      toWrite = "*" .. toWrite .. "*"
    elseif inTable(queueList, dir .. files[row]) then
      toWrite = "_" .. toWrite .. "_"
    end
    gfx.drawText(toWrite, x + 4, y + 2)
  end
end

settingsList = pd.ui.gridview.new(0, 10)
settingsList:setScrollDuration(250)
settingsList:setCellPadding(0, 0, 5, 10)
settingsList:setContentInset(24, 24, 13, 11)

function settingsList:drawCell(section, row, column, selected, x, y, width, height)
  local toWrite = settings[row]
  if settings[row] ~= nil then
    if selected then
      gfx.fillRoundRect(x, y, width, 20, 4)
      gfx.setImageDrawMode(dMColor2)
    else
      gfx.setImageDrawMode(dMColor1)
    end

    if settings[row] == currentFileName and dir == currentFileDir then
      toWrite = "*" .. toWrite .. "*"
    end
    gfx.drawText(toWrite, x + 4, y + 2)
  end
end

