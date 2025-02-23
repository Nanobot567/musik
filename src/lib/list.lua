-- List gridview wrapper class by nanobot567

import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/ui"

local pd <const> = playdate
local gfx <const> = pd.graphics

---@class PDList
PDList = {}

class("PDList").extends()

-- initialize PDList, with pd.ui.gridview properties
--
-- properties is a key-value table, which can provide the following values:
--
-- cellwidth: gridview cell width (default 0)
-- cellheight: gridview cell height (default 20)
-- padl: left cell padding (default 0)
-- padr: right cell padding (default 0)
-- padt: top cell padding (default 0)
-- padb: bottom cell padding (default 0)
-- insetl: left content inset padding (default 5)
-- insetr: right content inset padding (default 5)
-- insett: top content inset padding (default 5)
-- insetb: bottom content inset padding (default 5)
-- selectioncolor: selection color (default kColorBlack)
---@param properties? table
---@return PDList
function PDList:init(properties)
  self.properties = {
    cellwidth = 0,
    cellheight = 20,
    padl = 0,
    padr = 0,
    padt = 0,
    padb = 0,
    insetl = 5,
    insetr = 5,
    insett = 5,
    insetb = 5
  }

  if type(properties) == "table" then
    for k, v in pairs(properties) do
      self.properties[k] = v
    end
  end

  self.textcolor = gfx.kDrawModeNXOR

  self.labels = {}

  self.list = pd.ui.gridview.new(self.properties.cellwidth, self.properties.cellheight)
  self.list:setNumberOfRows(1)

  self.list:setCellPadding(self.properties.padl, self.properties.padr, self.properties.padt, self.properties.padb)

  self.list:setContentInset(self.properties.insetl, self.properties.insetr, self.properties.insett,
    self.properties.insetb)

  self.listitems = {}

  self.bindings = {}

  local otherSelf = self

  function self.list:drawCell(section, row, column, selected, x, y, width, height)
    if selected then
      gfx.setColor(gfx.kColorXOR)
      gfx.fillRoundRect(x, y, width, height, 4)
      gfx.setColor(gfx.kColorBlack)
      gfx.setImageDrawMode(otherSelf.textcolor)
    else
      gfx.setColor(gfx.kColorBlack)
      gfx.setImageDrawMode(otherSelf.textcolor)
    end

    if otherSelf.labels then
      gfx.drawText(otherSelf.labels[row], x + 4, y + 2)
    else
      gfx.drawText(otherSelf.listitems[row], x + 4, y + 2)
    end
  end

  return self
end

--- draw PDList in a rectangle
--- @param x number
--- @param y number
--- @param w number
--- @param h number
function PDList:drawInRect(x, y, w, h)
  self.list:drawInRect(x, y, w, h)
end

--- set items in a PDList
---@param items table
---@param preserveLabels? boolean
---@param row? number
function PDList:set(items, preserveLabels, row)
  if row == nil then
    row = 1
  end

  self.listitems = items

  if not preserveLabels then
    self.labels = table.deepcopy(items)
  end

  self.list:setNumberOfRows(#items)
  self.list:setSelectedRow(row)
  self.list:scrollToRow(row)
end

--- set label at item position index
---@param index number
---@param label string
function PDList:setLabel(index, label)
  self.labels[index] = label
end

--- select the next row in the list
---@param wrap? boolean
function PDList:next(wrap)
  self.list:selectNextRow(wrap)
end

--- select the previous row in the list
---@param wrap? boolean
function PDList:previous(wrap)
  self.list:selectPreviousRow(wrap)
end

---get the current selected row
---@return integer
function PDList:getRow()
  return self.list:getSelectedRow()
end

---get the text at the current row (not the label)
---@return string
function PDList:getRowText()
  return self.listitems[self.list:getSelectedRow()]
end

---check if the list needs to be displayed
---@return boolean
function PDList:needsDisplay()
  return self.list.needsDisplay
end

---get the internal playdate.ui.gridview
---@return playdate.ui.gridview
function PDList:getListView()
  return self.list
end

---get list view items
---@return table
function PDList:getListViewItems()
  return self.listitems
end

---scroll to row
---@param row number
function PDList:scrollToRow(row)
  self.list:scrollToRow(row)
end

---scroll to the top of the list
---@param animate boolean
function PDList:scrollToTop(animate)
  self.list:scrollToTop(animate)
end

---set the text at a row
---@param row number
---@param text string
---@param preserveLabel? boolean
function PDList:setRow(row, text, preserveLabel)
  self.listitems[row] = text

  if not preserveLabel then
    self.labels[row] = text
  end
end

---set the selected row
---@param row any
function PDList:setSelectedRow(row)
  self.list:setSelectedRow(row)
end

---set the text draw color (default kDrawModeNXOR)
---@param color number
function PDList:setTextDrawColor(color)
  self.textcolor = color
end

---bind an action to item titled `item` or at index `item`
---@param item number | string
---@param action function | nil
function PDList:bindAction(item, action)
  self.bindings[item] = action
end

---call binding attached to current item
---@param ... any
---@return unknown
function PDList:callBinding(...)
  if self.bindings[self:getRowText()] then
    return self.bindings[self:getRowText()](...)
  elseif self.bindings[self:getRow()] then
    return self.bindings[self:getRow()](...)
  end

  return nil
end

---clear all bindings
function PDList:clearBindings()
  self.bindings = {}
end


