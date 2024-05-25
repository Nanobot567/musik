-- utility functions

function indexOf(tab, str)
  for i, s in ipairs(tab) do
    if s == str then
      return i
    end
  end
  return nil
end

function inTable(tab, str)
  for i, v in ipairs(tab) do
    if v == str then
      return true
    end
  end

  return false
end

function findSupportedTypes(str)
  if str ~= nil then
    if (string.find(str,"%.mp3",#str-3) ~= nil or string.find(str,"%.pda",#str-3) ~= nil) and string.find(str,"/",#str-1) == nil then
      return true
    end
    return false
  end
end

function fixFormatting(string)
  return string.gsub(string.gsub(string,"*","**"),"_","__")
end

function formatSeconds(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "0:00"
  else
    hours = string.format("%02.f", math.floor(seconds/3600))
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))
    return mins..":"..secs
  end
end

function split(inputstr,sep)
  t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    -- "([^"..sep.."]+)"
    table.insert(t, str)
  end

  return t
end
