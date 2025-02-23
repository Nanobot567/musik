-- song class

class("Song").extends()

function Song:init(path, name)
  self.path = path
  self.name = name
end

function Song:__tostring()
  return self.name
end

function Song:getPath()
  return self.path
end
